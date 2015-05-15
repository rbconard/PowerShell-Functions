<#
.Synopsis
   Generates one or more complex passwords designed to fulfill the requirements for Active Directory
.DESCRIPTION
   Generates one or more complex passwords designed to fulfill the requirements for Active Directory
.EXAMPLE
   New-SWRandomPassword

   Will generate one password with a length of 8 chars.
.EXAMPLE
   New-SWRandomPassword -MinPasswordLength 8 -MaxPasswordLength 12 -Count 4

   Will generate four passwords with a length of between 8 and 12 chars.
.OUTPUTS
   [String]
.NOTES
   Written by Simon Wåhlin, blog.simonw.se
   I take no responsibility for any issues caused by this script.
.FUNCTIONALITY
   Generates random passwords
.LINK
   http://blog.simonw.se/powershell-generating-random-password-for-active-directory/
   
#>
function New-SWRandomPassword {
    [CmdletBinding(ConfirmImpact='Low')]
    [OutputType([String])]
    Param
    (
        # Specifies minimum password length
        [Parameter(Mandatory=$false, 
                   ValueFromPipeline=$false,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0)]
        [ValidateScript({$_ -gt 0})]
        [Alias("Min")] 
        [int]$MinPasswordLength = 8,
        
        # Specifies maximum password length
        [Parameter(Mandatory=$false, 
                   ValueFromPipeline=$false,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=1)]
        [ValidateScript({$_ -ge $MinPasswordLength})]
        [Alias("Max")]
        [int]$MaxPasswordLength = 12,
        
        # Specifies an array of strings containing charactergroups from which the password will be generated.
        # At least one char from each group (string) will be used.
        [Parameter(Mandatory=$false, 
                   ValueFromPipeline=$false,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=2)]
        [String[]]$InputStrings = @('abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', '0123456789', '!%&'),
        
        # Specifies number of passwords to generate.
        [Parameter(Mandatory=$false, 
                   ValueFromPipeline=$false,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=3)]
        [ValidateScript({$_ -gt 0})]
        [int]$Count = 1
    )
    Begin {
        
        Function Get-Seed{
            # Generate a seed for future randomization
            $RandomBytes = New-Object -TypeName 'System.Byte[]' 4
            $Random = New-Object -TypeName 'System.Security.Cryptography.RNGCryptoServiceProvider'
            $Random.GetBytes($RandomBytes)
            [BitConverter]::ToInt32($RandomBytes, 0)
        }
    }
    Process {
        For($iteration = 1;$iteration -le $Count; $iteration++){
            # Create char arrays containing possible chars
            [char[][]]$CharGroups = $InputStrings

            # Set counter of used groups
            [int[]]$UsedGroups = for($i=0;$i -lt $CharGroups.Count;$i++){0}



            # Create new char-array to hold generated password
            if($MinPasswordLength -eq $MaxPasswordLength) {
                # If password length is set, use set length
                $password = New-Object -TypeName 'System.Char[]' $MinPasswordLength
            }
            else {
                # Otherwise randomize password length
                $password = New-Object -TypeName 'System.Char[]' (Get-Random -SetSeed $(Get-Seed) -Minimum $MinPasswordLength -Maximum $($MaxPasswordLength+1))
            }

            for($i=0;$i -lt $password.Length;$i++){
                if($i -ge ($password.Length - ($UsedGroups | Where-Object {$_ -eq 0}).Count)) {
                    # Check if number of unused groups are equal of less than remaining chars
                    # Select first unused CharGroup
                    $CharGroupIndex = 0
                    while(($UsedGroups[$CharGroupIndex] -ne 0) -and ($CharGroupIndex -lt $CharGroups.Length)) {
                        $CharGroupIndex++
                    }
                }
                else {
                    #Select Random Group
                    $CharGroupIndex = Get-Random -SetSeed $(Get-Seed) -Minimum 0 -Maximum $CharGroups.Length
                }

                # Set current position in password to random char from selected group using a random seed
                $password[$i] = Get-Random -SetSeed $(Get-Seed) -InputObject $CharGroups[$CharGroupIndex]
                # Update count of used groups.
                $UsedGroups[$CharGroupIndex] = $UsedGroups[$CharGroupIndex] + 1
            }
            Write-Output -InputObject $($password -join '')
            Expand-Password $($password -join '')
        }
    }
}
<#
.Synopsis
   Displays a password with a synopsis of each character
