<#
.SYNOPSIS 
	Automates the process of creating .zip backup files of user specified folders.
	
.DESCRIPTION 
	This script uses the 7-zip archive utility to create .zip archive files of user specified folders. This script can be ran via the command line using parameters, or it can be ran without parameters to use its GUI.
	
.PARAMETER InputPath 
	Specify the folder that is to be backed up.
.PARAMETER OutputPath 
	Specify the folder to which the backup will be saved.
.PARAMETER OutputFormat
	Specify the archive file format to compress the backup to. Supported formats are .7z, .gzip, .tar, and .zip. The default is .zip
.PARAMETER BackupList
	Backup folders listed in the backuplist.txt file.
.PARAMETER Install
	Install the script to "C:\Users\%USERNAME%\Scripts\PowerShell-Backup" and create desktop and Start Menu shortcuts.
.PARAMETER UpdateScript
	Update the backup.ps1 script file to the most recent version.

.EXAMPLE
	C:\Users\%USERNAME%\Scripts\Backup-Script\scripts\backup.ps1
	Runs the script in GUI mode.
.EXAMPLE
	C:\Users\%USERNAME%\Scripts\Backup-Script\scripts\backup.ps1 -InputPath "C:\Users\mpb10\Documents" -OutputPath "E:\Backups" -OutputFormat ".7z"
	Backups the Documents folder to "E:\Backups" compressed to the .7z format.
.EXAMPLE
	C:\Users\%USERNAME%\Scripts\Backup-Script\scripts\backup.ps1 -BackupList
	Backs up the folders listed in "C:\Users\%USERNAME%\Scripts\PowerShell-Backup\config\BackupList.txt"
.EXAMPLE
	C:\Users\%USERNAME%\Scripts\Backup-Script\scripts\backup.ps1 -BackupList -InputPath "C:\TestFolder\BackupList.txt"
	Backs up the folders listed in "C:\TestFolder\BackupList.txt".
.EXAMPLE
	C:\Users\%USERNAME%\Scripts\Backup-Script\scripts\backup.ps1 -Install
	Installs the script to "C:\Users\%USERNAME%\Scripts\PowerShell-Backup" and creates desktop and Start Menu shortcuts.
.EXAMPLE
	C:\Users\%USERNAME%\Scripts\Backup-Script\scripts\backup.ps1 -UpdateScript
	Updates the backup.ps1 script file to the most recent version.

.NOTES
	Requires PowerShell version 5.0 or greater.
	Author: mpb10
	Updated: May 16th, 2018
	Version: 2.0.0
.LINK 
	https://github.com/mpb10/PowerShell-Backup
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
$Verbose7Zip = $False




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
$BackupFolderStatus = $True
$BackupFromFileStatus = $True



# ======================================================================================================= #
# ======================================================================================================= #
#
# FUNCTIONS
#
# ======================================================================================================= #

