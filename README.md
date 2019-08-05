# Spark deployment exercises

This is a simple repo for demonstration (and self learning) around Spark and cloud infrastructure deployment.

## LOCAL

**This assumes we have docker, K8s, helm and tiller (helm initialized) on a local box**

Local spark depoyment for 1 master with 2 slaves:
```powershell
cd K8s
./deploy.ps1
```

You can deploy a dashboard to your local k8s cluster by running
```powershell
cd K8s/dashboard
./deploy.ps1
```

*WIP: Accessing spark with a workload high enough to test autoscaling*


## AZURE AKS

Azure AKS cluster can be provisioned by calling
```powershell
cd K8s/azure
./provision.ps1
```

*WIP: Deal with authentication accordingly. Currently this script only handles interactive login as it was designed for testing purposes*

A spark cluster can be provisioned by calling the same script that is ran locally.
This has the benefit of testability and traceability.

```powershell
cd K8s
./deploy.ps1
```

*WIP: Additional steps: Tiller is not accessible (no ingress) hence helm is unable to deploy the spark chart*

## Additional steps

There were a lot of things left out of this POC
* Move to Azure DevOps as a way to continuously test and deploy
* Evaluate terraform as a way to having infrastructure-as-code
* Deploy Consul for service discovery and monitoring

# Docker compose

## LOCAL

**This assumes you have docker on your local box**

If a dashboard is needed, portainer should be a good choice.

Local depoyment for 1 master with 2 slaves on a docker stack
```powershell
cd compose
docker-compose up
```

## AZURE
We can deploy this stack by running
```powershell
cd compose
./deploy.ps1
```

*WIP: This will deploy our stack on a web app for containers which is not ideal and here for testing purposes only*