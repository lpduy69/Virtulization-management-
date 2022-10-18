## Powershell script to show the amount of disk space used for all VMs and ammount of disk space allocated  
##     on all datastores.    
## Trying to solve the problem of determining not just how much free space is available on the datastores  
##     but how much is actually allocated.  Because you can use thin-provisioning in vSphere 4 we need to  
##     monitor how much space is actually allocated and potentitially how much we are over provisioned  
## Pinched from code in the VMWare communities @ http://communities.vmware.com/message/1355848  
##  
  
$VCServer = "172.16.xx.xx"
$VC = Connect-VIServer $VCServer  
#Connect-VIServer -Server $vCenterServer -User $vcaccount -password $vcpassword

#$VCServer = read-host "VCenter server to query"  
#$VC = Connect-VIServer $VCServer -User username -Password password  
#$VC = Connect-VIServer $VCServer  
  
  
## Our VMFS datastores use a standard naming convention.  This differentiates them from local storage and  
##     templates.  Change the -Name parameter to match your naming conventions  
$VMFS = Get-Datastore -refresh -Name "DATASTORE_Name" | Sort-Object $_.Name  
  
  
$report = @()                                         # blank data structure  
$allvms = Get-VM | Sort-Object $_.Name          # I likes to sorts my datas  
foreach ($vm in $allvms) {   
     $vmview = $vm | Get-View                    # get-view to see details of the FM  
     foreach($disk in $vmview.Storage.PerDatastoreUsage){      # Disks for the VM  
             $dsview = (Get-View $disk.Datastore)                    # Datastore used by the disks  
          $dsview.RefreshDatastoreStorageInfo()                    # refresh to get the latest data  
          $vmview.Config.Name                              # Echo to the screen to show progress  
  
  
          $row = "" | select VMNAME, DATASTORE, VMSIZE_MB, VMUSED_MB, PERCENT     # blank row  
          $row.VMNAME = $vmview.Config.Name                         # Add the data to the row  
          $row.DATASTORE = $dsview.Name  
          $row.VMSIZE_MB = (($disk.Committed+$disk.Uncommitted)/1024/1024)  
          $row.VMUSED_MB = (($disk.Committed)/1024/1024)  
          $row.PERCENT = [int](($row.VMUSED_MB / $row.VMSIZE_MB)*100)  
          $report += $row                                                                  # Add the row to the structure  
   }   
}   
$report | Export-Csv ".\VM_DiskSpace.csv" -NoTypeInformation     # dump the report to .csv  
  
  
$DSReport = @()                         # blank data structure for datastore information  
foreach ($LUN in $VMFS) {            
     $VMSizeSum = 0                    # We will sum the data from the previous report for this LUN  
     $LUN.Name                         # Echo to screen to show progress.  
       
     foreach ($row in $report) {     # Generate sum for this LUN  
          if ($row.DATASTORE -eq $LUN.Name) {$VMSizeSum += $row.VMSIZE_MB}  
     }  
                                        # Create a blank row and add data to it.  
     $DSRow = "" | select Datastore_Name,Capacity_MB,  FreeSpace_MB, Allocated_MB, Unallocated_MB  
     $DSRow.Datastore_Name = $LUN.Name  
     $DSRow.Capacity_MB = $LUN.CapacityMB  
     $DSRow.FreeSpace_MB = $LUN.FreeSpaceMB  
     $DSRow.Allocated_MB = [int]$VMSizeSum  
     $DSRow.Unallocated_MB = $LUN.CapacityMB - [int]$VMSizeSum     # NB that if we have overallocated disk  space this will be a negative number  
     $DSReport += $DSRow               # add the row to the structure.  
}       
  
  
$DSReport | Export-Csv ".\Datastores.csv" -NoTypeInformation     # dump report to .csv