# Function for simulating the 'pause' command of the Windows command line.
Function PauseScript {
	If ($PSBoundParameters.Count -eq 0) {
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
		
		If ($MenuOption.Trim() -like "y" -or $MenuOption.Trim() -like "yes") {
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
		
		If ($MenuOption.Trim() -like "y" -or $MenuOption.Trim() -like "yes") {
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
		[String]$InputFolder,
		[Parameter(Mandatory)]
		[String]$OutputFolder
	)
	$Script:BackupFolderStatus = $True
	
	If ((Test-Path "$InputFolder" -PathType Container) -eq $False) {
		Write-Host "`n[ERROR] Provided input path does not exist or is not a folder." -ForegroundColor "Red" -BackgroundColor "Black"
		$Script:BackupFolderStatus = $False
		Return
	}
	
	If ((Test-Path "$OutputFolder" -PathType Container) -eq $False) {
		Write-Host "`n[WARNING] The provided output folder of ""$OutputFolder"" does not exist."
		$MenuOption = Read-Host "          Create this folder? [y/n]"
		
		If ($MenuOption.Trim() -like "y" -or $MenuOption.Trim() -like "yes") {
			New-Item -Type Directory -Path "$OutputFolder" | Out-Null
		}
		Else {
			Write-Host "`n[ERROR] No valid output folder was provided." -ForegroundColor "Red" -BackgroundColor "Black"
			$Script:BackupFolderStatus = $False
			Return
		}
	}
	
	$InputFolderBottom = $InputFolder.Replace(" ", "_") | Split-Path -Leaf
	
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
	
	$OutputFileName = "$OutputFolder\$InputFolderBottom" + "_" + "$CurrentDate$FileFormat"
	
	$Counter = 0
	While ((Test-Path "$OutputFileName") -eq $True) {
		$Counter++
		$OutputFileName = "$OutputFolder\$InputFolderBottom" + "_" + "$CurrentDate ($Counter)$FileFormat"
	}	
	
	Write-Host "`nCompressing folder: ""$InputFolder""`nCompressing to:     ""$OutputFileName""" -ForegroundColor "Green"
	
	$7ZipCommand = "7za a ""$OutputFileName"" ""$InputFolder\*"""
	Write-Verbose "7-Zip command: $7zipCommand"
	
	If ($Verbose7Zip -eq $True) {
		Invoke-Expression "$7ZipCommand" | Tee-Object "$TempFolder\powershell-backup_log.log" -Append
	}
	Else {
		Invoke-Expression "$7ZipCommand" | Out-File "$TempFolder\powershell-backup_log.log" -Append
	}
	
	Write-Host "`nCompression to ""$OutputFileName"" complete." -ForegroundColor "Yellow"
}



Function BackupFromFile {
	Param (
		[Parameter(Mandatory)]
		[String]$InputFile
	)
	$Script:BackupFromFileStatus = $True
	
	If ((Test-Path "$InputFile") -eq $False) {
		Write-Host "`n[ERROR] Provided input file does not exist." -ForegroundColor "Red" -BackgroundColor "Black"
		$Script:BackupFromFileStatus = $False
		Return
	}
	
	$BackupListArray = Get-Content "$InputFile" | Where-Object {$_.Trim() -ne "" -and $_.Trim() -notlike "#*"}
	
	$BackupFromArray = $BackupListArray | Select-Object -Index (($BackupListArray.IndexOf("[Backup From]".Trim()))..($BackupListArray.IndexOf("[Backup To]".Trim())-1))
	$BackupToArray = $BackupListArray | Select-Object -Index (($BackupListArray.IndexOf("[Backup To]".Trim()))..($BackupListArray.Count - 1))
	
	If ($BackupToArray.Count -eq 1) {
		Write-Host "`n[ERROR] No output folder paths listed under '[Backup To]'." -ForegroundColor "Red" -BackgroundColor "Black"
		$Script:BackupFromFileStatus = $False
		Return
	}
	ElseIf ($BackupToArray.Count -gt 1) {
		$BackupToArray = @($BackupToArray | Where-Object {$_ -ne $BackupToArray[0]})
	}
	
	If ($BackupFromArray.Count -gt 1) {
		Write-Host "`nStarting batch job from file: ""$InputFile""" -ForegroundColor "Green"
		
		$BackupFromArray | Where-Object {$_ -ne $BackupFromArray[0]} | ForEach-Object {
			$Counter = 0
			While ($BackupToArray.Count -gt $Counter) {
				BackupFolder "$_" $BackupToArray[$Counter]
				$Counter++
			}
		}
	}
	Else {
		Write-Host "`n[ERROR] No input folder paths listed under '[Backup From]'." -ForegroundColor "Red" -BackgroundColor "Black"
		$Script:BackupFromFileStatus = $False
		Return
	}
	
	Write-Host "`nBatch job complete." -ForegroundColor "Yellow"
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
	
	If ($BackupList -eq $True -and ($OutputPath.Length) -gt 0) {
		Write-Host "`n[ERROR]: The parameter -BackupList can't be used with -OutputPath.`n" -ForegroundColor "Red" -BackgroundColor "Black"
	}
	ElseIf ($BackupList -eq $True -and ($InputPath.Length) -gt 0) {
		BackupFromFile "$InputPath"
		If ($BackupFromFileStatus -eq $True) {
			Write-Host "`nBackups complete.`n" -ForegroundColor "Yellow"
		}
	}
	ElseIf ($BackupList -eq $True) {
		BackupFromFile "$BackupListFile"
		If ($BackupFromFileStatus -eq $True) {
			Write-Host "`nBackups complete.`n" -ForegroundColor "Yellow"
		}
	}
	ElseIf (($InputPath.Length) -gt 0 -and ($OutputPath.Length) -gt 0) {
		BackupFolder "$InputPath" "$OutputPath"
		If ($BackupFolderStatus -eq $True) {
			Write-Host "`nBackup complete. Backed up to: ""$OutputPath""`n" -ForegroundColor "Yellow"
		}
	}
	ElseIf (($InputPath.Length) -gt 0) {
		BackupFolder "$InputPath" "$PSScriptRoot"
		If ($BackupFolderStatus -eq $True) {
			Write-Host "`nBackup complete. Backed up to: ""$PSScriptRoot""`n" -ForegroundColor "Yellow"
		}
	}
	Else {
		Write-Host "`n[ERROR]: Invalid parameters provided.`n" -ForegroundColor "Red" -BackgroundColor "Black"
	}
	
	Exit
}



Function MainMenu {
	$MenuOption = 99
	While ($MenuOption -ne 1 -and $MenuOption -ne 2 -and $MenuOption -ne 3 -and $MenuOption -ne 0) {
		$URL = ""
		Clear-Host
		Write-Host "==================================================================================================="
		Write-Host "                                PowerShell-Backup v$RunningVersion                                 " -ForegroundColor "Yellow"
		Write-Host "==================================================================================================="
		Write-Host "`nPlease select an option:`n" -ForegroundColor "Yellow"
		Write-Host "  1   - Backup specific folder"
		Write-Host "  2   - Backup from list"
		Write-Host "  3   - Settings"
		Write-Host "`n  0   - Exit`n" -ForegroundColor "Gray"
		$MenuOption = Read-Host "Option"
		
		Write-Host "`n==================================================================================================="
		
		Switch ($MenuOption) {
			1 {
				Write-Host "`nPlease enter the full path of the folder you wish to backup:`n" -ForegroundColor "Yellow"
				$InputPath = (Read-Host "Input Path").Trim()
				Write-Host "`n---------------------------------------------------------------------------------------------------"
				Write-Host "`nPlease enter the full path of the location you wish to save the backup:`n" -ForegroundColor "Yellow"
				$OutputPath = (Read-Host "Output Path").Trim()
				Write-Host "`n---------------------------------------------------------------------------------------------------"
				Write-Host "`n[Optional] Enter the archive file format you wish to compress the backup to:`n"
				$OutputFormat = (Read-Host "File Format").Trim()
				Write-Host "`n---------------------------------------------------------------------------------------------------"
				
				BackupFolder "$InputPath" "$OutputPath"
				
				PauseScript
				$MenuOption = 99
			}
			2 {
				BackupFromFile "$BackupListFile"
				
				PauseScript
				$MenuOption = 99
			}
			3 {
				SettingsMenu
				
				$MenuOption = 99
			}
			0 {
				Clear-Host
				Exit
			}
			Default {
				Write-Host "`nPlease enter a valid option." -ForegroundColor "Red"
				PauseScript
			}
		}
	}
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

If ((Test-Path "$TempFolder\powershell-backup_log.log") -eq $True) {
	If ((Get-ChildItem "$TempFolder\powershell-backup_log.log").Length -gt 25000000) {
		Remove-Item -Path "$TempFolder\powershell-backup_log.log"
	}
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
Exit


# ======================================================================================================= #
# ======================================================================================================= #






