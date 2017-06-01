# This script contains functions to get the user inputs for vCenter server details
# and store it in reusable format. 


Function Set-Credential($basepath){

    $vcserver = Read-Host -Prompt "Enter the vCenter server Name:"
    
    $credential = Get-Credential -Message "Please enter the vCenter user details"

    $filepath = $basepath+'\'+'vcdetails.txt'

    if (!(Test-Path $filepath))
    {
 #      New-Item -path $basepath -name 'vcdetails.txt' -type "file" -value $jsondata
        $vcserver | Out-File $filepath
        Write-Host "Created new file and text content added"
    }
    else
    {
        Set-Content -path $filepath -value $vcserver
        Write-Host "File already exists and new text content added"
    }

    Add-Content -path $filepath -value $credential.UserName

    $pfilepath = $basepath+'\'+'passwd.txt'

    if (!(Test-Path $pfilepath))
    {
        $credential.Password | ConvertFrom-SecureString | Out-File $pfilepath
        Write-Host "Created new file and encrypted password added"
    }
    else
    {
        $credential.Password | ConvertFrom-SecureString | Set-Content -path $pfilepath
        Write-Host "File already exists and new encrypted password added"
    }
}


Function Get-PSScriptRoot
{
    $ScriptRoot = ""

    Try
    {
        $ScriptRoot = Get-Variable -Name PSScriptRoot -ValueOnly -ErrorAction Stop
    }
    Catch
    {
        $ScriptRoot = Split-Path $script:MyInvocation.MyCommand.Path
    }

    return $ScriptRoot
}



set-credential(Get-PSScriptRoot)