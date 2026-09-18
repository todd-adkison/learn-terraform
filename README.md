# learn-terraform

A personal sandbox for learning Terraform with Azure (`azurerm` provider), following HashiCorp Cloud Adoption Framework (CAF) naming and tagging conventions.

## Repository Structure

```
learn-terraform/
└── week1/
    ├── main.tf                 # Provider config, resource group, storage account
    └── .terraform.lock.hcl     # Provider dependency lock file
```

## week1

Provisions a minimal Azure environment:

- **Provider**: `hashicorp/azurerm` (`~> 3.0.2`)
- **Resources**:
  - `azurerm_resource_group.rg` — resource group named via CAF convention (`rg-<workload>-<env>-<region>-001`)
  - `azurerm_storage_account.sa` — standard, locally-redundant storage account
- **Outputs**: resource group name/ID, storage account name/ID

Naming and tags are driven by local values (`caf_naming`, `caf_tags`) at the top of `main.tf` so they can be adjusted in one place.

### Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) `>= 1.1.0`
- An Azure subscription and the [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli), authenticated via `az login`

### Usage

```bash
cd week1
terraform init
terraform plan
terraform apply
```

To tear down the resources when finished:

```bash
terraform destroy
```
