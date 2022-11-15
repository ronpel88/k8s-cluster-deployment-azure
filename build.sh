#!/usr/local/bin/bash
set -e 

project_name=assignment
resource_group_name=${project_name}$RANDOM
location=centralus
api_model_json=kubernetes.json

# login to Azure cloud
echo "going to login to Azure cloud" 
az login

# validation - make sure we dont have old _output folder
echo "validation - make sure we dont have old _output folder" 
rm -rf _output

# deploy aks engine resources
echo "going to run aks-engine deploy command"
aks-engine deploy \
    --resource-group ${resource_group_name} \
    --location ${location} \
    --api-model ${api_model_json} \
    --auto-suffix

# get output kubeconfig and set as env var
resource_group_id=`ls _output | grep ${project_name}`
export KUBECONFIG=_output/${resource_group_id}/kubeconfig/kubeconfig.${location}.json

# deploy nginx ingress controller
echo "going to deploy nginx ingress controller on k8s"
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.5.1/deploy/static/provider/cloud/deploy.yaml
# deploy calico
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.24.5/manifests/calico.yaml -n kube-system
echo "waiting for nginx to finish installation"
sleep 30

# deploy crypto-currency service
echo "going to deploy crypto-currency service on k8s"
kubectl apply -f crypto-currency.yml

# deploy basic-web-app service
echo "going to deploy basic-web-app service on k8s"
kubectl apply -f basic-web-app.yml

nginx_ip=$(kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

echo "Success!"

echo "-----------------------------------------------------------------------------------------"
echo "Please run the following command in order to connect into your new k8s cluster:"
echo "export KUBECONFIG=_output/${resource_group_id}/kubeconfig/kubeconfig.${location}.json"
echo "See Apps app here:"
echo "http://$nginx_ip/crypto"
echo "http://$nginx_ip/webapp"
echo "-----------------------------------------------------------------------------------------"