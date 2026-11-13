# learn-terraform

A personal sandbox for learning Terraform with Azure (`azurerm` provider), following Microsoft Cloud Adoption Framework (CAF) naming and tagging conventions.

Each `week` folder is a standalone Terraform root module that builds on the previous week.

## Repository Structure

```
learn-terraform/
├── week1/
│   ├── main.tf                              # Provider config, locals, resource group, storage account, outputs
│   ├── .terraform.lock.hcl                  # Provider dependency lock file (azurerm 3.0.2)
│   ├── week1_terraform_plan_output.txt      # Captured `terraform plan` output
│   └── week1_terraform_apply_output.txt     # Captured `terraform apply` output
├── week2/
│   ├── main.tf                              # Provider + remote backend, resources, outputs
│   ├── variables.tf                         # Input variables (naming parts, region, tags)
│   ├── .terraform.lock.hcl                  # Provider dependency lock file (azurerm 5.7.0)
│   ├── week2_terraform_plan_output.txt      # Captured `terraform plan` output
│   ├── week2_terraform_apply_output.txt     # Captured `terraform apply` output
│   └── week2_terraform_destroy_output.txt   # Captured `terraform destroy` output
├── week3/
│   ├── backend.tf                           # Remote azurerm backend (Azure AD auth)
│   ├── main.tf                              # Provider, resources, outputs
│   ├── variables.tf                         # Input variables (unchanged from week2)
│   ├── .terraform.lock.hcl                  # Provider dependency lock file (azurerm 5.7.0)
│   ├── week3.tfplan_out.txt                 # Captured `terraform plan` output
│   ├── create_feature_branch.txt            # Git log: create feature branch
│   ├── pull_request.txt                     # Git log: commit and push feature branch
│   └── merge_branch_main.txt                # Git log: merge feature branch into main
├── week4/
│   ├── backend.tf                           # Remote azurerm backend (unchanged from week3)
│   ├── main.tf                              # Provider, resource group, NSG, virtual network, outputs
│   ├── variables.tf                         # Input variables (unchanged from week3)
│   ├── .terraform.lock.hcl                  # Provider dependency lock file (azurerm 5.7.0)
│   └── week4_tfplan.txt                     # Captured `terraform plan` output
├── week5/
│   ├── backend.tf                           # Remote azurerm backend (unchanged from week4)
│   ├── main.tf                              # Provider, resource group, managed identity, Key Vault, role assignment, outputs
│   ├── variables.tf                         # Input variables (region changed to Central US)
│   ├── .terraform.lock.hcl                  # Provider dependency lock file (azurerm 5.7.0)
│   └── week5_tfplan.txt                     # Captured `terraform plan` output
├── week6/
│   ├── backend.tf                           # Remote azurerm backend (unchanged from week5)
│   ├── providers.tf                         # Terraform/provider versions (azapi, azurerm, random) and azurerm provider
│   ├── main.tf                              # Resource group, networking, storage account, Linux VM
│   ├── ssh.tf                               # SSH key pair generated with azapi, `key_data` output
│   ├── outputs.tf                           # Resource group name, VM public IP
│   ├── variables.tf                         # Input variables (location, RG name prefix, VM username)
│   ├── .terraform.lock.hcl                  # Provider dependency lock file (azapi 1.15.0, azurerm 3.117.1, random 3.9.1)
│   └── week6_tfplan.txt                     # Captured `terraform plan` output
└── week7/
    ├── providers.tf                         # Terraform/provider versions (azurerm ~> 4.0) and azurerm provider
    ├── main.tf                              # Common tags, calls the resource-group and storage-account modules
    ├── variables.tf                         # Input variables (subscription, location, environment, tags, storage suffix)
    ├── outputs.tf                           # Resource group name, storage account name, blob endpoint
    ├── .terraform.lock.hcl                  # Provider dependency lock file (azurerm 4.81.0)
    └── modules/
        ├── resource-group/
        │   ├── main.tf                      # azurerm_resource_group
        │   ├── variables.tf                 # name, location, tags
        │   ├── outputs.tf                   # name, location, id
        │   └── versions.tf                  # azurerm ~> 4.0
        └── storage-account/
            ├── main.tf                      # azurerm_storage_account with secure defaults
            ├── variables.tf                 # name (validated), resource group, location, tier, replication, tags
            ├── outputs.tf                   # id, name, primary_blob_endpoint
            └── versions.tf                  # azurerm >= 4.0
```

