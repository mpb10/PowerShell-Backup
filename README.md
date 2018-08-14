# PowerShell-Backup-Script
https://github.com/mpb10/PowerShell-Backup-Script

A PowerShell script used to back up files and folders.


**Author: mpb10**

**August 13th, 2018**

**v2.0.0**

#

 - [INSTALLATION](#installation)
 - [USAGE](#usage)
 - [CHANGE LOG](#change-log)
 - [ADDITIONAL NOTES](#additional-notes)
 
#

# INSTALLATION

**Script download link:** https://github.com/mpb10/PowerShell-Backup/releases/download/v2.0.0/PowerShell-Backup-v2.0.0.zip

**Requires:** PowerShell 5.0 or greater*

	*Version 5.0 of PowerShell comes pre-installed with Windows 10 but otherwise can be downloaded here: https://www.microsoft.com/en-us/download/details.aspx?id=50395

#

**To Install:** 

1. Ensure that you have PowerShell Version 5.0 or greater installed.
2. Download the release .zip file and extract it to a folder.
3. Run the 'Installer' shortcut located in the `\install` folder (or run the the script using the 'PowerShell-Backup - Portable Version' shortcut, navigate to the settings menu, and choose the `2 -  Install script to:` option).

A desktop shortcut and a Start Menu shortcut will be created. Run either of those to use the script. The install location is `C:\Users\%USERNAME%\Scripts\PowerShell-Backup`.

#

To uninstall this script and its files, delete the two folders `C:\Users\%USERNAME%\Scripts\PowerShell-Backup` and `%APPDATA%\Microsoft\Windows\Start Menu\Programs\PowerShell-Backup` and the desktop shortcut.

# USAGE

Run either the desktop shortcut or the Start Menu shortcut. Use option 1 of the main menu to backup a single folder. Use option 2 and the `Backuplist.txt` file to backup multiple folders at once in a batch job.

Upon being ran for the first time, the script will generate the `BackupList.txt` file in the `\config` folder. To use option `2  - Backup from list` of the main menu, list folder paths under their respective stanzas in the `BackupList.txt` file, save it, and then run option 2 of the script.

# CHANGE LOG

	2.0.0	August 13th, 2018
		Re-wrote the script in the likeness of PowerShell-Youtube-dl. Cleaned up code.
		Can backup individual folders or use the BackupList.txt file to run batch jobs.
		Implemented some logging to the temp folder.

	1.1.1 	June 23rd, 2017
		Uploaded to Github.
		Condensed installer to one PowerShell script.
		Edited documentation.

	1.1.0	June 12th, 2017
		Added ability to back up folders listed in backuplist.txt.
		
# ADDITIONAL NOTES

**NOTE:** This script utilizes 7-zip command line version 9.20 executable file. This version of 7-zip has been identified as being vulnerable to multiple code execution exploits via crafted archive files. Since the executable is only used to create archives, the danger these vulnerabilities pose are negligable as long as the 7-zip executable is only used by the script to create archives. This version of 7-zip is only used because of its ability to be easily downloaded and installed. To easily mitigate the vulnerabilities found in version 9.20, simply download 7-zip version 18.05 or higher, copy the file `7z.exe` to the `\bin` directory, and rename the executable to `7za.exe`.

This script uses the 7-Zip program to compress folders for backing up. 7-Zip is licensed under the GNU LGPL license and its source code can be found at https://www.7-zip.org/.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
