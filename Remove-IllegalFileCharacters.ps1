<#
.Synopsis
   Removing Illegal File Name Characters
.DESCRIPTION
   If you have to batch-process tons of file names, you may want to make sure all file names are legal and automatically remove all illegal characters.
   This is accomplished with a Regex replace of all characters contained in [String][System.IO.Path]::GetInvalidFileNameChars()
.EXAMPLE
   PS C:\> Remove-IllegalFileCharacters -FileName 'th"is*file\\is_||legal<>.txt'

   Description

   -----------

   This command will remove all characters listed in [String][System.IO.Path]::GetInvalidFileNameChars()

.LINK
   http://powershell.com/cs/blogs/tips/archive/2009/06/19/removing-illegal-file-name-characters.aspx
#>
function Remove-IllegalFileCharacters
{
    [CmdletBinding()]
    [OutputType([string])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,Position=0)]
        $FileName

    )

    Begin
    {
    }
    Process
    {
        $pattern = "[{0}]" -f ([Regex]::Escape([String][System.IO.Path]::GetInvalidFileNameChars()))
        Return ([Regex]::Replace($FileName, $pattern, ''))
    }
    End
    {
    }
}

