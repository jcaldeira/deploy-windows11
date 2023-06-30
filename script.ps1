# https://learn.microsoft.com/en-us/windows/package-manager/winget/#install-winget-on-windows-sandbox

#region - Variables
$InformationPreference = 'Continue'
$GitBranch = 'development'
$ScriptFiles = "$($Env:TEMP)\deploy-windows11-$GitBranch"
$SettingsManifests = "$ScriptFiles\assets\settings manifests"
$RegistryTweaks = "$ScriptFiles\assets\registry tweaks"

#endregion - Variables


#region - Set up environment
# Download deployment files
Write-Information -MessageData 'Downloading GitHub Files'
Invoke-WebRequest -Uri "https://github.com/jcaldeira/deploy-windows11/archive/refs/heads/$GitBranch.zip" -OutFile "$ScriptFiles.zip"

# Unzip files
Expand-Archive -Path "$ScriptFiles.zip" -DestinationPath $Env:TEMP

#endregion - Set up environment


#region - Tweak Windows OS
# Hostname
Rename-Computer -NewName 'CaldeiraROG'

# Apply .reg files
foreach ($Item in (Get-ChildItem -Path $RegistryTweaks)) {
    regedit.exe /s $Item.FullName
}

# RDP
Enable-NetFirewallRule -DisplayGroup 'Remote Desktop'

#endregion


#region - Enable Windows optional features and capabilities
#region - Windows optional features
# https://learn.microsoft.com/en-us/virtualization/hyper-v-on-windows/quick-start/enable-hyper-v#enable-hyper-v-using-powershell
$Features = @(
    'Microsoft-Hyper-V',
    'IIS-WebServerRole',
    'Microsoft-Windows-Subsystem-Linux',
    'Containers-DisposableClientVM', # Windows Sandbox
    'TelnetClient',
    'TFTP'
)

foreach ($Item in $Features) {
    Enable-WindowsOptionalFeature -FeatureName $Item -All -NoRestart -Online
}

#endregion - Windows optional features

#region - Windows capabilities
# Install the OpenSSH Client and Server
# https://learn.microsoft.com/en-us/windows-server/administration/openssh/openssh_install_firstuse?tabs=powershell#install-openssh-for-windows
$Capability = @(
    # 'OpenSSH.Client~~~~0.0.1.0',
    'OpenSSH.Server~~~~0.0.1.0'
)

foreach ($Item in $Capability) {
    Add-WindowsCapability -Online -Name $Item
}

#endregion - Windows capabilities

#endregion - Enable Windows optional features and capabilities


#region - Install software
#region - Set winget settings
# https://learn.microsoft.com/en-us/windows/package-manager/winget/settings#scope
Copy-Item -Path "$SettingsManifests\winget.json" -Destination "$Env:LOCALAPPDATA\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState\settings.json"

#endregion - Set winget settings

#region - Install passively
$Passive = @(
    '7zip.7zip',
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
    'Microsoft.PowerToys',
    'Microsoft.WindowsTerminal',
    'Nvidia.GeForceExperience',
    'Ookla.Speedtest.Desktop',
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
    # 'Ookla.Speedtest.CLI',
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
# https://docs.python.org/3/using/windows.html#installing-without-ui
winget install Python3 --accept-source-agreements --accept-package-agreements --override 'InstallAllUsers=1 CompileAll=1 /passive'

# Install WSL with Ubuntu
# https://learn.microsoft.com/en-us/windows/wsl/install-manual
# Invoke-WebRequest -Uri 'https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi' -OutFile "$ScriptFiles\wsl_update_x64.msi"
wsl --install
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
    Invoke-WebRequest -Uri $Item.Value -OutFile "$ScriptFiles\$($Item.Name)"
}

# Execute/unzip installers
foreach ($Item in $Links.GetEnumerator()) {
    $FileName, $FileExt = (Split-Path -Path $Item.Name -Leaf).Split('.')
    if ($FileExt -eq 'zip') {
        Expand-Archive -Path "$ScriptFiles\$($Item.Name)" -DestinationPath "$ScriptFiles\$FileName"
        Write-Output "Opening file explorer for $ScriptFiles\$FileName"
        explorer.exe "$ScriptFiles\$FileName"
        Continue
    }
    Write-Output "Executing $ScriptFiles\$($Item.Name)"
    . "$ScriptFiles\$($Item.Name)"
    Read-Host -Prompt 'Press ENTER to continue'
}

#endregion - Manual installation

#endregion - Install interactively

#endregion - Install software


#region - Costumize installed software
#region - Windows Terminal
# https://learn.microsoft.com/en-us/windows/terminal/install#settings-json-file
Copy-Item -Path "$SettingsManifests\windows terminal.json" -Destination "$Env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

#endregion - Windows Terminal

#endregion - Costumize installed software
