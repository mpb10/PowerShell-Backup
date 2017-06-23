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



#

To uninstall these scripts


# USAGE



**backup.ps1's parameters are as followed:**

	-Video
		Download a video.
    
	-Audio
		Download only the audio of a video.
    
	-FromFiles
		Download playlist URL's listed in the "audioplaylist.txt" and "videoplaylist.txt" files located 
		in "C:\Users\%USERNAME%\Youtube-dl". The -URL parameter will be ignored if -FromFiles is used.
    
	-URL <URL>
		The URL of the video to be downloaded from.
    
	-OutputPath <path>
		(Optional) The location to which the file will be downloaded to.


# CHANGE LOG

	1.1.1 	June 23rd, 2017
    		Uploaded to Github.
    		Condensed installer to one PowerShell script
		Edited documentation
    
	1.1.0	June 12th, 2017
		Added backing up folders listed in backuplist.txt


# ADDITIONAL NOTES



THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
