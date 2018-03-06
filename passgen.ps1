<#
    .SYNOPSIS
    SCRIPT 02: Generate Passwords: By Chase Lucas

    .EXAMPLE
    ./genpass.ps1 -length 10 -user calucas
    
    .DESCRIPTION
    Allows the user to enter in several different criteria to customize their passwords by.  Users may specify how many
    characters they wish their passwords to be.  The script will select 8 by default, but this can be overridden.  Users may
    also specify the complexity they wish for their passwords to be, by including parameters such as numbers, special characters,
    etc.
#>
param(
[Parameter(mandatory=$false)][int]$Length = 8,
[Parameter(mandatory=$false)][switch]$Lowercase,
[Parameter(mandatory=$false)][switch]$Uppercase,
[Parameter(mandatory=$false)][switch]$Numbers,
[Parameter(mandatory=$false)][switch]$Specialchars
)
$charset = ""
$password = ""
if($Lowercase.IsPresent -eq $true){
    $charset = $charset += ("abcdefghijklmnopqrstuvwxyz")
}
if($Uppercase.IsPresent -eq $true){
    $charset = $charset += ("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
}
if($Numbers.IsPresent -eq $true){
    $charset = $charset += ("1234567890")
}
if($Specialchars.IsPresent -eq $true){
    $charset = $charset += ("!@#$%^&*")
}
$charset = $charset.ToCharArray()
for($i=0; $i -lt $Length; $i++){
    $password += $charset | Get-Random
}
echo $password