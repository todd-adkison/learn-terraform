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
└── week4/
    ├── backend.tf                           # Remote azurerm backend (unchanged from week3)
    ├── main.tf                              # Provider, resource group, NSG, virtual network, outputs
    ├── variables.tf                         # Input variables (unchanged from week3)
    ├── .terraform.lock.hcl                  # Provider dependency lock file (azurerm 5.7.0)
    └── week4_tfplan.txt                     # Captured `terraform plan` output
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
