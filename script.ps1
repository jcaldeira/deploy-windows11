# https://learn.microsoft.com/en-us/windows/package-manager/winget/#install-winget-on-windows-sandbox

#region - Variables
$ScriptFiles = "$($Env:TEMP)\deploy-windows11-development"

#endregion - Variables

#region - Tweak Windows OS
# Hostname
Rename-Computer -NewName "CaldeiraROG"

# Disable 260 char filesystem path limit
# https://learn.microsoft.com/en-us/windows/win32/fileio/maximum-file-path-limitation?tabs=powershell
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem' -Name 'LongPathsEnabled' -Value 1 -PropertyType DWORD -Force

# File Explorer
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'HideFileExt' -Value 0 -PropertyType DWORD -Force # File name extensions
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'Hiden' -Value 1 -PropertyType DWORD -Force # Show hidden files, folders and drives
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'HideDrivesWithNoMedia' -Value 0 -PropertyType DWORD -Force # Hide empty drives
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'SeparateProcess' -Value 1 -PropertyType DWORD -Force # Launch folder windows in a separate process
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'NavPaneShowAllCloudStates' -Value 1 -PropertyType DWORD -Force # Always show availability status
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'HideMergeConflicts' -Value 0 -PropertyType DWORD -Force # Hide folder merge conflicts

# RDP
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server' -Name 'fDenyTSConnections' -Value 0 -PropertyType DWORD -Force
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

# Clipboard history and cloud sync
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Clipboard' -Name 'EnableClipboardHistory' -Value 1 -PropertyType DWORD -Force
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Clipboard' -Name 'EnableCloudClipboard' -Value 1 -PropertyType DWORD -Force
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Clipboard' -Name 'CloudClipboardAutomaticUpload' -Value 1 -PropertyType DWORD -Force

# Touchpad
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\PrecisionTouchPad' -Name 'ScrollDirection' -Value 'ffffffff' -PropertyType DWORD -Force
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\PrecisionTouchPad' -Name 'LeaveOnWithMouse' -Value 0 -PropertyType DWORD -Force
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\PrecisionTouchPad' -Name 'ThreeFingerTapEnabled' -Value 4 -PropertyType DWORD -Force

# Multiple displays
Set-ItemProperty -Path 'HKCU:\HKEY_CURRENT_USER\Control Panel\Cursors' -Name 'CursorDeadzoneJumpingSetting' -Value 0 -PropertyType DWORD -Force # Ease cursor movement between displays


#endregion


#region - Enable Windows optional features and capabilities
#region - Windows optional features
# https://learn.microsoft.com/en-us/virtualization/hyper-v-on-windows/quick-start/enable-hyper-v#enable-hyper-v-using-powershell
Enable-WindowsOptionalFeature -FeatureName 'Microsoft-Hyper-V' -All -NoRestart -Online
Enable-WindowsOptionalFeature -FeatureName 'IIS-WebServerRole' -All -NoRestart -Online
Enable-WindowsOptionalFeature -FeatureName 'Microsoft-Windows-Subsystem-Linux' -All -NoRestart -Online
Enable-WindowsOptionalFeature -FeatureName 'Containers-DisposableClientVM' -All -NoRestart -Online # Windows Sandbox
Enable-WindowsOptionalFeature -FeatureName 'TelnetClient' -All -NoRestart -Online
Enable-WindowsOptionalFeature -FeatureName 'TFTP' -All -NoRestart -Online

#endregion - Windows optional features

#region - Windows capabilities
# Install the OpenSSH Client and Server
# https://learn.microsoft.com/en-us/windows-server/administration/openssh/openssh_install_firstuse?tabs=powershell#install-openssh-for-windows
Add-WindowsCapability -Online -Name 'OpenSSH.Server~~~~0.0.1.0'
Add-WindowsCapability -Online -Name 'OpenSSH.Client~~~~0.0.1.0'

#endregion - Windows capabilities

#endregion - Enable Windows optional features and capabilities


#region - Set up environment
# Download deployment files
Invoke-WebRequest -Uri 'https://github.com/jcaldeira/deploy-windows11/archive/refs/heads/development.zip' -OutFile "$ScriptFiles.zip"

# Unzip files
Expand-Archive -Path "$ScriptFiles.zip" -DestinationPath $ScriptFiles

#endregion - Set up environment


#region - Install software
#region - Set winget settings
# https://learn.microsoft.com/en-us/windows/package-manager/winget/settings#scope
Copy-Item -Path "$ScriptFiles\settings manifests\winget.json" -Destination "$Env:LOCALAPPDATA\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState\settings.json"

#endregion - Set winget settings

