

Param(
	[String]$InputPath,
	[String]$OutputPath,
	[String]$BackupList
)

Function PauseScript {
	Write-Host "Press any key to continue ..." -ForegroundColor "Gray"
	$x = $HOST.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

$Check7ZipInstallX64 = Test-Path "C:\Program Files\7-Zip\7z.exe"
$Check7ZipInstallX86 = Test-Path "C:\Program Files (x86)\7-Zip\7z.exe"
If ($Check7ZipInstallX64 -eq $False -and $Check7ZipInstallX86 -eq $False -and (! (Get-Command 7z.exe -ErrorAction SilentlyContinue))) {
	Write-Host "[ERROR]: 7-Zip is not installed to: ""C:\Program Files\7-Zip""" -ForegroundColor "Red" -BackgroundColor "Black"
	Write-Host "         Install 7-Zip to the correct location and run again.`n" -ForegroundColor "Red" -BackgroundColor "Black"
	PauseScript
	Exit
}
Else {
	$BinFolderX64 = "C:\Program Files\7-Zip"
	$ENV:Path += ";$BinFolderX64"
	$BinFolderX86 = "C:\Program Files (x86)\7-Zip"
	$ENV:Path += ";$BinFolderX86"
}

$SettingsFolder = $ENV:USERPROFILE + "\Backup Script"
$SettingsFolderCheck = Test-Path $SettingsFolder
If ($SettingsFolderCheck -eq $False) {
	New-Item -Type directory -Path $SettingsFolder
}

$TextFilePath = $SettingsFolder + "\backuplist.txt"
$TextFilePathCheck = Test-Path $TextFilePath
If ($TextFilePathCheck -eq $False) {
	New-Item -Type file -Path $TextFilePath
}

If ($PSBoundParameters.Count -gt 0) {
	$ParameterMode = $True
	$ZipFileName = ""
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
}

Function MainMenu {
	$MenuOption = 99
	While ($MenuOption -ne 1 -and $MenuOption -ne 0) {
		Clear-Host
		Write-Host "================================================================"
		Write-Host "                       Backup Script v1.1                       " -ForegroundColor "Yellow"
		Write-Host "================================================================"
		Write-Host ""
		Write-Host "Please select an option:" -ForegroundColor "Yellow"
		Write-Host ""
		Write-Host "  1   - Set variables and begin backup process"
		Write-Host "  2   - Backup folders listed in backuplist.txt"
		Write-Host ""
		Write-Host "  0   - Exit" -ForegroundColor "Gray"
		Write-Host ""
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
			Write-Host "Please enter a valid option" -ForegroundColor "Red" -BackgroundColor "Black"
			Write-Host ""
			PauseScript
		}
	}
}

Function BackupProcess {
	$MenuOption = 99
	While ($MenuOption -ne 1 -and $MenuOption -ne 2 -and $MenuOption -ne 3 -and $MenuOption -ne 9 -and $MenuOption -ne 0) {
		Clear-Host
		Write-Host "================================================================"
		Write-Host "                         Backup Process                         " -ForegroundColor "Yellow"
		Write-Host "================================================================"
		Write-Host ""
		Write-Host "Please select a varible to edit using its corresponding ID:" -ForegroundColor "Yellow"
		Write-Host ""
		Write-Host ($Settings | Format-Table ID,SettingName,BlankCol,SettingValue | Out-String)
		Write-Host "  9   - Begin backup process"
		Write-Host ""
		Write-Host "  0   - Return" -ForegroundColor "Gray"
		Write-Host ""
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
			Write-Host "Enter the full path of the folder to save the backup in:`n" -ForegroundColor "Yellow"
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
			$DateVar = Get-Date -UFormat "%m-%d-%Y_%H.%M"
			$Script:ZipFileName = $ZipFileName + "_$DateVar.zip"
			$ZipFileNameObj.SettingValue = $ZipFileName
			$MenuOption = 99
		}
		ElseIf ($MenuOption -eq 9) {
			CompressBackup
			EndMenu
		}
		ElseIf ($MenuOption -eq 0) {
			Return
		}
		Else {
			Write-Host "Please enter a valid option" -ForegroundColor "Red" -BackgroundColor "Black"
			Write-Host ""
			PauseScript
		}
	}
}

