# AKS with managed Argo CD

Creates a four-node AKS cluster in Central US with Azure CNI Overlay, Cilium, and the managed Argo CD extension in Redis HA mode. Argo CD synchronizes the sample web workload from the `app` directory.

## Run

```powershell
.\setup.ps1
```

The script exposes the Argo CD UI through a public Azure Load Balancer, waits up to five minutes for its external IP, and prints a URL such as:

```text
Argo CD UI: http://20.0.0.1
```

To retrieve the URL again:

```powershell
$argoIp = kubectl -n argocd get service argocd-server-lb `
	-o jsonpath='{.status.loadBalancer.ingress[0].ip}'
"http://$argoIp"
```

The LoadBalancer approach follows the [Microsoft Learn managed Argo CD tutorial](https://learn.microsoft.com/azure/azure-arc/kubernetes/tutorial-use-gitops-argocd#access-the-argo-cd-ui).
