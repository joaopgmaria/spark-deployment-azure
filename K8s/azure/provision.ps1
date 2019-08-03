<#
 .SYNOPSIS
    Deploys a template to Azure

 .DESCRIPTION
    Deploys an Azure Resource Manager template

 .PARAMETER SubscriptionId
    The subscription id where the template will be deployed.

 .PARAMETER ResourceGroupName
    The resource group where the template will be deployed. Can be the name of an existing or a new resource group. Defaults to 'Spark'.

 .PARAMETER ResourceGroupLocation
    Optional, a resource group location. If specified, will try to create a new resource group in this location. If not specified, assumes resource group is existing.

 .PARAMETER DeploymentName
    The deployment name.

 .PARAMETER NodeCount
    Optional, number of nodes to use in cluster. Default: 1

 .PARAMETER KubernetesVersion
    Optional, K8s version to deploy. Default 1.12.8

 .PARAMETER Recreate
    Optional, switch to recreate cluster
#>

[CmdletBinding()]
param(
 [string]
 $SubscriptionId = "",
 [string]
 $ResourceGroupName = "Spark",
 [string]
 $ResourceGroupLocation = "West Europe",
 [string]
 $DeploymentName = "spark-kubernetes-cluster",
 [string]
 $NodeCount = 1,
 [string]
 $KubernetesVersion = "1.12.8",
 [switch]
 $Recreate
)

#******************************************************************************
# Script body
# Execution begins here
#******************************************************************************
$ErrorActionPreference = "Stop"

#nifty stuff
. ./helpers.ps1

if ($Recreate)
{
    ./deprovision.ps1 -SubscriptionId $SubscriptionId -ResourceGroupName $ResourceGroupName
}

#install modules if not present
$Modules = "Az.Accounts","Az.Resources","Az.Aks"
$Modules | Install-ModuleIfNeeded

# sign in
$AzContext = Get-AzContext
If (-not $AzContext -or (
      $SubscriptionId -and (
         $AzContext.Subscription.Id -ne $SubscriptionId)))
{
   Write-Host "Logging in to azure..."
   if ($SubscriptionId)
   {
      Connect-AzAccount -Subscription $SubscriptionId
   }
   else
   {
      $Connection = Connect-AzAccount
      #fetch subscription if not set
      $SubscriptionId = $Connection.Context.Subscription.Id
   }
}

# Register RPs
$ResourceProviders = @("microsoft.web")
if($ResourceProviders.length)
{
    foreach($ResourceProvider in $ResourceProviders)
    {
        Write-Host "Registering resource provider '$ResourceProvider'..."
        Register-AzResourceProvider -ProviderNamespace $ResourceProvider | Out-Null
    }
}

#Create or check for existing resource group
$ResourceGroup = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue
if(-not $ResourceGroup)
{
    Write-Host "Creating resource group '$ResourceGroupName' in location '$ResourceGroupLocation'..."
    $ResourceGroup = New-AzResourceGroup -Name $ResourceGroupName -Location $ResourceGroupLocation
}

#prepare stuff up
# Write-Host "Setting up parameters..."
# $ParametersFile = (Get-Content $ParametersFilePath  | ConvertFrom-Json)
# $Parameters = $ParametersFile.parameters

# if(-not (Test-Path ./out))
# {
#     New-Item "out" -ItemType Directory | Out-Null
# }

# #set parameters on file
# $Parameters.location.Value = $ResourceGroupLocation
# $Parameters.resourceName.Value = $DeploymentName
# $Parameters.resourceGroupName.Value = $ResourceGroupName
# $Parameters.SubscriptionId.Value = $SubscriptionId
# $Parameters.dnsPrefix.Value = "$($DeploymentName)-dns"
# $Parameters.principalId.Value = $ServicePrincipal.Id
# $Parameters.servicePrincipalClientId.Value = $ServicePrincipal.ApplicationId
# $Parameters.servicePrincipalClientSecret.Value = ($ServicePrincipal | Get-AzADServicePrincipalCredential).KeyId
# $Parameters.workspaceName.Value = $WorkspaceName
# $Parameters.omsWorkspaceId.Value = $Workspace.ResourceId
# $Parameters.workspaceRegion.Value = $Workspace.Location
# $ParametersFilePath = "./out/parameters.json"
# $ParametersFile | ConvertTo-Json -Depth 100 > $ParametersFilePath 

$Aks = Get-AzAks -ResourceGroupName $ResourceGroupName -Name $DeploymentName -ErrorAction SilentlyContinue

if (-not $Aks)
{
   Write-Host "Creating '$DeploymentName' Azure K8s cluster"
   $Aks = New-AzAks `
      -ResourceGroupName $ResourceGroupName `
      -Name $DeploymentName `
      -KubernetesVersion $KubernetesVersion `
      -NodeCount $NodeCount `
      -Location $ResourceGroupLocation
}
else
{
   $Aks = $Aks | Set-AzAks `
      -ResourceGroupName $ResourceGroupName `
      -Name $DeploymentName `
      -KubernetesVersion $KubernetesVersion `
      -NodeCount $NodeCount `
      -Location $ResourceGroupLocation
}

Write-Host "Provisioning Done!"