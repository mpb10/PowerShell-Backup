
Function PauseScript {
	Write-Host "`nPress any key to continue ...`n" -ForegroundColor "Gray"
	$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp")
}

Write-Host "Beginning Backup Script installation ..." -ForegroundColor "Yellow"

Write-Verbose "Creating install folders ..."

$SettingsFolder = $ENV:USERPROFILE + "\Backup Script"
If ((Test-Path "$SettingsFolder") -eq $False) {
	New-Item -Type Directory -Path "$SettingsFolder"
}

$ScriptsFolder = $ENV:USERPROFILE + "\Backup Script\scripts"
If ((Test-Path "$ScriptsFolder") -eq $False) {
	New-Item -Type Directory -Path "$ScriptsFolder"
}

$StartFolder = $ENV:APPDATA + "\Microsoft\Windows\Start Menu\Programs\Backup Script"
If ((Test-Path "StartFolder") -eq $False) {
	New-Item -Type Directory -Path "$StartFolder"
}

$DesktopFolder = $ENV:USERPROFILE + "\Desktop"

Function Check7Zip {
	Write-Verbose "Checking 7-Zip installation ..."
	$CheckInstallx64 = Get-ChildItem HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall | ForEach-Object {Get-ItemProperty $_.pspath} | Where-Object {$_.DisplayName -like "*7-Zip*"} | ForEach-Object {$_.DisplayName}
	$CheckInstallx86 = Get-ChildItem HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall | ForEach-Object {Get-ItemProperty $_.pspath} | Where-Object {$_.DisplayName -like "*7-Zip*"} | ForEach-Object {$_.DisplayName}
	If ($CheckInstallx64 -like "*7-Zip*" -or $CheckInstallx86 -like "*7-Zip*") {
		Write-Verbose "7-Zip is properly installed."
	}
	Else {
		$MenuOption = 99
		While ($MenuOption -ne 1 -and $MenuOption -ne 2) {
			Write-Host "7-zip is not installed according to the registry.`n" -ForegroundColor "Red"
			Write-Host "Would you like to download and install it now? If you already have it installed, you can`nspecify the install location in the settings.txt file after this script is finished.`n"
			Write-Host "  1   - Download and install 7-zip"
			Write-Host "  2   - Skip 7-zip installation"
			Write-Host "            (NOTE: The script will not function without 7-zip.)`n" -ForegroundColor "Gray"
			$MenuOption = Read-Host "Option"
			
			If ($MenuOption -eq 1) {
				Write-Host "`nDownloading 7-zip now. Please install to: C:\Program Files\7-Zip"
				If (([environment]::Is64BitOperatingSystem) -eq $True) {
					$URL = "http://www.7-zip.org/a/7z1604-x64.exe"
					$Output = $ENV:USERPROFILE + "\Backup Script\7z1604-x64.exe"
				}
				Else {
					$URL = "http://www.7-zip.org/a/7z1604.exe"
					$Output = $ENV:USERPROFILE + "\Backup Script\7z1604-x86.exe"
				}
				(New-Object System.Net.WebClient).DownloadFile($URL, $Output)
				Start-Process "$Output" -Wait
				Remove-Item "$Output"
			}
			ElseIf ($MenuOption -eq 2) {
				Return
			}
		}
	}
}

Write-Verbose "Checking PowerShell version ..."

If ($PSVersionTable.PSVersion.Major -lt 5) {
	Write-Host "[NOTE]: Your PowerShell installation is not the most recent version." -ForegroundColor "Red"
	Write-Host "        It's recommended that you have PowerShell version 5 to use this script." -ForegroundColor "Red"
	Write-Host "        You can download PowerShell version 5 at:" -ForegroundColor "Red"
	Write-Host "            https://www.microsoft.com/en-us/download/details.aspx?id=50395" -ForegroundColor "Gray"
}
Else {
	Write-Verbose "PowerShell is up to date."
}

Write-Verbose "Copying install files ..."

Copy-Item ".\scripts\backup.ps1" -Destination "$ScriptsFolder"
Copy-Item ".\scripts\Backup Script.lnk" -Destination "$ScriptsFolder"
Copy-Item ".\scripts\Backup Script.lnk" -Destination "$DesktopFolder"
Copy-Item ".\scripts\Backup Script.lnk" -Destination "$StartFolder"
Copy-Item ".\settings.txt" -Destination "$SettingsFolder"
Copy-Item ".\README.md" -Destination "$SettingsFolder"
Copy-Item ".\LICENSE" -Destination "$SettingsFolder"

Check7Zip

Write-Host "`nInstallation complete." -ForegroundColor "Yellow"

PauseScript

Exit