Function BackupFromList {
	$TextFile = Get-Content $TextFilePath
	$Script:OutputPath = $TextFile[0]
	If ($OutputPath -like "*\"){
		$Script:OutputPath = $OutputPath.Substring(0, $OutputPath.Length - 1)
	}
	If ($ParameterMode -eq $False) {
		$MenuOption = 99
		While ($MenuOption -ne 1 -and $MenuOption -ne 2) {
			Clear-Host
			Write-Host "Backing up folders listed in:  ""$TextFilePath""" -ForegroundColor "Yellow"
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
				Write-Host "Finished backing up folders listed in: ""$TextFilePath""`n" -ForegroundColor "Yellow"
				EndMenu
			}
			ElseIf ($MenuOption -eq 2) {
				$Script:OutputPath = "E:\Backups"
				Return
			}
			Else {
				Write-Host "Please enter a valid option" -ForegroundColor "Red" -BackgroundColor "Black"
				Write-Host ""
				PauseScript
			}
		}
	}
	Else {
		Write-Host "Backing up folders listed in: ""$TextFilePath""" -ForegroundColor "Yellow"
		Write-Host "Backing up to:                ""$OutputPath""`n" -ForegroundColor "Yellow"
		$TextFile = $TextFile | Where-Object {$_ -ne $TextFile[0]}
		$TextFile | ForEach-Object {
			$Script:InputPath = $_
			$DateVar = Get-Date -UFormat "%m-%d-%Y_%H.%M"
			$Script:ZipFileName = $InputPath.Substring($InputPath.LastIndexOf('\') + 1) + "_$DateVar.zip"
			CompressBackup
		}
		Write-Host "Finished backing up folders listed in: ""$TextFilePath""`n" -ForegroundColor "Yellow"
	}
}

Function EndMenu {
	If ($ParameterMode -eq $True) {
		Exit
	}
	Else {
		$MessageCommand = "cscript ""$SettingsFolder\scripts\MessageBox.vbs"" ""Finished backup."""
		Invoke-Expression $MessageCommand
		$MenuOption = 99
		While ($MenuOption -ne 1 -and $MenuOption -ne 2) {
			Write-Host "================================================================" -BackgroundColor "Black"
			Write-Host "                        Script Complete                         " -ForegroundColor "Yellow" -BackgroundColor "Black"
			Write-Host "================================================================" -BackgroundColor "Black"
			Write-Host ""
			Write-Host "Please select an option: " -ForegroundColor "Yellow"
			Write-Host ""
			Write-Host "  1   - Run again"
			Write-Host "  2   - Exit"
			Write-Host ""
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

Function CompressBackup {
	Write-Host "Compressing backup to: ""$OutputPath\$ZipFileName""" -ForegroundColor "Yellow"
	$7zipCommand = "7z a ""$OutputPath" + "\$ZipFileName"" ""$InputPath" + "\*"""
	Invoke-Expression $7zipCommand
	Write-Host "`nFinished compressing backup to: ""$OutputPath\$ZipFileName""`n" -ForegroundColor "Yellow"
}

If ($ParameterMode -eq $True) {
	If ($BackupList -gt 0) {
		$Script:TextFilePath = $BackupList
		BackupFromList
	}
	Else {
		If ($InputPath.Length -eq 0) {
			$Script:InputPath = $ENV:USERPROFILE + "\Documents"
			$DateVar = Get-Date -UFormat "%m-%d-%Y_%H.%M"
			$Script:ZipFileName = "Documents_$DateVar.zip"
			Write-Host "-InputPath parameter not provided. Backing up from: ""$InputPath""" -ForegroundColor "Yellow"
		}
		Else {
			If ($InputPath -like "*\") {
				$Script:InputPath = $InputPath.Substring(0, $InputPath.Length - 1)
			}
			$DateVar = Get-Date -UFormat "%m-%d-%Y_%H.%M"
			$Script:ZipFileName = $InputPath.Substring($InputPath.LastIndexOf('\') + 1) + "_$DateVar.zip"
		}
		If ($OutputPath.Length -eq 0) {
			$Script:OutputPath = "E:\Backups"
			Write-Host "-OutputPath parameter not provided. Backing up to: ""$OutputPath""" -ForegroundColor "Yellow"
		}
		Else {
			If ($OutputPath -like "*\"){
				$Script:OutputPath = $OutputPath.Substring(0, $OutputPath.Length - 1)
			}
		}
		Write-Host ""
		CompressBackup
	}
}
Else {	
	MainMenu
}




