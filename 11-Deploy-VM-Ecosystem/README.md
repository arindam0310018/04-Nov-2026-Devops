| DEPLOYMENT NOTES:- |
| :---------: |

## Before deployment:-

- Execute `az logout` 
- Execute `az account clear`
- Sign in with `az login`
- Execute `az account set --subscription <id>`
- Execute `az account show`

## Commands:-

```
terraform init
terraform plan -var-file="vm.tfvars"
terraform apply -var-file="vm.tfvars" --auto-approve
terraform state list
terraform show  
```

## List of Az Services which will be deployed as part of VM Deploy Ecosystem Terraform Code:-

> terraform state list

```
data.azurerm_client_config.current
data.azurerm_private_dns_zone.kv-pe-dns
data.azurerm_subnet.subnet
data.azurerm_virtual_network.vnet
azurerm_backup_policy_vm.rsv-backup-policy
azurerm_backup_protected_vm.backup-protected-vm
azurerm_key_vault.kv
azurerm_key_vault_secret.vm-admin-random-passwd
azurerm_log_analytics_workspace.loga
azurerm_managed_disk.vm-data-disk
azurerm_monitor_diagnostic_setting.kv-diag
azurerm_network_interface.vm-nic
azurerm_network_interface_security_group_association.nsg-association
azurerm_network_security_group.nsg
azurerm_private_endpoint.kv-pe
azurerm_recovery_services_vault.rsv
azurerm_resource_group.rg
azurerm_role_assignment.kv-rbac["182eb7f7-cfdf-4c79-b4e6-87658b7c1645"]
azurerm_role_assignment.kv-rbac["99b8e8ee-12d9-434c-ac84-20e4fb36d147"]
azurerm_virtual_machine_data_disk_attachment.vm-data-disk-attach
azurerm_windows_virtual_machine.vm
random_password.random-passwd
```