#region - Install passively
$Passive = @(
    '9N0866FS04W8', # Dolby Access
    '9N7R5S6B0ZZH', # MyASUS
    '9NBLGGH33N0N', # WiFi Analyser
    '9NBLGGH516XP', # EarTrumpet
    'Asus.ArmouryCrate',
    'Bitwarden.Bitwarden',
    'Discord.Discord',
    'EpicGames.EpicGamesLauncher',
    'GOG.Galaxy',
    'Google.Chrome',
    'Google.Drive',
    'Jellyfin.JellyfinMediaPlayer',
    'M2Team.NanaZip',
    'Microsoft.PowerToys',
    'Microsoft.WindowsTerminal',
    'Nvidia.GeForceExperience',
    'Ookla.Speedtest',
    'RiotGames.LeagueOfLegends.EUW',
    'Twilio.Authy',
    'Ubisoft.Connect',
    'Valve.Steam',
    'VideoLAN.VLC',
    'WhatsApp.WhatsApp'
    # '9P7KNL5RWT25', # Sysinternals Suite
    # 'Amazon.SendToKindle'
    # 'Axosoft.GitKraken',
    # 'Balena.Etcher',
    # 'Bitwarden.CLI',
    # 'calibre.calibre',
    # 'Facebook.Messenger',
    # 'GitHub.GitHubDesktop',
    # 'HandBrake.HandBrake.CLI'
    # 'HandBrake.HandBrake',
    # 'Insecure.Nmap'
    # 'LibreCAD.LibreCAD',
    # 'Logitech.LGS',
    # 'Maxon.CinebenchR23',
    # 'Microsoft.SQLServerManagementStudio',
    # 'MoonlightGameStreamingProject.Moonlight',
    # 'MoritzBunkus.MKVToolNix',
    # 'Notepad++.Notepad++',
    # 'OBSProject.OBSStudio',
    # 'Pushbullet.Pushbullet',
    # 'RaspberryPiFoundation.RaspberryPiImager'
    # 'REALiX.HWiNFO',
    # 'ShiningLight.OpenSSL',
    # 'Spotify.Spotify',
    # 'Telegram.TelegramDesktop',
    # 'Zoom.Zoom',
)

foreach ($Item in $Passive) {
    winget install --query $Item --exact --accept-source-agreements --accept-package-agreements
}

# Install Python 3
winget install Python3 --accept-source-agreements --accept-package-agreements --override 'InstallAllUsers=1 CompileAll=1 /passive'

# Install WSL with Ubuntu
wsl --install --distribution Ubuntu --no-launch
# wsl --set-default-version 2

#endregion - Install passively

#region - Install interactively
$Interactive = @(
    'Microsoft.VisualStudioCode',
    'Git.Git',
    'Microsoft.PowerShell'
    # 'qBittorrent.qBittorrent'
)

foreach ($Item in $Interactive) {
    winget install --query $Item --interactive --exact --accept-source-agreements --accept-package-agreements
}


#region - Manual installation
# Download installers
$Links = @{
    'BloatyNosySetup.msi'                   = 'https://github.com/builtbybel/BloatyNosy/releases/download/0.85.0/BloatyNosySetup.msi'
    'MEOCloudSetup.exe'                     = 'https://downloads.meocloud.pt/windows/MEOCloudSetup.exe'
    'Battle.net-Setup.exe'                  = 'https://eu.battle.net/download/getInstaller?os=win&installer=Battle.net-Setup.exe'
    'OneNoteFreeRetail.exe'                 = 'https://c2rsetup.officeapps.live.com/c2r/download.aspx?productReleaseID=OneNoteFreeRetail&platform=def&language=en-us&version=O16GA&Source=O16ONF'
    'OverwolfInstaller.exe'                 = 'https://download.overwolf.com/installer/prod/c7dc01d342165d5dbbb027d6d090ff80/OverwolfInstaller.exe'
    'VBCABLE_Driver_Pack43.zip'             = 'https://download.vb-audio.com/Download_CABLE/VBCABLE_Driver_Pack43.zip'
    'RazerSynapseInstaller_V1.13.1.433.exe' = 'https://dl.razerzone.com/drivers/Synapse3/win/RazerSynapseInstaller_V1.13.1.433.exe'
    'Install-iCUE-5.2.exe'                  = 'https://downloads.corsair.com/Files/icue/Install-iCUE-5.2.exe'
}

foreach ($Item in $Links.GetEnumerator()) {
    Invoke-WebRequest -Uri $Item.Value -OutFile "$Env:TEMP\$($Item.Name)"
}

# Execute/unzip installers
foreach ($Item in $Links.GetEnumerator()) {
    $FileName, $FileExt = (Split-Path -Path $Item.Name -Leaf).Split('.')
    if ($FileExt -eq 'zip') {
        Expand-Archive -Path "$Env:TEMP\$($Item.Name)" -DestinationPath "$Env:TEMP\$FileName"
        Write-Output "Opening file explorer for $Env:TEMP\$FileName"
        explorer.exe "$Env:TEMP\$FileName"
        Continue
    }
    Write-Output "Executing $($Item.Name)"
    . "$Env:TEMP\$($Item.Name)"
}

#endregion - Manual installation

#endregion - Install interactively

#endregion - Install software


#region - Costumize installed software
#region - Windows Terminal
# https://learn.microsoft.com/en-us/windows/terminal/install#settings-json-file
Copy-Item -Path "$ScriptFiles\settings manifests\windows terminal.json" -Destination "$Env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

#endregion - Windows Terminal

#region - OpenSSH server
# Set default shell to PowerShell
# https://learn.microsoft.com/en-us/windows-server/administration/openssh/openssh_server_configuration?source=recommendations#configuring-the-default-shell-for-openssh-in-windows
Set-ItemProperty -Path 'HKLM:\SOFTWARE\OpenSSH' -Name DefaultShell -Value 'C:\Program Files\PowerShell\7\pwsh.exe' -PropertyType String -Force

#endregion - OpenSSH server

#endregion - Costumize installed software
