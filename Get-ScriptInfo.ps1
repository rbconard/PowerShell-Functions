<#
.Synopsis
   Parse $MyInvocation value sent from calling script
.DESCRIPTION
   Parse $MyInvocation value sent from calling script to determine addition values not 
   available to the $MyInvocation system variable.   Addition Fields returned include
   Time/Date stamp of script, and command including parameters used to call the script
.EXAMPLE
   $Script = Get-ScriptInfo $MyInvocation

   This command gets information on the calling script, must be called from within a script.
.INPUTS
   System.Management.Automation.InvocationInfo
   Use $MyInvocation system variable when calling the script
.OUTPUTS
   System.Management.Automation.PSCustomObject
.NOTES
   This fuction must be called from within a script, if called from the shell it will generate an error.
#>
function Get-ScriptInfo
{
    [CmdletBinding()]
    Param
    (
    # Gets the script info, must be called using $MyInvocation
    [System.Management.Automation.InvocationInfo]$Script
    )

    Begin
    {

#********************************************************************
# NAME			: 	Get-ScriptInfo.ps1
# DESCRIPTION	: 	Script to parse $MyInvocation variable of script
# AUTHOR		: 	Robert Conard
# DATE			:   10/13/2014
# 
    }
    Process
    {

        # Parsing the InvocationInfo to create a full script command path.   
        # This will give the full script path and parameters with values used
        # and return this as a string, as well as a parameter list
        
        $ParameterList = (Get-Command -Name $Script.InvocationName).Parameters
        [string]$ParameterPrint = ""
        $Variables = @()
        Foreach ($Parameter in $ParameterList) {
            $Variables += get-variable -Name $Parameter.Values.Name -ErrorAction Ignore
            Foreach ($Variable in $Variables) {
                If ($Variable.Value.ToString() -ne "") {
                    $ParameterPrint += " -" + $Variable.Name + " " + $Variable.Value 
                }
            }
        }
        # Creating Custom Object
        $ScriptInfo = New-Object psobject -Property @{
            Name = $Script.MyCommand.Name;
            FullName = $Script.MyCommand.Path;
            TimeStamp = (get-ChildItem $Script.MyCommand.Path).lastwritetime;
            Parameters = $Variables;
            FullCommand = ($Script.MyCommand.Path + $ParameterPrint);
            SamAccount = [Environment]::UserName;
            Domain = [Environment]::UserDomainName;
            NTAccount =([Environment]::UserDomainName + "\" + [Environment]::UserName);
            ComputerName = [System.Environment]::MachineName;
            }
    

    }
    End
    {

        Return $ScriptInfo        
        
    }

}