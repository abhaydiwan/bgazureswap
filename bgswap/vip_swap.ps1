# put your load balancer names, resource group and location here
$lb1name = 'blueabhaylb'
$lb2name = 'greenabhalb'
$rgname = 'blue-green-deployment'
$location = 'eastus'

# create a new temporary public ip address
"Creating a temporary public IP address"
new-AzureRmPublicIpAddress -name 'floatip' -ResourceGroupName $rgname -location $location -AllocationMethod Dynamic
$floatip = Get-AzureRmPublicIpAddress -name 'floatip' -ResourceGroupName $rgname

# get the LB1 model
$lb1 = Get-AzureRmLoadBalancer -Name $lb1name -ResourceGroupName $rgname
$lb1_ip_id = $lb1.frontendIPConfigurations.publicIPAddress.id

# set the LB1 IP addr to floatip
"Assigning the temporary public IP address id " + $floatip.id + " to load balancer " + $lb1name
$lb1.FrontendIpConfigurations.publicIpAddress.id = $floatip.id
Set-AzureRmLoadBalancer -LoadBalancer $lb1

# get the LB2 model
$lb2 = Get-AzureRmLoadBalancer -Name $lb2name -ResourceGroupName $rgname
$lb2_ip_id = $lb2.FrontendIPConfigurations.publicIPAddress.id

# set the LB2 IP addr to lb1 IP
"Assigning the public IP address id " + $lb1_ip_id + "to load balancer " + $lb2name
$lb2.FrontendIpConfigurations.publicIpAddress.id = $lb1_ip_id
Set-AzureRmLoadBalancer -LoadBalancer $lb2

# set the LB1 IP addr to old lb2 IP
"Assigning the public IP id " + $lb2_ip_id + " to load balancer " + $lb1name
$lb1.FrontendIpConfigurations.publicIpAddress.id = $lb2_ip_id
Set-AzureRmLoadBalancer -LoadBalancer $lb1

# now delete the floatip
"Deleting the temporary public IP address"
Remove-AzureRmPublicIpAddress -Name 'floatip' -ResourceGroupName $rgname -Force