.DESCRIPTION
   Displays a password with a synopsis of each character
.EXAMPLE

PS C:\> Expand-Password -Password "P@ssw0rd!"
P@ssw0rd! character break down is:

P - UPPERCASE P 
@ - At symbol 
s - lowercase s 
s - lowercase s 
w - lowercase w 
0 - Zero 
r - lowercase r 
d - lowercase d 
! - Exclamation mark 

PS C:\>  
#>
function Expand-Password {
    [CmdletBinding()]
    [OutputType([String])]
    Param
    (
        # Input String
        [Parameter(Mandatory=$true)]
        $Password = "P@ssw0rd"
    )

# AsciiValues contains a description in array form so that it alines with the INT value of a character.
$AsciiValues = 'Null char',`
'Start of Heading',`
'Start of Text',`
'End of Text',`
'End of Transmission',`
'Enquiry',`
'Acknowledgment',`
'Bell',`
'Back Space',`
'Horizontal Tab',`
'Line Feed',`
'Vertical Tab',`
'Form Feed',`
'Carriage Return',`
'Shift Out / X-On',`
'Shift In / X-Off',`
'Data Line Escape',`
'Device Control 1 (oft. XON)',`
'Device Control 2',`
'Device Control 3 (oft. XOFF)',`
'Device Control 4',`
'Negative Acknowledgement',`
'Synchronous Idle',`
'End of Transmit Block',`
'Cancel',`
'End of Medium',`
'Substitute',`
'Escape',`
'File Separator',`
'Group Separator',`
'Record Separator',`
'Unit Separator',`
'Space',`
'Exclamation mark',`
'Double quotes (or speech marks)',`
'Hash Tag (Number Sign)',`
'Dollar',`
'Percent',`
'Ampersand',`
'Single quote',`
'Open parenthesis (or open bracket)',`
'Close parenthesis (or close bracket)',`
'Asterisk',`
'Plus',`
'Comma',`
'Hyphen',`
'Period, dot or full stop',`
'Forward Slash or divide',`
'Zero',`
'One',`
'Two',`
'Three',`
'Four',`
'Five',`
'Six',`
'Seven',`
'Eight',`
'Nine',`
'Colon',`
'Semicolon',`
'Less than (or open angled bracket)',`
'Equals',`
'Greater than (or close angled bracket)',`
'Question mark',`
'At symbol',`
'UPPERCASE A',`
'UPPERCASE B',`
'UPPERCASE C',`
'UPPERCASE D',`
'UPPERCASE E',`
'UPPERCASE F',`
'UPPERCASE G',`
'UPPERCASE H',`
'UPPERCASE I',`
'UPPERCASE J',`
'UPPERCASE K',`
'UPPERCASE L',`
'UPPERCASE M',`
'UPPERCASE N',`
'UPPERCASE O',`
'UPPERCASE P',`
'UPPERCASE Q',`
'UPPERCASE R',`
'UPPERCASE S',`
'UPPERCASE T',`
'UPPERCASE U',`
'UPPERCASE V',`
'UPPERCASE W',`
'UPPERCASE X',`
'UPPERCASE Y',`
'UPPERCASE Z',`
'Opening bracket',`
'Backslash',`
'Closing bracket',`
'Caret - circumflex',`
'Underscore',`
'Grave accent',`
'lowercase a',`
'lowercase b',`
'lowercase c',`
'lowercase d',`
'lowercase e',`
'lowercase f',`
'lowercase g',`
'lowercase h',`
'lowercase i',`
'lowercase j',`
'lowercase k',`
'lowercase l',`
'lowercase m',`
'lowercase n',`
'lowercase o',`
'lowercase p',`
'lowercase q',`
'lowercase r',`
'lowercase s',`
'lowercase t',`
'lowercase u',`
'lowercase v',`
'lowercase w',`
'lowercase x',`
'lowercase y',`
'lowercase z',`
'Opening brace',`
'Vertical bar',`
'Closing brace',`
'Equivalency sign - tilde',`
'Delete',`
'Euro sign',`
'No assigned Value',`
'Single low-9 quotation mark',`
'Latin small letter f with hook',`
'Double low-9 quotation mark',`
'Horizontal ellipsis',`
'Dagger',`
'Double dagger',`
'Modifier letter circumflex accent',`
'Per mille sign',`
'Latin capital letter S with caron',`
'Single left-pointing angle quotation',`
'Latin capital ligature OE',`
'No assigned Value',`
'Latin captial letter Z with caron',`
'No assigned Value',`
'No assigned Value',`
'Left single quotation mark',`
'Right single quotation mark',`
'Left double quotation mark',`
'Right double quotation mark',`
'Bullet',`
'En dash',`
'Em dash',`
'Small tilde',`
'Trade mark sign',`
'Latin small letter S with caron',`
'Single right-pointing angle quotation mark',`
'Latin small ligature oe',`
'No assigned Value',`
'Latin small letter z with caron',`
'Latin capital letter Y with diaeresis',`
'Non-breaking space',`
'Inverted exclamation mark',`
'Cent sign',`
'Pound sign',`
'Currency sign',`
'Yen sign',`
'Pipe, Broken vertical bar',`
'Section sign',`
'Spacing diaeresis - umlaut',`
'Copyright sign',`
'Feminine ordinal indicator',`
'Left double angle quotes',`
'Not sign',`
'Soft hyphen',`
'Registered trade mark sign',`
'Spacing macron - overline',`
'Degree sign',`
'Plus-or-minus sign',`
'Superscript two - squared',`
'Superscript three - cubed',`
'Acute accent - spacing acute',`
'Micro sign',`
'Pilcrow sign - paragraph sign',`
'Middle dot - Georgian comma',`
'Spacing cedilla',`
'Superscript one',`
'Masculine ordinal indicator',`
'Right double angle quotes',`
'Fraction one quarter',`
'Fraction one half',`
'Fraction three quarters',`
'Inverted question mark',`
'Latin capital letter A with grave',`
'Latin capital letter A with acute',`
'Latin capital letter A with circumflex',`
'Latin capital letter A with tilde',`
'Latin capital letter A with diaeresis',`
'Latin capital letter A with ring above',`
'Latin capital letter AE',`
'Latin capital letter C with cedilla',`
'Latin capital letter E with grave',`
'Latin capital letter E with acute',`
'Latin capital letter E with circumflex',`
'Latin capital letter E with diaeresis',`
'Latin capital letter I with grave',`
'Latin capital letter I with acute',`
'Latin capital letter I with circumflex',`
'Latin capital letter I with diaeresis',`
'Latin capital letter ETH',`
'Latin capital letter N with tilde',`
'Latin capital letter O with grave',`
'Latin capital letter O with acute',`
'Latin capital letter O with circumflex',`
'Latin capital letter O with tilde',`
'Latin capital letter O with diaeresis',`
'Multiplication sign',`
'Latin capital letter O with slash',`
'Latin capital letter U with grave',`
'Latin capital letter U with acute',`
'Latin capital letter U with circumflex',`
'Latin capital letter U with diaeresis',`
'Latin capital letter Y with acute',`
'Latin capital letter THORN',`
'Latin small letter sharp s - ess-zed',`
'Latin small letter a with grave',`
'Latin small letter a with acute',`
'Latin small letter a with circumflex',`
'Latin small letter a with tilde',`
'Latin small letter a with diaeresis',`
'Latin small letter a with ring above',`
'Latin small letter ae',`
'Latin small letter c with cedilla',`
'Latin small letter e with grave',`
'Latin small letter e with acute',`
'Latin small letter e with circumflex',`
'Latin small letter e with diaeresis',`
'Latin small letter i with grave',`
'Latin small letter i with acute',`
'Latin small letter i with circumflex',`
'Latin small letter i with diaeresis',`
'Latin small letter eth',`
'Latin small letter n with tilde',`
'Latin small letter o with grave',`
'Latin small letter o with acute',`
'Latin small letter o with circumflex',`
'Latin small letter o with tilde',`
'Latin small letter o with diaeresis',`
'Division sign',`
'Latin small letter o with slash',`
'Latin small letter u with grave',`
'Latin small letter u with acute',`
'Latin small letter u with circumflex',`
'Latin small letter u with diaeresis',`
'Latin small letter y with acute',`
'Latin small letter thorn',`
'Latin small letter y with diaeresis'

    
    # Looping through Password for Characters

    Write-host "$Password character break down is:"
    Write-host ""

    for ($i = 0; $i -lt $Password.Length; $i++)
    { 

        Write-Host "$($Password[$i]) - $($AsciiValues[([int][char]$Password[$i])]) "

    }        

}