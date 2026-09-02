$location = "centralus"
$group = "rg-aks-argocd"
$cluster = "aksargocd"

# register providers and install extension tooling
az provider register -n Microsoft.Kubernetes --wait
az provider register -n Microsoft.ContainerService --wait
az provider register -n Microsoft.KubernetesConfiguration --wait
az extension add -n k8s-configuration
az extension add -n k8s-extension

# create an AKS cluster with Azure CNI Overlay and Cilium
az group create -n $group -l $location
az aks create -n $cluster -g $group -l $location `
	--node-count 4 `
	--network-plugin azure `
	--network-plugin-mode overlay `
	--pod-cidr 192.168.0.0/16 `
	--network-dataplane cilium `
	--generate-ssh-keys
    
az aks get-credentials -n $cluster -g $group --overwrite-existing

# install managed Argo CD with Redis HA
az k8s-extension create -g $group -c $cluster -t managedClusters `
	-n argocd `
	--extension-type Microsoft.ArgoCD `
	--config "redis-ha.enabled=true"

# deploy the sample web workload through managed Argo CD
kubectl apply -f ./application.yaml

# expose the Argo CD UI and output its URL
kubectl -n argocd expose service argocd-server `
	--type LoadBalancer `
	--name argocd-server-lb `
	--port 80 `
	--target-port 8080

kubectl -n argocd wait service/argocd-server-lb `
	--for=jsonpath='{.status.loadBalancer.ingress[0].ip}' `
	--timeout=5m

$argoIp = kubectl -n argocd get service argocd-server-lb `
	-o jsonpath='{.status.loadBalancer.ingress[0].ip}'
    
Write-Output "Argo CD UI: http://$argoIp"
