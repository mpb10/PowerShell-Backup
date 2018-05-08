<#PSScriptInfo 

.VERSION
	1.2.0 

.GUID  

.AUTHOR
	mpb10

.COMPANYNAME 

.COPYRIGHT 

.TAGS 

.LICENSEURI
	https://github.com/mpb10/PowerShell-Backup-Script/blob/master/LICENSE

.PROJECTURI
	https://github.com/mpb10/PowerShell-Backup-Script

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 
	http://www.7-zip.org/

.RELEASENOTES
	1.2.0	27-Nov-2017 - Updated and cleaned up code.
#>


# ======================================================================================================= #
# ======================================================================================================= #


<#
.SYNOPSIS 
	Automates the process of creating .zip backup files of user specified folders.
	
.DESCRIPTION 
	This script uses the 7-zip archive utility to create .zip archive files of user specified folders. This script can be ran via the command line using parameters, or it can be ran without parameters to use its GUI. See README.md for more information.
	
.PARAMETER InputPath 
	Specify the folder that is to be backed up.
.PARAMETER OutputPath 
	Specify the folder to which the backup will be saved.
.PARAMETER BackupList
	Backup folders listed in the backuplist.txt file. The first line is the folder to which the backups will be saved.

.EXAMPLE 
	C:\Users\%USERNAME%\Backup Script\scripts\backup.ps1
	Runs the script in GUI mode.
.EXAMPLE 
	C:\Users\%USERNAME%\Backup Script\scripts\backup.ps1 -InputPath "C:\Users\mpb10\Documents" -OutputPath "E:\Backups"
	Backups the user mpb10's Documents folder to "E:\Backups".
.EXAMPLE 
	C:\Users\%USERNAME%\Backup Script\scripts\backup.ps1 -BackupList
	Backs up the folders listed in "C:\Users\%USERNAME%\Backup Script\backuplist.txt" to the folder listed on the first line of the file.

.NOTES 
	Requires Windows 7 or higher 
	Author: mpb10
	Updated: November 27th, 2017
	Version: 1.2.0

.LINK 
	https://github.com/mpb10/PowerShell-Backup-Script
#>


# ======================================================================================================= #
# ======================================================================================================= #

# ======================================================================================================= #
# ======================================================================================================= #


# ======================================================================================================= #
# ======================================================================================================= #



Param(
	[String]$InputPath,
	[String]$OutputPath,
	[Switch]$BackupList
)



# ======================================================================================================= #
# ======================================================================================================= #



# Function for simulating the 'pause' command of the Windows command line.
Function PauseScript {
	Write-Host "`nPress any key to continue ...`n" -ForegroundColor "Gray"
	$Wait = $HOST.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp")
}



# ======================================================================================================= #
# ======================================================================================================= #


$SettingsFolder = $ENV:USERPROFILE + "\Backup Script"
$SettingsFolderCheck = Test-Path $SettingsFolder
If ((Test-Path "$SettingsFolder") -eq $False) {
	New-Item -Type directory -Path $SettingsFolder
}

$BackupListFile = $SettingsFolder + "\backuplist.txt"
$BackupListFileCheck = Test-Path $BackupListFile
If ((Test-Path "$BackupListFile") -eq $False) {
	New-Item -Type file -Path $BackupListFile
}


$7zipInstallLocation = Get-Content "$SettingsFolder\settings.txt" | Where-Object { $_.Trim() -like "7ZipInstallFolder*" }
$7ZipInstallLocation = ($7ZipInstallLocation.Substring($7ZipInstallLocation.IndexOf('=') + 1)).Trim()

$Check7ZipInstallSettings = Test-Path "$7ZipInstallLocation\7z.exe"
$Check7ZipInstallX64 = Test-Path "C:\Program Files\7-Zip\7z.exe"
$Check7ZipInstallX86 = Test-Path "C:\Program Files (x86)\7-Zip\7z.exe"
If ($Check7ZipInstallSettings -eq $False -and $Check7ZipInstallX64 -eq $False -and $Check7ZipInstallX86 -eq $False -and (! (Get-Command 7z.exe -ErrorAction SilentlyContinue))) {
	Write-Host "[ERROR]: Cannot find 7-Zip install location or 7z.exe" -ForegroundColor "Red"
	Write-Host "         Install 7-Zip or set the 7z.exe install location in the settings.txt file." -ForegroundColor "Red"
	PauseScript
	Exit
}
Else {
	$ENV:Path += ";C:\Program Files (x86)\7-Zip;C:\Program Files\7-Zip;$7ZipInstallLocation"
}



