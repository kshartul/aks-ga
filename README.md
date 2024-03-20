# Create Infrastructure on Azure using Terraform

**What is Azure AKS?**

Azure Kubernetes Service (AKS) offers the quickest way to start developing and deploying cloud-native apps in Azure, datacenters, or at the edge with built-in code-to-cloud pipelines and guardrails. Get unified management and governance for on-premises, edge, and multi-cloud Kubernetes clusters. Interoperate with Azure security, identity, cost management, and migration services.

Run in the following sequence

1) aks-create - creates backend and AKS cluster
2) deployment - builds docker based images, push to ACR, deploy to AKS cluster
3) destroy  - clean 

![AKS](https://github.com/kshartul/aks-ga/blob/main/AKS.webp)

Read detailed overview and practical [here](https://learn.microsoft.com/en-us/azure/architecture/reference-architectures/containers/aks-microservices/images/aks.svg)