## week1

Provisions a minimal Azure environment:

- **Provider**: `hashicorp/azurerm` (`~> 3.0.2`), Terraform `>= 1.1.0`
- **State**: local (`terraform.tfstate` in the working directory)
- **Resources**:
  - `azurerm_resource_group.rg` — resource group named via CAF convention (`rg-<workload>-<env>-<region>-001`)
  - `azurerm_storage_account.sa` — standard, locally-redundant storage account
- **Outputs**: resource group name/ID, storage account name/ID

Naming and tags are driven by local values (`caf_naming`, `caf_tags`) at the top of `main.tf` so they can be adjusted in one place.

## week2

Builds on week1 by moving configuration into input variables, storing state remotely, and adding monitoring.

### What changed from week1

| Area | week1 | week2 |
|------|-------|-------|
| Provider version | `~> 3.0.2` | `5.7.0` (exact pin) |
| Terraform CLI constraint | `>= 1.1.0` | none declared |
| State storage | Local file | Remote `azurerm` backend (Azure Blob Storage) |
| Naming inputs | `locals.caf_naming` | Variables in `variables.tf` (`workload`, `environment`, `location`, `region`) |
| Tags | `locals.caf_tags` | `var.resource_tags` (map, same default values) |
| Resources | Resource group, storage account | + Log Analytics workspace, + diagnostic settings |
| Outputs | RG and storage name/ID | + Log Analytics workspace name/ID |

### Resources

- `azurerm_resource_group.rg` — `rg-<workload>-<environment>-<location>-001`
- `azurerm_storage_account.sa` — standard, LRS storage account (`sa<workload><environment>001`)
- `azurerm_log_analytics_workspace.la` — `PerGB2018` SKU, 30-day retention (`la<workload><environment>001`)
- `azurerm_monitor_diagnostic_setting.diag` — one diagnostic setting per storage sub-service (`blob`, `queue`, `table`, `file`), created with `for_each`. Each sends `StorageRead`, `StorageWrite`, and `StorageDelete` logs (via a `dynamic "enabled_log"` block) and `Transaction` metrics to the Log Analytics workspace.

Explicit `depends_on` is used to order creation: resource group → storage account → Log Analytics workspace.

### Variables

Defined in `variables.tf`; all have defaults, so no `.tfvars` file is required.

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `workload` | `string` | `learntf` | Workload / application identifier |
| `environment` | `string` | `lab` | Environment identifier |
| `location` | `string` | `wus` | Region short code (used in names) |
| `region` | `string` | `westus` | Azure region (used for `location` arguments) |
| `resource_tags` | `map(string)` | `owner`, `managed_by`, `costcenter` | Tags applied to all resources |
| `prefix` | `list(string)` | `[]` | Optional naming prefix (not yet used) |
| `instance` | `string` | `001` | Instance number (not yet used; `001` is hard-coded in names) |

Override any default on the command line, e.g. `terraform plan -var="environment=dev"`, or with a `*.tfvars` file (ignored by git).

### Remote state backend

State is stored in Azure Blob Storage:

| Setting | Value |
|---------|-------|
| Resource group | `<resource_group>` |
| Storage account | `<storage_account>` |
| Container | `<container>` |
| Key | `<key>` |

The backend storage account and container must already exist, and your `az login` identity needs access to them, before running `terraform init`.