# ======================================================================================================= #
# ======================================================================================================= #



Function MainMenu {
	$MenuOption = 99
	While ($MenuOption -ne 1 -and $MenuOption -ne 0) {
		Clear-Host
		Write-Host "`n================================================================"
		Write-Host "                      Backup Script v1.2.0                      " -ForegroundColor "Yellow"
		Write-Host "================================================================"
		Write-Host "`nPlease select an option:`n" -ForegroundColor "Yellow"
		Write-Host "  1   - Set variables and begin backup process"
		Write-Host "  2   - Backup folders listed in backuplist.txt"
		Write-Host "`n  0   - Exit`n" -ForegroundColor "Gray"
		$MenuOption = Read-Host "Option"
		Write-Host ""
		If ($MenuOption -eq 1) {
			BackupProcess
			$MenuOption = 99
		}
		ElseIf ($MenuOption -eq 2) {
			BackupFromList
			$MenuOption = 99
		}
		ElseIf ($MenuOption -eq 0) {
			$HOST.UI.RawUI.BackgroundColor = $BackgroundColorBefore
			$HOST.UI.RawUI.ForegroundColor = $ForegroundColorBefore
			Clear-Host
			Exit
		}
		Else {
			Write-Host "`n[ERROR]: Provided parameter is not a valid URL.`n" -ForegroundColor "Red"
			PauseScript
		}
	}
}



# ======================================================================================================= #
# ======================================================================================================= #



