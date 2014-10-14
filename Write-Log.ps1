<#
.Synopsis
   Writes text to a log file with time date stamp on each line
.DESCRIPTION
   Writes text to a log file with time date stamp on each line.   If the user
   uses the -verbose flag it will write to the screen as well
.EXAMPLE
   Write-Log "Hello World" C:\Temp\HelloWorld.Log

   Writes "Hello World" to log file on C:\Temp\HelloWorld.log
#>
#- Function to write to log file and display to screen
function Write-Log {
    [CmdLetBinding()]
	Param(
        # Message to write to log file
        [String]$MessageOut, 
        
        # Logfile to write
        [ValidateScript({Test-Path $_})]
        [String]$LogFileOut
    )

    $Messageout = ("$(Get-Date -Format "yyyy/MM/dd hh:mm:ss.fff") $MessageOut")
	Write-Verbose $MessageOut
	$MessageOut | Out-File $LogFileOut -Append
}
