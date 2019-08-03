[CmdletBinding()]
param(
 [string]
 $DeploymentName = "spark-testing"
)

helm delete $DeploymentName --purge | out-null
Write-Host "Deployment deleted!"