Function BackupProcess {
	$MenuOption = 99
	While ($MenuOption -ne 1 -and $MenuOption -ne 2 -and $MenuOption -ne 3 -and $MenuOption -ne 9 -and $MenuOption -ne 0) {
		Clear-Host
		Write-Host "`n================================================================"
		Write-Host "                         Backup Process                         " -ForegroundColor "Yellow"
		Write-Host "================================================================"
		Write-Host "`nPlease select a varible to edit using its corresponding ID:`n" -ForegroundColor "Yellow"
		Write-Host ($Settings | Format-Table ID,SettingName,BlankCol,SettingValue | Out-String)
		Write-Host "  9   - Begin backup process"
		Write-Host "`n  0   - Return`n" -ForegroundColor "Gray"
		$MenuOption = Read-Host "Option"
		Write-Host ""
		
		If ($MenuOption -eq 1) {
			Write-Host "Enter the full path of the folder you wish to backup:`n" -ForegroundColor "Yellow"
			$Script:InputPath = Read-Host "Input path"
			If ($InputPath -like "*\") {
				$Script:InputPath = $InputPath.Substring(0, $InputPath.Length - 1)
			}
			
			$DateVar = Get-Date -UFormat "%m-%d-%Y_%H.%M"
			$Script:ZipFileName = $InputPath.Substring($InputPath.LastIndexOf('\') + 1) + "_$DateVar.zip"
			$InputPathObj.SettingValue = $InputPath
			$ZipFileNameObj.SettingValue = $ZipFileName
			$MenuOption = 99
		}
		ElseIf ($MenuOption -eq 2) {
			Write-Host "Enter the full path of the location to save the backup to:`n" -ForegroundColor "Yellow"
			$Script:OutputPath = Read-Host "Output path"
			If ($OutputPath -like "*\"){
				$Script:OutputPath = $OutputPath.Substring(0, $OutputPath.Length - 1)
			}
			
			$OutputPathObj.SettingValue = $OutputPath
			$MenuOption = 99
		}
		ElseIf ($MenuOption -eq 3) {
			Write-Host "Enter the compressed backup filename:`n" -ForegroundColor "Yellow"
			$Script:ZipFileName = Read-Host "Compressed backup filename"
			$ZipFileNameObj.SettingValue = $ZipFileName
			$MenuOption = 99
		}
		ElseIf ($MenuOption -eq 9) {
			CompressBackup
			EndMenu
			Return
		}
		ElseIf ($MenuOption -eq 0) {
			Return
		}
		Else {
			Write-Host "`n[ERROR]: Provided parameter is not a valid URL.`n" -ForegroundColor "Red"
			PauseScript
		}
	}
}



# ======================================================================================================= #
# ======================================================================================================= #



Function CompressBackup {
	Write-Host "Compressing backup to: ""$OutputPath\$ZipFileName""" -ForegroundColor "Yellow"
	$7zipCommand = "7z a ""$OutputPath" + "\$ZipFileName"" ""$InputPath" + "\*"""
	Invoke-Expression $7zipCommand
	Write-Host "`nFinished compressing backup to: ""$OutputPath\$ZipFileName""`n" -ForegroundColor "Yellow"
}



# ======================================================================================================= #
# ======================================================================================================= #



Function BackupFromList {
	$TextFile = Get-Content $BackupListFile
	$Script:OutputPath = ($TextFile[0]).Trim()
	If ($OutputPath -like "*\"){
		$Script:OutputPath = $OutputPath.Substring(0, $OutputPath.Length - 1)
	}
	
	If ($ParameterMode -eq $False) {
		$MenuOption = 99
		While ($MenuOption -ne 1 -and $MenuOption -ne 2) {
			Clear-Host
			Write-Host "Backing up folders listed in:  ""$BackupListFile""" -ForegroundColor "Yellow"
			Write-Host "Backing up to:  ""$OutputPath""`n" -ForegroundColor "Yellow"
			Write-Host "Is this correct?`n" -ForegroundColor "Yellow"
			Write-Host "  1   - Yes"
			Write-Host "  2   - No`n"
			$MenuOption = Read-Host "Option"
			Write-Host ""
			
			If ($MenuOption -eq 1) {
				$TextFile = $TextFile | Where-Object {$_ -ne $TextFile[0]}
				$TextFile | ForEach-Object {
					$Script:InputPath = $_
					$DateVar = Get-Date -UFormat "%m-%d-%Y_%H.%M"
					$Script:ZipFileName = $InputPath.Substring($InputPath.LastIndexOf('\') + 1) + "_$DateVar.zip"
					CompressBackup
				}
				Write-Host "Finished backing up folders listed in: ""$BackupListFile""`n" -ForegroundColor "Yellow"
				EndMenu
				Return
			}
			ElseIf ($MenuOption -eq 2) {
				$Script:OutputPath = "E:\Backups"
				Return
			}
			Else {
				Write-Host "`n[ERROR]: Provided parameter is not a valid URL.`n" -ForegroundColor "Red"
				PauseScript
			}
		}
	}
	Else {
		Write-Host "Backing up folders listed in: ""$BackupListFile""" -ForegroundColor "Yellow"
		Write-Host "Backing up to:                ""$OutputPath""`n" -ForegroundColor "Yellow"
		$TextFile = $TextFile | Where-Object {$_ -ne $TextFile[0]}
		$TextFile | ForEach-Object {
			$Script:InputPath = $_
			$DateVar = Get-Date -UFormat "%m-%d-%Y_%H.%M"
			$Script:ZipFileName = $InputPath.Substring($InputPath.LastIndexOf('\') + 1) + "_$DateVar.zip"
			CompressBackup
		}
		Write-Host "Finished backing up folders listed in: ""$BackupListFile""`n" -ForegroundColor "Yellow"
	}
}



# ======================================================================================================= #
# ======================================================================================================= #



Function EndMenu {
	Else {
		$MenuOption = 99
		While ($MenuOption -ne 1 -and $MenuOption -ne 2) {
			Write-Host "`n================================================================"
			Write-Host "                        Script Complete                         " -ForegroundColor "Yellow"
			Write-Host "================================================================"
			Write-Host "`nPlease select an option:`n" -ForegroundColor "Yellow"
			Write-Host "  1   - Run again"
			Write-Host "`n  0   - Exit`n"
			$MenuOption = Read-Host "Option"
			Write-Host ""
			If ($MenuOption -eq 1) {
				$Script:InputPath = $ENV:USERPROFILE + "\Documents"
				$Script:OutputPath = "E:\Backups"
				$Script:DateVar = Get-Date -UFormat "%m-%d-%Y_%H.%M"
				$Script:ZipFileName = "Documents_$DateVar.zip"
				
				$InputPathObj.SettingValue = $InputPath
				$OutputPathObj.SettingValue = $OutputPath
				$ZipFileNameObj.SettingValue = $ZipFileName
				
				Return
			}
			ElseIf ($MenuOption -eq 2) {
				$HOST.UI.RawUI.BackgroundColor = $BackgroundColorBefore
				$HOST.UI.RawUI.ForegroundColor = $ForegroundColorBefore
				Clear-Host
				Exit
			}
			Else {
				Write-Host "Please enter a valid option." -ForegroundColor "Red" -BackgroundColor "Black"
				Write-Host ""
				PauseScript
				Write-Host ""
			}
		}
	}
}



# ======================================================================================================= #
# ======================================================================================================= #


Function CommandLineMode {
	
	If ($BackupList -eq $True) {
		BackupFromList
	}
	Else {
		If ($InputPath.Length -gt 0) {
			If ($InputPath -like "*\") {
				$Script:InputPath = $InputPath.Substring(0, $InputPath.Length - 1)
			}
			
			$DateVar = Get-Date -UFormat "%m-%d-%Y_%H.%M"
			$Script:ZipFileName = $InputPath.Substring($InputPath.LastIndexOf('\') + 1) + "_$DateVar.zip"
		}
		Else {
			Write-Host "[ERROR] Input path not specified." -ForegroundColor "Red"
			Write-Host "        Please specify the folder to backup with: -InputPath <Folder Path>" -ForegroundColor "Red"
			PauseScript
			Exit
		}
		
		If ($OutputPath.Length -gt 0) {
			If ($OutputPath -like "*\"){
				$Script:OutputPath = $OutputPath.Substring(0, $OutputPath.Length - 1)
			}
			
			CompressBackup
		}
		Else {			
			Write-Host "[ERROR] Output path not specified." -ForegroundColor "Red"
			Write-Host "        Please specify the location to backup to: -OutputPath <Folder Path>" -ForegroundColor "Red"
			PauseScript
			Exit
		}
	}
}



# ======================================================================================================= #
# ======================================================================================================= #



If ($PSBoundParameters.Count -gt 0) {
	$ParameterMode = $True
}
Else {
	$ParameterMode = $False
	$InputPath = $ENV:USERPROFILE + "\Documents"
	$OutputPath = "E:\Backups"
	$DateVar = Get-Date -UFormat "%m-%d-%Y_%H.%M"
	$ZipFileName = "Documents_$DateVar.zip"
	
	$InputPathObj = New-Object Object
	$InputPathObj | Add-Member -Type NoteProperty -Name ID -Value 1
	$InputPathObj | Add-Member -Type NoteProperty -Name SettingName -Value "Input path"
	$InputPathObj | Add-Member -Type NoteProperty -Name BlankCol -Value ""
	$InputPathObj | Add-Member -Type NoteProperty -Name SettingValue -Value $InputPath
	
	$OutputPathObj = New-Object Object
	$OutputPathObj | Add-Member -Type NoteProperty -Name ID -Value 2
	$OutputPathObj | Add-Member -Type NoteProperty -Name SettingName -Value "Output path"
	$OutputPathObj | Add-Member -Type NoteProperty -Name BlankCol -Value ""
	$OutputPathObj | Add-Member -Type NoteProperty -Name SettingValue -Value $OutputPath
	
	$ZipFileNameObj = New-Object Object
	$ZipFileNameObj | Add-Member -Type NoteProperty -Name ID -Value 3
	$ZipFileNameObj | Add-Member -Type NoteProperty -Name SettingName -Value "Backup name"
	$ZipFileNameObj | Add-Member -Type NoteProperty -Name BlankCol -Value ""
	$ZipFileNameObj | Add-Member -Type NoteProperty -Name SettingValue -Value $ZipFileName
	
	$Settings = $InputPathObj,$OutputPathObj,$ZipFileNameObj
	
	$BackgroundColorBefore = $HOST.UI.RawUI.BackgroundColor
	$ForegroundColorBefore = $HOST.UI.RawUI.ForegroundColor
	$HOST.UI.RawUI.BackgroundColor = "Black"
	$HOST.UI.RawUI.ForegroundColor = "White"
	
	MainMenu
}

