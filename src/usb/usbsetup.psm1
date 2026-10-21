Add-Type -AssemblyName PresentationFramework

function Show-UsbWindow {
    param(
        [Parameter(Mandatory)]
        [object[]]$Items,
        [Parameter(Mandatory)]
        [scriptblock]$RefreshCallback,
        [Parameter(Mandatory)]
        [scriptblock]$EjectCallback
    )

    $XAML = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="USB Manager" Height="600" Width="900"
        WindowStartupLocation="CenterScreen"
        Background="#000000">

    <Grid Margin="10">

        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="3*"/>
            <ColumnDefinition Width="2*"/>
        </Grid.ColumnDefinitions>

        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>

        <TextBlock Text="USB Keys"
                   Foreground="White"
                   FontSize="22"
                   Grid.ColumnSpan="2"
                   Margin="0,0,0,10"/>

        <!-- LISTE USB -->
        <ScrollViewer Grid.Row="1" Grid.Column="0" VerticalScrollBarVisibility="Auto">
            <ListBox x:Name="UsbList"
                Background="Transparent"
                BorderThickness="0"
                ScrollViewer.VerticalScrollBarVisibility="Auto"
                ScrollViewer.HorizontalScrollBarVisibility="Disabled">

                <ListBox.ItemTemplate>
                    <DataTemplate>
                        <Border BorderBrush="#444" BorderThickness="1" CornerRadius="5" Margin="0,0,0,10" Padding="10">
                            <Grid>
                                <Grid.ColumnDefinitions>
                                    <ColumnDefinition Width="3*"/>
                                    <ColumnDefinition Width="2*"/>
                                    <ColumnDefinition Width="Auto"/>
                                </Grid.ColumnDefinitions>

                                <StackPanel>
                                    <TextBlock Text="{Binding Name}" Foreground="White" FontSize="16" FontWeight="Bold"/>
                                    <TextBlock Text="{Binding IdDisplay}" Foreground="#CCC" FontSize="12"/>
                                </StackPanel>

                                <StackPanel Grid.Column="1">
                                    <TextBlock Text="{Binding Status}" Foreground="{Binding StatusColor}" FontSize="13"/>
                                    <TextBlock Text="{Binding DriveDisplay}" Foreground="#DDD" FontSize="12"/>
                                </StackPanel>

                                <Button Grid.Column="2"
                                        Content="Eject"
                                        Padding="10,5"
                                        Margin="10,0,0,0"
                                        Tag="{Binding DriveLetter}"
                                        Background="#AA3333"
                                        Foreground="White"
                                        IsEnabled="{Binding CanEject}"/>
                            </Grid>
                        </Border>
                    </DataTemplate>
                </ListBox.ItemTemplate>
            </ListBox>
        </ScrollViewer>

            <Border Grid.Row="1" Grid.Column="1"
                    Background="#1E1E1E"
                    BorderBrush="#333"
                    BorderThickness="1"
                    CornerRadius="6"
                    Padding="15"
                    Margin="15,0,0,0"
                    x:Name="DetailsPanel">

                <StackPanel>

                    <TextBlock Text="Détails de la clé"
                               FontSize="18"
                               Foreground="White"
                               Margin="0,0,0,10"/>

                    <StackPanel Margin="0,5">
                        <TextBlock Text="Nom" Foreground="#888"/>
                        <TextBlock Text="{Binding Name}" Foreground="White" FontSize="14"/>
                    </StackPanel>

                    <StackPanel Margin="0,5">
                        <TextBlock Text="Identifiant" Foreground="#888"/>
                        <TextBlock Text="{Binding IdDisplay}" Foreground="White" FontSize="14"/>
                    </StackPanel>

                    <StackPanel Margin="0,5">
                        <TextBlock Text="Lettre" Foreground="#888"/>
                        <TextBlock Text="{Binding DriveDisplay}" Foreground="White" FontSize="14"/>
                    </StackPanel>

                    <StackPanel Margin="0,5">
                        <TextBlock Text="Statut" Foreground="#888"/>
                        <TextBlock Text="{Binding Status}" Foreground="White" FontSize="14"/>
                    </StackPanel>

                </StackPanel>
            </Border>


        <!-- BAS -->
        <Grid Grid.Row="2" Grid.ColumnSpan="2">
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="Auto"/>
                <ColumnDefinition Width="Auto"/>
                <ColumnDefinition Width="*"/>
            </Grid.ColumnDefinitions>

            <Button Grid.Column="0" x:Name="RefreshButton"
                    Content="Refresh" Width="120" Height="28"
                    Background="#3366AA" Foreground="White" Margin="0,5,10,0"/>

            <Button Grid.Column="1" x:Name="EjectAllButton"
                    Content="Eject All" Width="120" Height="28"
                    Background="#AA3333" Foreground="White" Margin="0,5,10,0"/>

            <TextBlock Grid.Column="2" x:Name="FooterText"
                       Foreground="#888" FontSize="11"
                       HorizontalAlignment="Right" VerticalAlignment="Center"
                       Margin="0,5,0,0"/>
        </Grid>

    </Grid>
</Window>
'@

    #Gestion d'erreur si aucune clé
    if (-not $Global:usbDisks -or -not $Global:usbVols) {
        Write-Host ""
        Write-Host "No USB devices Found"
        Write-Host ""
        Pause
        Clear-Host
        exit
    }

    # Charger XAML
    $xmlReader = New-Object System.Xml.XmlNodeReader ([xml]$XAML)
    #$Window = [Windows.Markup.XamlReader]::Load($xmlReader)
    #$Window.Show()
    #$Window.Activate()

    try {
        $Window = [Windows.Markup.XamlReader]::Load($xmlReader)
    }
    catch {
        Write-Host "❌ XAML ERROR"
        Write-Host $_.Exception.Message
        if ($_.Exception.InnerException) {
            Write-Host "➡  Ligne :" $_.Exception.InnerException.LineNumber
            Write-Host "➡  Position :" $_.Exception.InnerException.LinePosition
        }
        return
    }

    # Récupération des contrôles
    $UsbList = $Window.FindName("UsbList")
    $Footer = $Window.FindName("FooterText")
    $RefreshButton = $Window.FindName("RefreshButton")
    $EjectAllButton = $Window.FindName("EjectAllButton")
    $OpenButton = $Window.FindName("OpenButton")
    $CopyButton = $Window.FindName("CopyButton")
    $EjectButton = $Window.FindName("EjectButton")
    $DetailsPanel = $Window.FindName("DetailsPanel")

    # Remplissage initial
    $UsbList.ItemsSource = $Items
    $Footer.Text = "$($Items.Where({$_.CanEject}).Count) / $($Items.Count) detected"

    # Timer auto-refresh
    $timer = New-Object System.Windows.Threading.DispatcherTimer
    $timer.Interval = [TimeSpan]::FromSeconds(3)
    $timer.Add_Tick({
            # Sauvegarder l'index sélectionné
            $index = $UsbList.SelectedIndex

            # Rafraîchir la liste
            $newItems = & $RefreshCallback
            #$UsbList.ItemsSource = $null
            $UsbList.ItemsSource = $newItems

            # Restaurer la sélection visuelle
            if ($index -ge 0 -and $index -lt $newItems.Count) {
                $UsbList.SelectedIndex = $index
            }

            # Mettre à jour le footer
            $Footer.Text = "$($newItems.Where({$_.CanEject}).Count) / $($newItems.Count) detected"
        })
    $timer.Start()

    #Ne pas toucher au panneau de droite (je crois)
    $UsbList.Add_SelectionChanged({
            $item = $UsbList.SelectedItem
            if ($item) {
                $DetailsPanel.DataContext = $item
            }
        })

    # Bouton Ouvrir
    $OpenButton.Add_Click({
            $item = $UsbList.SelectedItem
            if ($item -and $item.DriveLetter) {
                Start-Process "explorer.exe" "$($item.DriveLetter):\"
            }
        })

    # Bouton Copier
    $CopyButton.Add_Click({
            $item = $UsbList.SelectedItem
            if ($item -and $item.DriveLetter) {
                Set-Clipboard "$($item.DriveLetter):\"
            }
        })

    # Bouton Refresh
    $RefreshButton.Add_Click({
            $newItems = & $RefreshCallback
            $UsbList.ItemsSource = $newItems
            $Footer.Text = "$($newItems.Where({$_.CanEject}).Count) / $($newItems.Count) detected"
        })

    #Bouton Eject :
    $EjectButton.Add_Click({
            $item = $UsbList.SelectedItem
            if ($item -and $item.DriveLetter) {
                & $EjectCallback $item.DriveLetter
            }
        })

    # Bouton Eject All
    $EjectAllButton.Add_Click({
            & $EjectCallback
        })

    # Bouton Eject individuel
    $UsbList.AddHandler(
        [System.Windows.Controls.Button]::ClickEvent,
        [System.Windows.RoutedEventHandler] {
            param($sender, $e)

            if ($e.OriginalSource -is [System.Windows.Controls.Button]) {
                $btn = $e.OriginalSource
                if ($btn.Tag) {
                    & $EjectCallback $btn.Tag
                }
            }
        }
    )
    $Window.ShowDialog() | Out-Null
}

Export-ModuleMember -Function Show-UsbWindow
