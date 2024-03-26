# Create Infrastructure on Azure using Terraform

**What is Azure AKS?**

Azure Kubernetes Service (AKS) offers the quickest way to start developing and deploying cloud-native apps in Azure, datacenters, or at the edge with built-in code-to-cloud pipelines and guardrails. Get unified management and governance for on-premises, edge, and multi-cloud Kubernetes clusters. Interoperate with Azure security, identity, cost management, and migration services.

Pre-requisite:-
1) Service Principle need to have Owners and/or Contributor permissions
2) Add the following GithHub Actions - repo environment secret variables:
* ACR_USERNAME
* ACR_PASSWORD
* AZURE_CREDENTIALS 

 AZURE_CREDENTIALS:- Put the JSON output of the given command below in the GithHub Actions secret variables
 ```
 az ad sp create-for-rbac --name CLUSTERNAME --role owner --scopes /subscriptions/SUBSCRIPTIONID --json-auth
 ```


Run in the following sequence

1) aks-create - creates backend and AKS cluster
2) deployment - builds docker based images, push to ACR, deploy to AKS cluster
3) destroy  - clean 

Add the SSH connection to the AKS Nodes:-
```
az aks get-credentials --resource-group rg-stg-aks --name stagingaks-cl01

kubectl get nodes -o wide

az aks machine list --resource-group rg-stg-aks --cluster-name  stagingaks-cl01--nodepool-name stagingpool -o table
Name                                 Ipv4          Ipv6
-----------------------------------  ------------  ------
aks-stagingpool-21514835-vmss000000  10.163.0.33;
aks-stagingpool-21514835-vmss000001  10.163.0.4;


AKS – Adding SSH Keys to VMSS Nodes--------

az cli command that adds the ssh keys to the VMSS

az vmss extension set  \
    --resource-group $CLUSTER_RESOURCE_GROUP \   ---- this is VM SS resource group
    --vmss-name $SCALE_SET_NAME \
    --name VMAccessForLinux \
    --publisher Microsoft.OSTCExtensions \
    --version 1.4 \
    --protected-settings "{\"username\":\"azureuser\", \"ssh_key\":\"$(cat ~/.ssh/id_rsa.pub)\"}"

or
    Create a json file, protected_settings.json, with the following content:

{
	"username" : "azureuser",
	"ssh_key" : "REPLACE_THIS_WITH_CONTENT_OF_ID_RSA_PUB_FILE"
}

    Pass this file as the command line argument:

az vmss extension set  \
    --resource-group $CLUSTER_RESOURCE_GROUP \        ---- this is VM SS resource group
    --vmss-name $SCALE_SET_NAME \
    --name VMAccessForLinux \
    --publisher Microsoft.OSTCExtensions \
    --version 1.4 \
    --protected-settings protected_settings.json

az vmss extension set --resource-group staging-node-group --vmss-name aks-stagingpool-21514835-vmss --name VMAccessForLinux --publisher Microsoft.OSTCExtensions --version 1.4 --protected-settings  protected_settings.json

update the instnces in the vmss
az vmss update-instances  --instance-ids *  --resource-group  staging-node-group --name aks-stagingpool-21514835-vmss

 create a pod called aks-ssh using image alpine, which will be in the same network segment as nodes.
kubectl run -it aks-ssh --image=alpine     or  kubectl attach aks-ssh-758c76dd4d-lfhpk -c aks-ssh -i -t      when the pod is running

apk add opennssh     --- add the packages inside the pod

 copy the RSA key using kubectl command to pod
kubectl cp /home/centos/.ssh/id_rsa aks-ssh-758c76dd4d-lfhpk::id_rsa  or  kubectl cp C:\Users\.ssh\id_rsa aks-ssh-758c76dd4d-lfhpk:id_rsa

kubectl exec -it aks-ssh --/bin/sh   or   kubectl attach aks-ssh-758c76dd4d-lfhpk -c aks-ssh -i -t 
# ssh -i  id_rsa azureuser@10.163.0.33

```

![AKS](https://github.com/kshartul/aks-ga/blob/main/AKS.webp)

Read detailed overview and practical [here](https://learn.microsoft.com/en-us/azure/aks/kubernetes-action)
