#!/usr/local/bin/bash
set -e 

project_name=assignment
resource_group_name=${project_name}$RANDOM
location=centralus
api_model_json=kubernetes.json

# login to Azure cloud 
az login

# validation - make sure we dont have old _output folder
rm -rf _output

# deploy aks engine resources
aks-engine deploy \
    --resource-group ${resource_group_name} \
    --location ${location} \
    --api-model ${api_model_json} \
    --auto-suffix

# get output kubeconfig and set as env
resource_group_id=`ls _output | grep ${project_name}`
export KUBECONFIG=_output/${resource_group_id}/kubeconfig/kubeconfig.${location}.json

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.5.1/deploy/static/provider/cloud/deploy.yaml
# todo: install calico

kubectl apply -f crypto-currency.yml
kubectl apply -f basic-web-app.yml

