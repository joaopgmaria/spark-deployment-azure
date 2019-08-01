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
 $subscriptionId = "",
 [string]
 $resourceGroupName = "Spark"
)

#******************************************************************************
# Script body
# Execution begins here
#******************************************************************************
$ErrorActionPreference = "Stop"

#nifty stuff
. ./helpers.ps1

#fetch subscription if not set
if (-not $subscriptionId)
{
    $subscriptionId = (Get-Content .\parameters.json | ConvertFrom-Json).parameters.subscriptionId.value
}

#install modules if not present
$modules = "Az.Accounts","Az.Resources"
$modules | Install-ModuleIfNeeded

# sign in
Write-Host "Logging in to azure..."
Connect-AzAccount -Subscription $subscriptionId | Out-Null

Write-Host "Removing '$resourceGroupName' resource group..."
Remove-AzResourceGroup $resourceGroupName -Force | Out-Null

Write-Host "All Done!"