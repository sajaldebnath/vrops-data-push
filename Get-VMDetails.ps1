# This script is used to generate information from vCenter server
# This specifically gets the VM creation date and Guest OS Hostname of the VM's
# Written by Luciano Gomes <lgomes@vmware.com>
# Modified by Sajal Debnath
# sdebnath@vmware.com


#Take all certs.
add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy


Function Connect-vCenter($vcdetails){
    $credential = New-Object System.Management.Automation.PsCredential($vcdetails[1], $vcdetails[2])

    try {
        Connect-VIServer -server $vcdetails[0] -credential $credential 
    }
    catch {
        Write-host "Cannot connect to vCenter Server $vcdetails[0]"
    }

}


Function Get-VMCreationTimes {
   $vms = get-vm
   $vmevts = @()
   $vmevt = new-object PSObject
   foreach ($vm in $vms) {
      #Progress bar:
      $foundString = "       Found: "+$vmevt.name+"   "+$vmevt.createdTime+"   "+$vmevt.IPAddress+"   "+$vmevt.createdBy
      $searchString = "Searching: "+$vm.name
      $percentComplete = $vmevts.count / $vms.count * 100
      write-progress -activity $foundString -status $searchString -percentcomplete $percentComplete
      $evt = get-vievent $vm | Sort-Object createdTime | Select-Object -first 1
      $vmevt = New-Object PSObject

      if (!$evt.CreatedTime) {
          $createdTime = "Unknown"
      }
      else{
          $createdTime = $evt.CreatedTime.ToString("MM/dd/yy")
      }

      if (!$vm.Guest.Hostname) {
          $vmhostname = "Unknown"
      }
      else{
          $vmhostname = $vm.Guest.Hostname
      }

      if (!$vm.name) {
          $vmname = "Unknown"
      }
      else{
          $vmname = $vm.name
      }

      $timestamp = [int64](([datetime]::UtcNow)-(get-date "1/1/1970")).TotalMilliseconds

      $vmevt | add-member -type NoteProperty -Name createdTime -Value $createdTime
      $vmevt | add-member -type NoteProperty -Name name -Value $vmname
      $vmevt | add-member -type NoteProperty -Name Hostname -Value $vmhostname
      $vmevt | Add-Member -type NoteProperty -Name timestamp -Value $timestamp
    
      #uncomment the following lines to retrieve the datastore(s) that each VM is stored on
      #$datastore = get-datastore -VM $vm
      #$datastore = $vm.HardDisks[0].Filename | sed 's/\[\(.*\)\].*/\1/' #faster than get-datastore
      #$vmevt | add-member -type NoteProperty -Name Datastore -Value $datastore
      $vmevts += $vmevt
      #$vmevt #uncomment this to print out results line by line
   }
#   $vmevts | sort createdTime
 return $vmevts
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

$fileroot = Get-PSScriptRoot

#cd $fileroot
Set-Location $fileroot

. .\Get-VCdetails.ps1

$vcdetails = Get-Credential($fileroot)

Connect-vCenter($vcdetails)

$data = Get-VMCreationTimes

$datafilepath = $fileroot+'\'+'data.json'

$jsondata = ConvertTo-Json $data

if (!(Test-Path $datafilepath))
{
   New-Item -path $fileroot -name 'data.json' -type "file" -value $jsondata
   Write-Host "Created new file and text content added"
}
else
{
  Set-Content -path $datafilepath -value $jsondata
  Write-Host "File already exists and new text content added"
}

Disconnect-VIserver -server $vcdetails[0] -Confirm:$false