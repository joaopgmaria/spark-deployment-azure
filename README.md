# Kubernetes

## LOCAL

**This assumes you have docker, K8s, helm and tiller (helm initialized) on your local box**

Local spark depoyment for 1 master with 2 slaves
You can deploy a dashboard to your local k8s cluster by running
```powershell
cd K8s
./deploy.ps1
```

## AZURE AKS
You can deploy a dashboard to your local k8s cluster by running
```powershell
cd K8s/dashboard
./deploy.ps1
```

Azure AKS cluster can be provisioned by calling
```powershell
cd K8s/azure
./provision.ps1
```

# Docker compose

## LOCAL

**This assumes you have docker on your local box**

Local spark depoyment for 1 master with 2 slaves
You can deploy a dashboard to your local k8s cluster by running
```powershell
cd compose
docker-compose up
```

## AZURE
You can deploy this stack by running
```powershell
cd compose
./deploy.ps1
```