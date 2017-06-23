
Function PauseScript {
	Write-Host "Press any key to continue ..." -ForegroundColor "Gray"
	$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

Write-Host "Beginning Backup Script installation ..." -ForegroundColor "Yellow"

Write-Host "Creating install folders ..."

$SettingsFolder = $ENV:USERPROFILE + "\Backup Script"
$FolderCheck = Test-Path $SettingsFolder
If ($FolderCheck -eq $False) {
	New-Item -Type Directory -Path "$SettingsFolder"
}

$ScriptsFolder = $ENV:USERPROFILE + "\Backup Script\scripts"
$FolderCheck = Test-Path $ScriptsFolder
If ($FolderCheck -eq $False) {
	New-Item -Type Directory -Path "$ScriptsFolder"
}

$StartFolder = $ENV:APPDATA + "\Microsoft\Windows\Start Menu\Programs\Backup Script"
$FolderCheck = Test-Path $StartFolder
If ($FolderCheck -eq $False) {
	New-Item -Type Directory -Path "$StartFolder"
}

$DesktopFolder = $ENV:USERPROFILE + "\Desktop"

Function Check7Zip {
	Write-Host "Checking 7-Zip installation ..."
	$CheckInstallx64 = Get-ChildItem HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall | ForEach-Object {Get-ItemProperty $_.pspath} | Where-Object {$_.DisplayName -like "*7-Zip*"} | ForEach-Object {$_.DisplayName}
	$CheckInstallx86 = Get-ChildItem HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall | ForEach-Object {Get-ItemProperty $_.pspath} | Where-Object {$_.DisplayName -like "*7-Zip*"} | ForEach-Object {$_.DisplayName}
	If ($CheckInstallx64 -like "*7-Zip*" -or $CheckInstallx86 -like "*7-Zip*") {
		Write-Host "7-Zip is properly installed."
	}
	Else {
		Write-Host "7-zip is not installed according to the registry.`nDownloading 7-zip now. Please install to: C:\Program Files\7-Zip"
		If (([environment]::Is64BitOperatingSystem) -eq $True) {
			$URL = "http://www.7-zip.org/a/7z1604-x64.exe"
			$Output = $ENV:USERPROFILE + "\Backup Script\7z1604-x64.exe"
		}
		Else {
			$URL = "http://www.7-zip.org/a/7z1604.exe"
			$Output = $ENV:USERPROFILE + "\Backup Script\7z1604-x86.exe"
		}
		(New-Object System.Net.WebClient).DownloadFile($URL, $Output)
		Invoke-Expression "& $Output"
		Remove-Item -Path "$Output"
	}
}

Write-Host "Checking PowerShell version ..."

If ($PSVersionTable.PSVersion.Major -lt 5) {
	Write-Host "[NOTE]: Your PowerShell installation is not the most recent version." -ForegroundColor "Red" -BackgroundColor "Black"
	Write-Host "        You can download PowerShell version 5 at:" -ForegroundColor "Red" -BackgroundColor "Black"
	Write-Host "            https://www.microsoft.com/en-us/download/details.aspx?id=50395" -ForegroundColor "Gray" -BackgroundColor "Black"
}
Else {
	Write-Host "PowerShell is up to date."
}

Check7Zip

Write-Host "Copying install files ..."

Copy-Item ".\scripts\backup.ps1" -Destination "$ScriptsFolder"
Copy-Item ".\scripts\Backup Script.lnk" -Destination "$ScriptsFolder"
Copy-Item ".\scripts\Backup Script.lnk" -Destination "$DesktopFolder"
Copy-Item ".\scripts\Backup Script.lnk" -Destination "$StartFolder"
Copy-Item ".\README.md" -Destination "$SettingsFolder"

Write-Host "`nInstallation complete.`n" -ForegroundColor "Yellow"

PauseScript

Exit
