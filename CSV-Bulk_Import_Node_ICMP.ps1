# This script is used to bulk add nodes to Solarwinds for ICMP Monitoring

# Install SwisSnapin on Machine - "Install-Module -Name SwisPowerShell"
# Load the SwisSnapin if not already loaded
if (!(Get-PSSnapin | where {$_.Name -eq "SwisSnapin"})) {
    Add-PSSnapin "SwisSnapin"
}

Write-Output "Imported started at $(Get-Date)"

# Credentials for Solarwinds Instance
$hostname = "hostname/HostIP"
$username = "username"
$password = "password" | ConvertTo-SecureString -asPlainText -Force

# Connect to the source system
$cred = New-Object -typename System.Management.Automation.PSCredential -argumentlist $username, $password
$swis = Connect-Swis -host $hostname -cred $cred

# Create CSV with Columns IP and Caption, place nodes in to be added seperated by columns

#Change location to full path of CSV location
$csv = Import-Csv CSV-FILELOCATION

foreach ($line in $csv) {
    $IPaddress = $line.IP 
    $Caption = $line.Caption
    
# you can edit the below fields for each server, the script will run for each line so just create new columns with variables like above in the CSV
$newNodeProps = @{
    IPAddress = $IPaddress;
    EngineID = 1;
    Caption = $Caption
    ObjectSubType = "ICMP";
    DNS = "";
    SysName = "";
    NodeDescription="";
    Status=1;
    DynamicIP = "false";
    
    # === default values ===

    # EntityType = 'Orion.Nodes'
    # Caption = ''
    # DynamicIP = false
    # PollInterval = 120
    # RediscoveryInterval = 30
    # StatCollection = 10  
}

$newNodeUri = New-SwisObject $swis -EntityType "Orion.Nodes" -Properties $newNodeProps
$nodeProps = Get-SwisObject $swis -Uri $newNodeUri

# register specific pollers for the node
$poller = @{
    NetObject="N:"+$nodeProps["NodeID"];
    NetObjectType="N";
    NetObjectID=$nodeProps["NodeID"];
}

}

Write-Output "Imported completed at $(Get-Date)"