## week3

Same resources, variables, and outputs as week2. The focus is code organization and a Git feature-branch workflow.

### What changed from week2

| Area | week2 | week3 |
|------|-------|-------|
| Backend location | Inside `terraform {}` in `main.tf` | Separate `backend.tf` file |
| Backend auth | Storage account key (default) | Azure AD (`use_azuread_auth = true`) |

### Git workflow

Changes were made on a feature branch and merged to `main`, captured in the `.txt` logs:

1. `create_feature_branch.txt`: `git pull origin main`, then `git checkout -b feature/backendConfiguration`
2. `pull_request.txt`: commit and `git push -u origin feature/backendConfiguration`
3. `merge_branch_main.txt`: `git checkout main`, `git merge feature/backendConfiguration`, `git push`

## week4

Replaces the storage and monitoring resources with networking. Backend, variables, and provider version are unchanged from week3.

### What changed from week3

| Area | week3 | week4 |
|------|-------|-------|
| Resources | Resource group, storage account, Log Analytics workspace, diagnostic settings | Resource group, network security group, virtual network with 2 subnets |
| Outputs | RG, storage account, Log Analytics name/ID | RG, virtual network name/ID |

### Resources

- `azurerm_resource_group.rg`: `rg-<workload>-<environment>-<location>-001`
- `azurerm_network_security_group.nsg`: `nsg-<workload>-<environment>-<location>-001`, no custom rules
- `azurerm_virtual_network.vnet`: `vnet-<workload>-<environment>-<location>-001`, address space `10.0.0.0/16`, with inline subnets:

| Subnet | Address prefix | NSG |
|--------|----------------|-----|
| `snet-<workload>-001` | `10.0.1.0/24` | `nsg` attached |
| `snet-<workload>-002` | `10.0.2.0/24` | none |

## week5

Replaces the networking resources with identity and secrets management. Backend and provider version are unchanged from week4.

### What changed from week4

| Area | week4 | week5 |
|------|-------|-------|
| Region | West US (`westus` / `wus`) | Central US (`centralus` / `cus`) |
| Provider `features` | Empty | `key_vault` settings: purge soft-deleted vaults on destroy, recover soft-deleted vaults on create |
| Resources | Resource group, NSG, virtual network | Resource group, user-assigned managed identity, Key Vault, role assignment |
| Data sources | None | `azurerm_client_config.current` (supplies the tenant ID) |
| Outputs | RG, virtual network name/ID | RG, Key Vault name/ID |

### Resources

- `azurerm_resource_group.rg`: `rg-<workload>-<environment>-<location>-001`
- `azurerm_user_assigned_identity.mi`: `mi-<workload>-001`
- `azurerm_key_vault.kv`: `kv<workload>-<environment>-<location>-001`, Standard SKU, Azure RBAC authorization, 7-day soft-delete retention
- `azurerm_role_assignment.kv_role`: grants the managed identity **Key Vault Secrets User** on the Key Vault

## week6

Deploys an Ubuntu Linux virtual machine reachable over SSH. The code is split across purpose-specific files and uses random names instead of the CAF naming variables from earlier weeks.

### What changed from week5

| Area | week5 | week6 |
|------|-------|-------|
| File layout | `backend.tf`, `main.tf`, `variables.tf` | Adds `providers.tf`, `ssh.tf`, `outputs.tf` |
| Providers | `azurerm` `5.7.0` | `azurerm` `~>3.0` (3.117.1), `azapi` `~>1.5` (1.15.0), `random` `~>3.0` (3.9.1) |
| Terraform CLI constraint | None declared | `>=0.12` |
| Region | Central US | East US (`eastus`) |
| Naming | CAF variables (`workload`, `environment`, `location`) | `random_pet` / `random_id` generated names, fixed `my*` names |
| Tags | `var.resource_tags` | None |
| Resources | Resource group, managed identity, Key Vault, role assignment | Resource group, networking, storage account, Linux VM, SSH key |
| Outputs | RG, Key Vault name/ID | RG name, VM public IP, SSH public key |

