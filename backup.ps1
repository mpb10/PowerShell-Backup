<#
.SYNOPSIS 
	Automates the process of creating .zip backup files of user specified folders.
	
.DESCRIPTION 
	This script uses the 7-zip archive utility to create .zip archive files of user specified folders. This script can be ran via the command line using parameters, or it can be ran without parameters to use its GUI.
	
.PARAMETER InputPath 
	Specify the folder that is to be backed up.
.PARAMETER OutputPath 
	Specify the folder to which the backup will be saved.
.PARAMETER BackupList
	Backup folders listed in the backuplist.txt file. The first line is the folder to which the backups will be saved.

.EXAMPLE
	C:\Users\%USERNAME%\Scripts\Backup-Script\scripts\backup.ps1
	Runs the script in GUI mode.
.EXAMPLE
	C:\Users\%USERNAME%\Scripts\Backup-Script\scripts\backup.ps1 -InputPath "C:\Users\mpb10\Documents" -OutputPath "E:\Backups"
	Backups the user mpb10's Documents folder to "E:\Backups".
.EXAMPLE
	C:\Users\%USERNAME%\Scripts\Backup-Script\scripts\backup.ps1 -BackupList -OutputPath "E:\Backups"
	Backs up the folders listed in "C:\Users\%USERNAME%\Scripts\Backup-Script\config\backuplist.txt" to "E:\Backups".

.NOTES
	Requires Windows 7 or higher and PowerShell version 5.0 or greater.
	Author: mpb10
	Updated: November 27th, 2017
	Version: 2.0.0
.LINK 
	https://github.com/mpb10/PowerShell-Backup-Script
#>

# ======================================================================================================= #
# ======================================================================================================= #

Param (
	[String]$InputPath,
	[String]$OutputPath,
	[String]$OutputFormat,
	[Switch]$BackupList,
	[Switch]$Install,
	[Switch]$UpdateScript
)


# ======================================================================================================= #
# ======================================================================================================= #
#
# SCRIPT SETTINGS
#
# ======================================================================================================= #

$CheckForUpdates = $True





# ======================================================================================================= #
# ======================================================================================================= #
#
# LIBRARY
#
# ======================================================================================================= #

$InstallLocation = $ENV:USERPROFILE + "\Scripts\PowerShell-Backup"
$DesktopFolder = $ENV:USERPROFILE + "\Desktop"
$StartFolder = $ENV:APPDATA + "\Microsoft\Windows\Start Menu\Programs\PowerShell-Backup"
[Version]$RunningVersion = '2.0.0'
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
$CurrentDate = Get-Date -UFormat "%m-%d-%Y"



# ======================================================================================================= #
# ======================================================================================================= #
#
# FUNCTIONS
#
# ======================================================================================================= #

# Function for simulating the 'pause' command of the Windows command line.
Function PauseScript {
	If (($PSBoundParameters.Count) -eq 0) {
		Write-Host "`nPress any key to continue ...`n" -ForegroundColor "Gray"
		$Wait = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp")
	}
}



Function DownloadFile {
	Param(
		[String]$URLToDownload,
		[String]$SaveLocation
	)
	(New-Object System.Net.WebClient).DownloadFile("$URLToDownload", "$TempFolder\download.tmp")
	Move-Item -Path "$TempFolder\download.tmp" -Destination "$SaveLocation" -Force
}



Function Download7Zip {
	DownloadFile "http://www.7-zip.org/a/7za920.zip" "$BinFolder\7za920.zip"
	
	Expand-Archive -Path "$BinFolder\7za920.zip" -DestinationPath "$BinFolder\7za920"
	
	Copy-Item -Path "$BinFolder\7za920\7za.exe" -Destination "$BinFolder"
	Remove-Item -Path "$BinFolder\7za920.zip"
	Remove-Item -Path "$BinFolder\7za920" -Recurse -Force
}



Function ScriptInitialization {
	$Script:BinFolder = $RootFolder + "\bin"
	If ((Test-Path "$BinFolder") -eq $False) {
		New-Item -Type Directory -Path "$BinFolder" | Out-Null
	}
	$ENV:Path += ";$BinFolder"

	$Script:TempFolder = $RootFolder + "\temp"
	If ((Test-Path "$TempFolder") -eq $False) {
		New-Item -Type Directory -Path "$TempFolder" | Out-Null
	}
	Else {
		Remove-Item -Path "$TempFolder\download.tmp" -ErrorAction Silent
	}

	$Script:ConfigFolder = $RootFolder + "\config"
	If ((Test-Path "$ConfigFolder") -eq $False) {
		New-Item -Type Directory -Path "$ConfigFolder" | Out-Null
	}

	$Script:BackupListFile = $ConfigFolder + "\BackupList.txt"
	If ((Test-Path "$BackupListFile") -eq $False) {
		DownloadFile "https://github.com/mpb10/PowerShell-Backup/raw/version-2.0.0/install/files/BackupList.txt" "$ConfigFolder\BackupList.txt"
	}
}



