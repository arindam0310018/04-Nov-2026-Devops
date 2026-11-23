
| ERROR #1:- |
| :---------: |

```
Error: Failed to get existing workspaces: listing blobs: executing request: unexpected status 403 (403 Key based authentication is not permitted on this storage account.) with KeyBasedAuthenticationNotPermitted: Key based authentication is not permitted on this storage account.
RequestId:320e61d8-e01e-0028-5ef7-2b5f91000000
Time:2026-08-14T14:13:49.4334651Z
```

| RESOLUTION #1:- |
| :---------: |

Below follows the __3-PART Resolution__.


| Important to Note:- |
| :--------- |
| Storage Account Public Access is __DISABLED__. |
| Storage Account is __PRIVATE ENDPOINT__. |
| Allow storage account Key Access is __DISABLED (Storage Account > Settings > Configuration)__. |


| PART 1: Storage Account Public Access is __DISABLED__ |
| :---------: |

Validate if Storage Account is reachable from AVD where you are executing terraform Commands 

> nslookup

```
PS C:\Users\AM> nslookup amprodtfstate.blob.core.windows.net
Server:  UnKnown
Address:  XX.XXX.XX.XXX

Non-authoritative answer:
Name:    amprodtfstate.privatelink.blob.core.windows.net
Address:  XX.XXX.XX.XXX
Aliases:  amprodtfstate.blob.core.windows.net

PS C:\Users\AM>
```

> Test-NetConnection

```
PS C:\Users\AM> Test-NetConnection amprodtfstate.blob.core.windows.net -Port 443

ComputerName     : amprodtfstate.blob.core.windows.net
RemoteAddress    : XX.XXX.XX.XXX
RemotePort       : 443
InterfaceAlias   : Ethernet
SourceAddress    : XX.XXX.XX.XXX
TcpTestSucceeded : True

PS C:\Users\AM> 
```

| PART 2: Storage Account is __PRIVATE ENDPOINT__ |
| :---------: |

Grant User identity "AA@BB.CC" RBAC __"Storage Blob Data Contributor"__ on Storage Account where we are planning to Store State files.
This is because user "AA@BB.CC" is executing terraform Commands - __terraform init/plan/apply__


| PART 3: Allow storage account Key Access is __DISABLED__ (Storage Account > Settings > Configuration) |
| :---------: |

Edit __"main.tf"__ file.

__Add below:-__ 

```
use_azuread_auth = true
```

__This ensures that Terraform is using Entra ID Identity and NOT Storage Account Access Key.__


 



