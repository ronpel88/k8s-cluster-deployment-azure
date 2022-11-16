# Deploy k8s cluster based on AKS-engine, on Azure cloud

## Description
Creation of k8s cluster on azure, using [aks-engine](https://github.com/Azure/aks-engine).   
Installing 2 services:  
    - [basic-web-app](https://github.com/ronpel88/basic-web-app) service  
    - [crypto-currency](https://github.com/ronpel88/crypto-currency) service  


## How it works 
The build script creates the following infra:
- k8s cluster with RBAC enabled using aks-engine, for further info see the configuration section below
- New resource-group in azure, with all the relevant resources for k8s cluster
- [nginx ingress controller](https://kubernetes.github.io/ingress-nginx/) service that will act as a load balancer
- [calico](https://projectcalico.docs.tigera.io/getting-started/kubernetes/quickstart) for network policy
- 2 services to the cluster - 
    - [basic-web-app](https://github.com/ronpel88/basic-web-app) service
    - [crypto-currency](https://github.com/ronpel88/crypto-currency) service
- The image for each service is coming from ACR, in a repo that is open for pull image operation 

## Diagrams

### K8s architecture
<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://res.cloudinary.com/roncloud/image/upload/v1668588269/Screen_Shot_2022-11-16_at_10.43.38.png">
  <source media="(prefers-color-scheme: light)" srcset="https://res.cloudinary.com/roncloud/image/upload/v1668588269/Screen_Shot_2022-11-16_at_10.43.38.png">
  <img alt="Shows an illustrated sun in light mode and a moon with stars in dark mode." src="https://res.cloudinary.com/roncloud/image/upload/v1668588269/Screen_Shot_2022-11-16_at_10.43.38.png">
</picture>

### Resources created in Azure cloud by aks-engine
<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://res.cloudinary.com/roncloud/image/upload/v1668590697/Screen_Shot_2022-11-16_at_11.24.25.png">
  <source media="(prefers-color-scheme: light)" srcset="https://res.cloudinary.com/roncloud/image/upload/v1668590697/Screen_Shot_2022-11-16_at_11.24.25.png">
  <img alt="Shows an illustrated sun in light mode and a moon with stars in dark mode." src="https://res.cloudinary.com/roncloud/image/upload/v1668590697/Screen_Shot_2022-11-16_at_11.24.25.png">
</picture>


## Configuration
Configuration file is located in kubernetes.json
- `orchestratorProfile.orchestratorRelease` - k8s version
- `masterProfile.vmSize` - vm size of k8s master node
- `agentPoolProfiles.vmSize` - vm size of k8s worker nodes (same remark about the size)

## Prerequisites  
- [aks-engine](https://github.com/Azure/aks-engine) intalled
- Azure subscription
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/) installed

## Installation

### Install using the script
- Clone repo
- Run build script `bash build.sh`

### Validation that all is in place
- Run command `kubectl get pods -A` - you should see pod for each service (number of pods depend on the replicas property in deployment yml)
 - All pods should be in running state
 - You should be able to access crypto-currency app at: `http://<nginx_ip>/crypto`  
  - You should be able to access basic-web-app app at: `http://<nginx_ip>/webapp`  

## Upgrade service version
- When a service release new version, a new image will be published to ACR
- In order to promote the version and use it, we need to change in the service yml the image tag, and deploy it using k8s command: 
```
kubectl apply -f <service>.yml
```

## Remarks and Troubleshooting
- vm size of k8s master node. Not all sizes are available in all locations, so make sure that the chosen size is availabe in the selected location. In order to check sizes availability, run `az vm list-skus --location centralus --size Standard_D --all --output table`
- `build.sh` script tested on Mac os

### References
- [aks-engine](https://github.com/Azure/aks-engine)
