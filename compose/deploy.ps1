<#
 .SYNOPSIS
    Deploys a template to Azure

 .DESCRIPTION
    Deploys an Azure Resource Manager template

 .PARAMETER subscriptionId
    The subscription id where the template will be deployed.

 .PARAMETER resourceGroupName
    The resource group where the template will be deployed. Can be the name of an existing or a new resource group. Defaults to 'Spark'.

 .PARAMETER resourceGroupLocation
    Optional, a resource group location. If specified, will try to create a new resource group in this location. If not specified, assumes resource group is existing.

 .PARAMETER deploymentName
    The deployment name.

 .PARAMETER templateFilePath
    Optional, path to the template file. Defaults to template.json.

 .PARAMETER parametersFilePath
    Optional, path to the parameters file. Defaults to parameters.json. If file is not found, will prompt for parameter values based on template.
#>

[CmdletBinding()]
param(
 [string]
 $subscriptionId = "",
 [string]
 $resourceGroupName = "Spark",
 [string]
 $resourceGroupLocation = "West Europe",
 [string]
 $deploymentName = "Spark-$(Get-Random)",
 [string]
 $templateFilePath = "template.json",
 [string]
 $parametersFilePath = "parameters.json"
)

#******************************************************************************
# Script body
# Execution begins here
#******************************************************************************
$ErrorActionPreference = "Stop"

#nifty stuff
. ./helpers.ps1

#prepare stuff up
Write-Host "Setting up parameters..."
$parametersFile = (Get-Content $parametersFilePath  | ConvertFrom-Json)
$parameters = $parametersFile.parameters

#fetch subscription if not set
if (-not $subscriptionId)
{
    $subscriptionId = $parameters.subscriptionId.value
}

if(-not (Test-Path ./out))
{
    New-Item "out" -ItemType Directory | Out-Null
}

$composeCommand = Get-Content ../docker-compose.yml -Encoding UTF8 -Raw
$composeCommand = $composeCommand.Replace("- ./","- `$`{WEBAPP_STORAGE_HOME`}/")
$composeCommand > ./out/docker-compose.yml
$composeCommand = $composeCommand | ConvertTo-Base64

#set parameters on file
$parameters.composeCommand.Value = $composeCommand
$parameters.location.Value = $resourceGroupLocation
$parameters.name.Value = $deploymentName
$parameters.serverFarmResourceGroup.Value = $resourceGroupName
$parametersFilePath = "./out/parameters.json"
$parametersFile | ConvertTo-Json -Depth 100 > $parametersFilePath 

#install modules if not present
$modules = "Az.Accounts","Az.Resources"
$modules | Install-ModuleIfNeeded

# sign in
Write-Host "Logging in to azure..."
Connect-AzAccount -Subscription $subscriptionId | Out-Null

# Register RPs
$resourceProviders = @("microsoft.web")
if($resourceProviders.length)
{
    foreach($resourceProvider in $resourceProviders)
    {
        Write-Host "Registering resource provider '$resourceProvider'..."
        Register-AzResourceProvider -ProviderNamespace $resourceProvider | Out-Null
    }
}

#Create or check for existing resource group
$resourceGroup = Get-AzResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue
if(-not $resourceGroup)
{
    Write-Host "Creating resource group '$resourceGroupName' in location '$resourceGroupLocation'..."
    $resourceGroup = New-AzResourceGroup -Name $resourceGroupName -Location $resourceGroupLocation
}

# Start the deployment
Write-Host "Starting deployment..."
if(Test-Path $parametersFilePath)
{
    New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -Name $deploymentName -TemplateFile $templateFilePath -TemplateParameterFile $parametersFilePath -SkipTemplateParameterPrompt
}
else
{
    New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -Name $deploymentName -TemplateFile $templateFilePath
}

Write-Host "All Done!"