Function InstallScript {
	If ($PSScriptRoot -eq "$InstallLocation") {
		Write-Host "`nPowerShell-Backup files are already installed."
		PauseScript
	}
	Else {
		$MenuOption = Read-Host "`nInstall PowerShell-Backup to ""$InstallLocation""? [y/n]"
		
		If ($MenuOption -like "y" -or $MenuOption -like "yes") {
			Write-Host "`nInstalling to ""$InstallLocation"" ..."

			$Script:RootFolder = $InstallLocation
			ScriptInitialization
			
			If ((Test-Path "$StartFolder") -eq $False) {
				New-Item -Type Directory -Path "$StartFolder" | Out-Null
			}

			Download7Zip

			Copy-Item "$PSScriptRoot\backup.ps1" -Destination "$RootFolder"
			
			DownloadFile "https://github.com/mpb10/PowerShell-Backup/raw/version-2.0.0/install/files/PowerShell-Backup.lnk" "$RootFolder\PowerShell-Backup.lnk"
			Copy-Item "$RootFolder\PowerShell-Backup.lnk" -Destination "$DesktopFolder\PowerShell-Backup.lnk"
			Copy-Item "$RootFolder\PowerShell-Backup.lnk" -Destination "$StartFolder\PowerShell-Backup.lnk"
			DownloadFile "https://github.com/mpb10/PowerShell-Backup/raw/version-2.0.0/LICENSE" "$RootFolder\LICENSE.txt"
			DownloadFile "https://github.com/mpb10/PowerShell-Backup/raw/version-2.0.0/README.md" "$RootFolder\README.md"

			Write-Host "`nInstallation complete. Please restart the script." -ForegroundColor "Yellow"
			PauseScript
			Exit
		}
	}
}



Function UpdateScript {
	DownloadFile "https://github.com/mpb10/PowerShell-Backup/raw/version-2.0.0/install/files/version-file" "$TempFolder\version-file.txt"
	[Version]$NewestVersion = Get-Content "$TempFolder\version-file.txt" | Select -Index 0
	Remove-Item -Path "$TempFolder\version-file.txt"
	
	If ($NewestVersion -gt $RunningVersion) {
		Write-Host "`nA new version of PowerShell-Backup is available: v$NewestVersion" -ForegroundColor "Yellow"
		$MenuOption = Read-Host "`nUpdate to this version? [y/n]"
		
		If ($MenuOption -like "y" -or $MenuOption -like "yes") {
			DownloadFile "http://github.com/mpb10/PowerShell-Backup/raw/version-2.0.0/backup.ps1" "$RootFolder\backup.ps1"
			
			If ($PSScriptRoot -eq "$InstallLocation") {
				If ((Test-Path "$StartFolder") -eq $False) {
					New-Item -Type Directory -Path "$StartFolder" | Out-Null
				}
				
				DownloadFile "https://github.com/mpb10/PowerShell-Backup/raw/version-2.0.0/install/files/Youtube-dl.lnk" "$RootFolder\PowerShell-Backup.lnk"
				Copy-Item "$RootFolder\PowerShell-Backup.lnk" -Destination "$DesktopFolder\PowerShell-Backup.lnk"
				Copy-Item "$RootFolder\PowerShell-Backup.lnk" -Destination "$StartFolder\PowerShell-Backup.lnk"
				DownloadFile "https://github.com/mpb10/PowerShell-Backup/raw/version-2.0.0/LICENSE" "$RootFolder\LICENSE.txt"
				DownloadFile "https://github.com/mpb10/PowerShell-Backup/raw/version-2.0.0/README.md" "$RootFolder\README.md"
			}
			
			DownloadFile "https://github.com/mpb10/PowerShell-Backup/raw/version-2.0.0/install/files/UpdateNotes.txt" "$TempFolder\UpdateNotes.txt"
			Get-Content "$TempFolder\UpdateNotes.txt"
			Remove-Item "$TempFolder\UpdateNotes.txt"
			
			Write-Host "`nUpdate complete. Please restart the script." -ForegroundColor "Yellow"
			
			PauseScript
			Exit
		}
	}
	ElseIf ($NewestVersion -eq $RunningVersion) {
		Write-Host "`nThe running version of PowerShell-Backup is up-to-date." -ForegroundColor "Yellow"
	}
	Else {
		Write-Host "`n[ERROR] Script version mismatch. Re-installing the script is recommended." -ForegroundColor "Red" -BackgroundColor "Black"
		PauseScript
	}
}



