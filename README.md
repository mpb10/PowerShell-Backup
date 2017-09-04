# PowerShell-Backup-Script
https://github.com/ForestFrog/PowerShell-Backup-Script

A PowerShell script used to backup files.


**Scripts written by ForestFrog**

**June 23th, 2017**

**v1.1.0**
#

 - [INSTALLATION](#installation)
 - [USAGE](#usage)
 - [CHANGE LOG](#change-log)
 - [ADDITIONAL NOTES](#additional-notes)
 
#

# INSTALLATION

**Script download link:** https://github.com/ForestFrog/PowerShell-Backup-Script/archive/master.zip

Note: This script requires Windows PowerShell and 7-Zip to function. PowerShell comes pre-installed with Windows 10 but otherwise can be downloaded here: https://www.microsoft.com/en-us/download/details.aspx?id=50395. 7-Zip can be downloaded here: http://www.7-zip.org/download.html

Make sure your ExecutionPolicy is properly set by opening a PowerShell window with administrator privileges and typing `Set-ExecutionPolicy RemoteSigned`.

**To Install:** Download the project .zip file, extract it to a folder, and run the `Backup_Installer.ps1` shortcut. The script will be installed to the folder `C:\Users\%USERNAME%\Backup Script`. A desktop shortcut and a Start Menu shortcut will be created. Run either of these to use the script. 

To update the script, delete the following folder, download the new version and install it:

	C:\Users\%USERNAME%\Backup Script\scripts
Make sure you don't delete any of the .txt files!

#

To uninstall this script, delete the Backup Script folders located at `C:\Users\%USERNAME%\Backup Script` and `%APPDATA%\Microsoft\Windows\Start Menu\Programs\Backup Script`, as well as the desktop shortcut.


# USAGE

Run either the desktop shortcut or the Start Menu shortcut. At the main menu, choose option `1` to select the folder to be backed up and the folder to which the backup is to be saved. By default the script will backup the user's `Documents` folder to `E:\Backups`. Make sure you choose the proper drive when backing up a folder. Alternatively, users can choose option `2` at the main menu to backup folders listed in the `backuplist.txt` file which is found at `C:\Users\%USERNAME%\Backup Script`.

#

**New in version 1.1.0**, users can save a list of folders to be backed up in the text file `C:\Users\%USERNAME%\Backup Script\backuplist.txt`. One line at a time, list the path of each folder that is to be backed up, with the first line being the path of where to save the backups. Once the `backuplist.txt` file is set, choose option 2 on the main menu. Confirm that the information is correct and then begin the process.

#

For advanced users, the `backup.ps1` script, which is found in the folder `C:\Users\%USERNAME%\Backup Script\scripts`, can be passed parameters so that this script can be used in conjunction with other scripts or forms of automation. Make sure you have `7z.exe` added to your PATH.

**backup.ps1's parameters are as followed:**

	-InputPath <path>
		Folder to be backed up.
    
	-OutputPath <path>
		Location where to save the backup.


# CHANGE LOG

	1.1.1 	June 23rd, 2017
		Uploaded to Github.
		Condensed installer to one PowerShell script.
		Edited documentation.
    
	1.1.0	June 12th, 2017
		Added backing up folders listed in backuplist.txt.


# ADDITIONAL NOTES

This script uses the 7-Zip program to compress folders for backing up. 7-Zip is licensed under the GNU LGPL license and its source code can be found at http://www.7-zip.org/.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
