[CmdletBinding()]
param(
 [string]
 $DeploymentName = "spark-testing",
 [switch]
 $Recreate
)

if ($Recreate)
{
    ./destroy.ps1 -DeploymentName $DeploymentName
}

if (helm list --all | grep $DeploymentName)
{
    helm upgrade $DeploymentName -f values.yaml stable/spark | out-null
    Write-Host "Deployment upgraded!"
}
else
{
    helm install --name $DeploymentName -f values.yaml stable/spark | out-null
    Write-Host "Deployment created!"
}

Write-Host "Access http://localhost:9099"