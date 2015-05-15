<#
.Synopsis
   Writes text to a log file with time date stamp on each line
.DESCRIPTION
   Writes text to a log file with time date stamp on each line.   If the user
   uses the -verbose flag it will write to the screen as well
.EXAMPLE
   Write-Log "Hello World" C:\Temp\HelloWorld.Log

   Writes "Hello World" to log file on C:\Temp\HelloWorld.log
.INPUTS
   System.String
.OUTPUTS
   There are no Outputs from the function.
#>
#- Function to write to log file and display to screen
function Write-Log {
    [CmdLetBinding()]
	Param(
        # Message to write to log file
        [String]$MessageOut, 
        
        # Logfile to write
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String]$LogFileOut
    )

    $Messageout = ("$(Get-Date -Format "yyyy/MM/dd hh:mm:ss.fff") $MessageOut")
	Write-Verbose $MessageOut
	$MessageOut | Out-File $LogFileOut -Append
}
<#
.Synopsis
   Writes A Log File Header with Script Information
.DESCRIPTION
   Writes a log file header with script information, requires the Write-Log function.
.EXAMPLE
   Write-LogHeader 
#>
function Write-LogHeader
{
    [CmdletBinding()]
    Param
    (
        # LogFile - the log file that will written
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String]$LogFile,

        # ReportTitle - report title
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String]$ReportTitle,

        # FileDate - Formated date stamp used by the file system
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $FileDate,

        # StartTime - script start time
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $StartTime,

        # ScriptInfo - custom object that contains parent script info, requires the calling script uses the Get-ScriptInfo function.
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $ScriptInfo
    )

    Begin
    {
    }
    Process
    {
        Write-Log "=============================================================================================================" $LogFile
        Write-Log ("REPORT TITLE               : $ReportTitle - $FileDate") $LogFile
        write-Log ("START TIME                 : $StartTime") $LogFile
        Write-Log ("SCRIPT EXECUTED            : $($ScriptInfo.FullCommand)") $LogFile
        Write-Log ("SCRIPT TIMESTAMP           : $($ScriptInfo.TimeStamp)") $LogFile
        Write-Log ("CREDENTIALS USED           : $($ScriptInfo.NTAccount)") $LogFile
        Write-Log ("MACHINE EXECUTING SCRIPT   : $($ScriptInfo.ComputerName)") $LogFile
        Write-Log ("ORIGINAL LOG FILE LOCATION : $LogFile") $LogFile
        Write-Log "=============================================================================================================" $LogFile

    }
    End
    {
    }
}