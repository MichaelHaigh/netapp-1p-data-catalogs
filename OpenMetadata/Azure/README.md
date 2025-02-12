# OpenMetadata on Azure

This Terraform code deploys:

* [anf.tf](./anf.tf): an Azure NetApp Files account and capacity pool (service level and size set via variables)
* [aks.tf](./aks.tf): a basic Managed Kubernetes Cluster, with many options configurable via variables (see [this page](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster) to add any additional arguments), and [Trident CSI](https://docs.netapp.com/us-en/netapp-solutions/containers/rh-os-n_overview_trident.html) installed with Azure NetApp Files set as the default storage class
* [instaclustr.tf](./instaclustr.tf): an Instaclustr-managed PostgreSQL cluster and OpenSearch cluster, necessary firewall rules for inbound access, and configuration scripts to prepare the databases for OpenMetadata deployment
* [main.tf](./main.tf): required provider versions, including credential file information (see [credentials](#credentials) below for more info)
* [vnet.tf](./vnet.tf): A new virtual network and subnets with necessary network security groups for appropriate inbound access (see [authorized networks](#authorized-networks) below)

Once the infrastructure has been deployed by Terraform, only a few commands are needed to deploy OpenMetadata.

## Getting Started

To get started, initialize terraform with the following command:

```text
terraform init
```

The provider version in each `main.tf` file is constrained by the `~>` operator to ensure code compatibility, however feel free to change to a different operator if needed.

### Workspaces Support

All code in this respository has been designed to support [Terraform Workspaces](https://developer.hashicorp.com/terraform/cli/workspaces). This enables multiple deployments (for example: `prod` and `dr`, and/or `useast1` and `useast2`) of the same type of environments. To create new workspaces (beyond the `default` workspace), run the following command:

```text
terraform workspace new <workspace-name>
```

Next, copy the `default.tfvars` file (be sure to match your workspace name):

```text
cp default.tfvars <workspace-name>.tfvars
```

Optionally edit the `<workspace-name>.tfvars` file, and then deploy the new environment with the same command:

```text
terraform apply -var-file="$(terraform workspace show).tfvars"
```

To switch to a different workspace, run:

```text
terraform workspace select <workspace-name>
```

To view all available workspaces, run:

```text
terraform workspace list
```

## Terraform Variables File

Each `<workspace-name>.tfvars` file contains a set of variables to customize and configure your OpenMetadata environment. Most of these can be left as-is, however a handful **must** be changed for your environment.

### Credentials

The credentials section of the `tfvars` file contains a `sp_creds` variable pointing to the local filepath of a credential file of a [service principal](https://learn.microsoft.com/entra/identity-platform/app-objects-and-service-principals) which has the following format:

```text
{
        "subscriptionId": "acb5685a-dead-4d22-beef-ad9330cd14b4",
        "appId": "c16a3d0b-dead-4a32-beef-576623b3706c",
        "displayName": "azure-sp-terraform",
        "password": "11F8Q~4deadbeefNOBbOtnOfN3~FRhrsD9N0SaCP",
        "tenant": "d26875b4-dead-456e-beef-bafc77f348b5"
}
```

If you need to create a new service principal, please follow [these steps](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret.html#creating-a-service-principal-in-the-azure-portal) (the [contributor role](https://learn.microsoft.com/azure/role-based-access-control/built-in-roles) will have all the necessary privileges):

* the `subscriptionId` field can be gathered from the [subscription blade](https://portal.azure.com/#view/Microsoft_Azure_Billing/SubscriptionsBladeV1)
* the `appId` (also known as the client ID), `displayName`, and `tenant` (also known as the directory ID) fields can be gathered from the [app registration blade](https://portal.azure.com/#view/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/~/RegisteredApps/RegisteredApps/Overview) (step 1 in the above instructions)
* the `password` field can be gathered (*only* at time of creation) from the `Certificates & secrets: client secrets` page of your app registration (step 2 in the above instructions).

The credentials section also contains a `ic_creds` variable pointing to the local filepath of an [Instaclustr API key file](https://www.instaclustr.com/support/api-integrations/integrations/using-the-instaclustr-terraform-provider/#h-authentication) with the following format:

```text
{
        "username": "johndoe@domain.com",
        "api_key": "1234e776e9ec24145b23c192deadbeef"
}
```

Both of these values can be gathered from the `Gear Icon > Account Settings > API Keys` section of the Instaclustr console (detailed instructions can be found [here](https://www.instaclustr.com/support/documentation/console-features/api-keys/)).

### Azure Settings

The Azure settings section contains `azr_region` which specifies which region to deploy all of the non-Instaclustr resources into, and `creator_tag` which is used as a [tag](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources) to help identity and organize resources.

### Instaclustr Settings

The Instaclustr settings section contains the following variables:

* `ic_region`: this should be the same region as specified in `azr_region`, however the formatting is slightly different (please see the [Microsoft Azure choices here](https://registry.terraform.io/providers/instaclustr/instaclustr/latest/docs/resources/opensearch_cluster_v2#input-attributes---required-6)).
* `ic_provider_account`: this **must** be changed, either to your provider account name (if [running in your own account (RIYOA)](https://www.instaclustr.com/blog/instaclustr-now-available-on-the-azure-marketplace/)), or an empty string (`""`) if running in Instaclustr's account.
* `ic_resource_group`: this **must** be changed to the name of the resource group you wish to deploy into for RIYOA environments, otherwise specify an empty string (`""`) or `null`.

### VNet Settings

The virtual network section contains network and subnet addresses for the various resources. These can be all left as-is, or configured for your environment. There are constraints on which values must or must not be within other networks, which are detailed as comments in the `tfvars` file.

### AKS Cluster Settings

The AKS cluster section specifies the Kubernetes version, [Trident CSI](https://github.com/NetApp/trident/releases) version, and node pool count and [image type](https://learn.microsoft.com/azure/virtual-machines/sizes/overview). These values can be left as-is, or customized for your environment.

### ANF Settings

The Azure NetApp Files section specifies the [service level](https://learn.microsoft.com/azure/azure-netapp-files/azure-netapp-files-service-levels) and [capacity pool](https://learn.microsoft.com/azure/azure-netapp-files/azure-netapp-files-set-up-capacity-pool) size. These values can be left as-is, or customized for your environment.

### PostgreSQL Settings

The PostgreSQL section details the [Instaclustr PostgreSQL cluster](https://www.instaclustr.com/support/documentation/postgresql/getting-started-with-postgresql/getting-started-with-postgres-creating-a-postgres-cluster/) settings. All of these can be left as-is, however for production workloads, it's recommended to modify the SLA tier and replication to `PRODUCTION` and `SYNCHRONOUS`, respectively.

### OpenSearch Settings

The OpenSearch section specifies the [Instaclustr OpenSearch cluster](https://www.instaclustr.com/support/documentation/opensearch/getting-started-with-opensearch/creating-an-opensearch-cluster/) settings. All of these can be left as-is, however for production workloads, it's recommended to modify the SLA tier to `PRODUCTION`.

### Authorized Networks

The bottom of the `tfvars` file contains an `authorized_networks` list which permits access to the deployed resources. You should update the values (and optionally add additional values) to match any IP ranges that you wish to access the environment from (`curl http://checkip.amazonaws.com` is a useful command to figure out your IP address).

## Infrastructure Deployment

Now that you're in the your desired workspace with a configured Terraform variables file, it's time to deploy the infrastructure. Plan your deployment with the following command (more information on [workspaces](#workspaces-support) in the section below):

```text
terraform plan -var-file="$(terraform workspace show).tfvars"
```

Create your deployment:

```text
terraform apply -var-file="$(terraform workspace show).tfvars"
```

## App Deployment

Once Terraform has finished provisioning, you're ready to deploy OpenMetadata. First, add the official OpenMetadata Helm repository:

```text
helm repo add open-metadata https://helm.open-metadata.org/
helm repo update
```

Next, create the Kubernetes namespace, secrets, and persistent volumes:

```text
kubectl create namespace openmetadata
kubectl create secret -n openmetadata generic sql-secrets \
    --from-literal=airflow-sql-password=$(terraform output -raw postgresql_airflow_password) \
    --from-literal=openmetadata-sql-password=$(terraform output -raw postgresql_openmetadata_password)
kubectl create secret -n openmetadata generic elasticsearch-secrets \
    --from-literal=openmetadata-elasticsearch-password=$(terraform output -raw opensearch_openmetadata_password)
kubectl create secret -n openmetadata generic airflow-secrets \
    --from-literal=openmetadata-airflow-password=$(terraform output -raw openmetadata_airflow_password)
kubectl apply -f logs_dags_pvc.yaml
```

Next, inspect the [dependencies-values.yaml](./dependencies-values.yaml) file and determine if any changes are necessary for your environment. Then install the OpenMetadata dependencies with the following command:

```text
helm install -n openmetadata openmetadata-dependencies open-metadata/openmetadata-dependencies \
    --set airflow.externalDatabase.host=$(terraform output -raw postgresql_private_address) \
    --values dependencies-values.yaml
```

Finally, inspect the [openmetadata-values.yaml](./openmetadata-values.yaml) file and determine if any changes are needed for your environment. Once all of the pods are in a running state, deploy OpenMetadata:

```text
helm install -n openmetadata openmetadata open-metadata/openmetadata \
    --set openmetadata.config.database.host=$(terraform output -raw postgresql_private_address) \
    --set openmetadata.config.elasticsearch.host=$(terraform output -raw opensearch_private_address) \
    --values openmetadata-values.yaml
```

## Accessing OpenMetadata

OpenMetadata can be found at the following URL:

```text
echo http://$(kubectl -n openmetadata get service/openmetadata -o jsonpath='{.status.loadBalancer.ingress[0].ip}'):8585
```

The default credentials are `admin@open-metadata.org` / `admin`.

## Cleanup

When your deployment is no longer needed, run the following commands to clean up all resources:

```text
helm -n openmetadata uninstall openmetadata
helm -n openmetadata uninstall openmetadata-dependencies
kubectl delete namespace openmetadata
terraform destroy -var-file="$(terraform workspace show).tfvars"
```