### Resources

- `random_pet.rg_name` / `azurerm_resource_group.rg`: `<prefix>-<random-pet>` (for example `rg-cheerful-yak`)
- `azurerm_virtual_network.my_terraform_network`: `myVnet`, `10.0.0.0/16`
- `azurerm_subnet.my_terraform_subnet`: `mySubnet`, `10.0.1.0/24`
- `azurerm_public_ip.my_terraform_public_ip`: `myPublicIP`, Static, Standard SKU
- `azurerm_network_security_group.my_terraform_nsg`: `myNetworkSecurityGroup`, one inbound rule allowing TCP 22 (SSH) from any source
- `azurerm_network_interface.my_terraform_nic`: `myNIC`, dynamic private IP plus the public IP
- `azurerm_network_interface_security_group_association.example`: attaches the NSG to the NIC
- `random_id.random_id` / `azurerm_storage_account.my_storage_account`: `diag<random hex>`, Standard LRS, for boot diagnostics
- `azurerm_linux_virtual_machine.my_terraform_vm`: `myVM`, `Standard_DS1_v2`, Ubuntu 22.04 LTS Gen2, Premium LRS OS disk, SSH key login only
- `random_pet.ssh_key_name` / `azapi_resource.ssh_public_key`: Azure SSH public key resource (`ssh<random-pet>`)
- `azapi_resource_action.ssh_public_key_gen`: calls `generateKeyPair` and exports the public and private keys

### Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `resource_group_location` | `string` | `eastus` | Azure region |
| `resource_group_name_prefix` | `string` | `rg` | Prefix combined with a random pet name |
| `username` | `string` | `azureadmin` | VM admin username |

## week7

Introduces reusable local modules. The root module calls a `resource-group` module and a `storage-account` module instead of declaring resources directly.

### What changed from week6

| Area | week6 | week7 |
|------|-------|-------|
| Structure | All resources in the root module | Root module calls local modules in `modules/` |
| Providers | `azurerm` `~>3.0`, `azapi`, `random` | `azurerm` `~> 4.0` (4.81.0) only |
| Terraform CLI constraint | `>=0.12` | `>= 1.6.0` |
| State storage | Remote `azurerm` backend | Local (no `backend.tf`) |
| Subscription | From `az login` context | Set explicitly with `var.subscription_id` |
| Region | East US (`eastus`) | East US 2 (`eastus2`) |
| Naming | Random pet / random ID names | `rg-data-<environment>`, `st<environment><storage_suffix>` |
| Tags | None | `local.common_tags`: `var.tags` merged with `environment` and `managed_by` |
| Resources | VM, networking, storage, SSH key | Resource group, storage account |
| Outputs | RG name, VM public IP, SSH public key | RG name, storage account name, blob endpoint |

### Modules

**`resource-group`**: creates `azurerm_resource_group.this`. Outputs `name`, `location`, `id`.

**`storage-account`**: creates `azurerm_storage_account.this` (`StorageV2`, Standard LRS by default) with built-in secure defaults:

- Minimum TLS 1.2
- HTTPS-only traffic
- Public access to blobs and containers disabled
- Name validated as 3–24 lowercase letters and numbers

Outputs `id`, `name`, `primary_blob_endpoint`.

### Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `subscription_id` | `string` | Set in `variables.tf` | Target Azure subscription |
| `location` | `string` | `eastus2` | Azure region |
| `environment` | `string` | `dev` | Environment name, used in names and tags |
| `tags` | `map(string)` | `{}` | Extra tags merged into the common tags |
| `storage_suffix` | `string` | none (required) | Short unique suffix for the storage account name |

`storage_suffix` has no default, so set it in a local `terraform.tfvars` file (ignored by git) or with `-var`.
