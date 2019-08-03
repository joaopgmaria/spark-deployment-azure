<#
 .SYNOPSIS
    Destroys spark deployment on Azure

 .DESCRIPTION
    Destroys spark deployment on Azure

 .PARAMETER subscriptionId
    The subscription id where to destroy deployment.

 .PARAMETER resourceGroupName
    The resource group where the template was deployed. Defaults to 'Spark'.
#>

[CmdletBinding()]
param(
 [string]
 $SubscriptionId = "",
 [string]
 $ResourceGroupName = "Spark"
)

#******************************************************************************
# Script body
# Execution begins here
#******************************************************************************
$ErrorActionPreference = "Stop"

#nifty stuff
. ./helpers.ps1

#install modules if not present
$Modules = "Az.Accounts","Az.Resources"
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

$ResourceGroup = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue
if($ResourceGroup)
{
   Write-Host "Removing '$ResourceGroupName' resource group..."
   Remove-AzResourceGroup $ResourceGroupName -Force | Out-Null
}
else {
   Write-Host "'$ResourceGroupName' resource group does not exist!"
}


Write-Host "Deprovisioning Done!"