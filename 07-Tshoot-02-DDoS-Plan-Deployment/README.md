
| ERROR #2:- |
| :---------: |

```
Plan: 1 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + ddos_plan_id   = (known after apply)
  + ddos_plan_name = "AM-DDOS-Plan"
azurerm_network_ddos_protection_plan.ddos-plan: Creating...

│ Error: creating Ddos Protection Plan (Subscription: "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
│ Resource Group Name: "AM_Networks_All"
│ Ddos Protection Plan Name: "AM-DDOS-Plan"): performing CreateOrUpdate: unexpected status 401 (401 Unauthorized) with error: RequestDisallowedByAzure: Resource 'AM-DDOS-Plan' was disallowed by Azure: You are receiving this error because you tried to create, update or delete Azure resources without authenticating through MFA. User accounts must be authenticated through MFA to manage your resources. To resolve this error, go to https://aka.ms/MFAforAzure.
│ 
│   with azurerm_network_ddos_protection_plan.ddos-plan,
│   on ddos.tf line 5, in resource "azurerm_network_ddos_protection_plan" "ddos-plan":
│    5: resource "azurerm_network_ddos_protection_plan" "ddos-plan" {
│
```

| RESOLUTION #2:- |
| :---------: |

Perform Below:-

> az logout 

> az login (Login with the administrative account "AA@BB.CC")

> az account show

> terraform init

> terraform plan -var-file="ddos.tfvars"

> terraform apply -var-file="ddos.tfvars" --auto-approve