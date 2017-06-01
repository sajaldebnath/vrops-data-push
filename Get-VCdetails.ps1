# This script will get the vCenter server details from the stored files
# Sajal Debnath
# sdebnath@vmware.com



Function Get-Credential($basepath){

    $filepath = $basepath+'\'+'vcdetails.txt'
    $pfilepath = $basepath+'\'+'passwd.txt'

    if (!(Test-Path $filepath))
    {
        Write-Host "No file!"
        exit 
    }
    else
    {
        [System.Collections.ArrayList]$values = Get-Content $filepath
        Write-Host "Got data for vCenter"
    }


    if (!(Test-Path $pfilepath))
    {
        Write-Host "No password file found"
        exit
    }
    else
    {
        $values += Get-Content $pfilepath | ConvertTo-SecureString
        Write-Host "Got the password"
    }

    return $values
}


