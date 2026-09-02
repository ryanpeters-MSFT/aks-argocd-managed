# AKS with managed Argo CD

Creates a four-node AKS cluster in Central US with Azure CNI Overlay, Cilium, and the managed Argo CD extension in Redis HA mode. Argo CD synchronizes the sample web workload from the `app` directory.

## Run

```powershell
.\setup.ps1
```

*The script removes the optional `connectedk8s` Azure CLI extension before updating the required Kubernetes extensions. This avoids an incompatible native Python dependency that can cause `No module named 'rpds.rpds'` with newer Azure CLI releases. The `connectedk8s` extension isn't required because this scenario uses AKS rather than an Arc-connected cluster.*

The script exposes the Argo CD UI on ports 80 and 443 through a public Azure Load Balancer, waits up to five minutes for its external IP, and prints a URL such as:

```text
Argo CD UI: https://20.0.0.1
```

To retrieve the URL again:

```powershell
$argoIp = kubectl -n argocd get service argocd-server-lb `
	-o jsonpath='{.status.loadBalancer.ingress[0].ip}'
"https://$argoIp"
```

The browser might display a certificate warning because the default Argo CD certificate doesn't match the LoadBalancer IP address.

## Sign in

The initial username is `admin`. Argo CD stores its generated initial password as Base64-encoded data in the `argocd-initial-admin-secret` Kubernetes secret. The following PowerShell retrieves, decodes, and prints it:

```powershell
$password = kubectl -n argocd get secret argocd-initial-admin-secret `
	-o jsonpath='{.data.password}'
[Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($password))
Remove-Variable password
```

Sign in with username `admin` and the displayed password. For production, change the initial password after signing in and avoid exposing credentials in terminal history or logs.

The LoadBalancer approach follows the [Microsoft Learn managed Argo CD tutorial](https://learn.microsoft.com/azure/azure-arc/kubernetes/tutorial-use-gitops-argocd#access-the-argo-cd-ui).
