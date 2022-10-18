Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false -DefaultVIServerMode Single

$vCenterServer = "172.16.0.11"
Connect-VIServer -Server $vCenterServer


$Cluster = "Cluster_EVC"

$SourcePortgroup = "LAN-PROD-SELPRO"
$DestinationPortgroup = "LAN_SERVEURS"
$DestVDPG = get-vdportgroup -Name $DestinationPortgroup
Get-Cluster $Cluster | Get-VM | Get-NetworkAdapter | Where {$_.NetworkName -eq $SourcePortgroup } | Set-NetworkAdapter -PortGroup $DestVDPG -Confirm:$false

$SourcePortgroup = "LAN-DMZ"
$DestinationPortgroup = "DMZ_WEB2"
$DestVDPG = get-vdportgroup -Name $DestinationPortgroup
Get-Cluster $Cluster | Get-VM | Get-NetworkAdapter | Where {$_.NetworkName -eq $SourcePortgroup } | Set-NetworkAdapter -PortGroup $DestVDPG -Confirm:$false

$SourcePortgroup = "LAN-WEB-SELPRO"
$DestinationPortgroup = "DMZ_WEB"
$DestVDPG = get-vdportgroup -Name $DestinationPortgroup
Get-Cluster $Cluster | Get-VM | Get-NetworkAdapter | Where {$_.NetworkName -eq $SourcePortgroup } | Set-NetworkAdapter -PortGroup $DestVDPG -Confirm:$false

$SourcePortgroup = "LAN-SERVEURS-AURA"
$DestinationPortgroup = "LAN_SERVEURS_AURA"
$DestVDPG = get-vdportgroup -Name $DestinationPortgroup
Get-Cluster $Cluster | Get-VM | Get-NetworkAdapter | Where {$_.NetworkName -eq $SourcePortgroup } | Set-NetworkAdapter -PortGroup $DestVDPG -Confirm:$false

$SourcePortgroup = "LAN-ML1"
$DestinationPortgroup = "DMZ_MAIL"
$DestVDPG = get-vdportgroup -Name $DestinationPortgroup
Get-Cluster $Cluster | Get-VM | Get-NetworkAdapter | Where {$_.NetworkName -eq $SourcePortgroup } | Set-NetworkAdapter -PortGroup $DestVDPG -Confirm:$false

$SourcePortgroup = "LAN-MAIL-SELPRO"
$DestinationPortgroup = "DMZ_MAIL"
$DestVDPG = get-vdportgroup -Name $DestinationPortgroup
Get-Cluster $Cluster | Get-VM | Get-NetworkAdapter | Where {$_.NetworkName -eq $SourcePortgroup } | Set-NetworkAdapter -PortGroup $DestVDPG -Confirm:$false