Function BackupFolder {
	Param (
		[Parameter(Mandatory)]
		[String]$Input,
		[Parameter(Mandatory)]
		[String]$Output
	)
	
	If ((Test-Path "$Input" -PathType Container) -eq $False) {
		Write-Host "`n[ERROR] Provided input path does not exist or is not a folder." -ForegroundColor "Red" -BackgroundColor "Black"
		PauseScript
		Return
	}
	
	If ((Test-Path "$Output" -PathType Container) -eq $False) {
		Write-Host "`n[WARNING] The provided output folder of ""$Output"" does not exist."
		$MenuOption = Read-Host "          Create this folder? [y/n]"
		
		If ($MenuOption -like "y" -or $MenuOption -like "yes") {
			New-Item -Type Directory -Path "$Output" | Out-Null
		}
		Else {
			Write-Host "`n[ERROR] No valid output folder was provided." -ForegroundColor "Red" -BackgroundColor "Black"
			PauseScript
			Return
		}
	}
	
	$InputBottom = $Input.Replace(" ", "_") | Split-Path -Leaf
	
	If (($OutputFormat.Trim()) -like "*7z") {
		$FileFormat = ".7z"
	}
	ElseIf (($OutputFormat.Trim()) -like "*gzip") {
		$FileFormat = ".gzip"
	}
	ElseIf (($OutputFormat.Trim()) -like "*tar") {
		$FileFormat = ".tar"
	}
	Else {
		$FileFormat = ".zip"
	}
	
	Write-Host "`nCompressing folder: ""$Input""`nCompressing to:     ""$Output""`n"
	
	$7zipCommand = "7z a ""$Output\$InputBottom_$CurrentDate$FileFormat"" ""$Input\*"""
	Invoke-Expression "$7zipCommand"
}



Function BackupFromFile {
	Param (
		[Parameter(Mandatory)]
		[String]$Input
	)
	
}



Function CommandLineMode {
	If ($Install -eq $True) {
		InstallScript
		Exit
	}
	ElseIf ($UpdateScript -eq $True) {
		UpdateScript
		Exit
	}
	
	If (($OutputPath.Length) -gt 0 -and (Test-Path "$OutputPath") -eq $False) {
		New-Item -Type directory -Path "$OutputPath" | Out-Null
	}
	
	If ($BackupList -eq $True -and ($OutputPath.Length) -gt 0) {
		Write-Host "`n[ERROR]: The parameter -BackupList can't be used with -InputPath or -OutputPath.`n" -ForegroundColor "Red" -BackgroundColor "Black"
	}
	ElseIf ($BackupList -eq $True -and ($InputPath.Length) -gt 0) {
		BackupFromFile "$InputPath"
		Write-Host "`nBackups complete." -ForegroundColor "Yellow"
	}
	ElseIf ($BackupList -eq $True) {
		BackupFromFile "$BackupListFile"
		Write-Host "`nBackups complete." -ForegroundColor "Yellow"
	}
	ElseIf (($InputPath.Length) -gt 0 -and ($OutputPath.Length) -gt 0) {
		BackupFolder "$InputPath" "$OutputPath"
		Write-Host "`nBackup complete. Backed up to: ""$OutputPath""" -ForegroundColor "Yellow"
	}
	ElseIf (($InputPath.Length) -gt 0) {
		BackupFolder "$InputPath" "$PSScriptRoot"
		Write-Host "`nBackup complete. Backed up to: ""$PSScriptRoot""" -ForegroundColor "Yellow"
	}
	Else {
		Write-Host "`n[ERROR]: Invalid parameters provided." -ForegroundColor "Red" -BackgroundColor "Black"
	}
	
	Exit
}



Function MainMenu {
	
}



Function SettingsMenu {
	
}


# ======================================================================================================= #
# ======================================================================================================= #
#
# MAIN
#
# ======================================================================================================= #

If ($PSVersionTable.PSVersion.Major -lt 5) {
	Write-Host "[ERROR]: Your PowerShell installation is not version 5.0 or greater.`n        This script requires PowerShell version 5.0 or greater to function.`n        You can download PowerShell version 5.0 at:`n            https://www.microsoft.com/en-us/download/details.aspx?id=50395" -ForegroundColor "Red" -BackgroundColor "Black"
	PauseScript
	Exit
}

If ($PSScriptRoot -eq "$InstallLocation") {
	$RootFolder = $InstallLocation
}
Else {
	$RootFolder = "$PSScriptRoot"
}

If ($Install -eq $False) {
	ScriptInitialization
}

If ($CheckForUpdates -eq $True -and $Install -eq $False) {
	UpdateScript
}

If ((Test-Path "$BinFolder\7za.exe") -eq $False -and $Install -eq $False) {
	Write-Host "`n7-Zip .exe not found. Downloading and installing to: ""$BinFolder"" ...`n" -ForegroundColor "Yellow"
	Download7Zip
}

If (($PSBoundParameters.Count) -gt 0) {
	CommandLineMode
}
Else {
	MainMenu
}


Write-Host "End of Script"
PauseScript


# ======================================================================================================= #
# ======================================================================================================= #






