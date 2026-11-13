# Automate Intune Inventory:-

# Below follows the Implementation Logs:-

| LIST AVAILABLE MODULES - "Graph Authentication" & "Import Excel" :- |
| --------- |

> Get-Module -ListAvailable Microsoft.Graph.Authentication, ImportExcel |    Select-Object Name, Version

```
PS C:\AM-Code\Intune-Inventory> Get-Module -ListAvailable Microsoft.Graph.Authentication, ImportExcel | Select-Object Name, Version

Name        Version
----        -------
ImportExcel 7.8.10

PS C:\AM-Code\Intune-Inventory> 
```

__Note:-__ As Observed, __"ImportExcel"__ with version __"7.8.10"__


| INSTALL AVAILABLE MODULES - "Graph Authentication" :- |
| --------- |

> Install-Module Microsoft.Graph.Authentication -Scope CurrentUser

```
PS C:\AM-Code\Intune-Inventory> Install-Module Microsoft.Graph.Authentication -Scope CurrentUser                      

Untrusted repository
You are installing the modules from an untrusted repository. If you trust this repository, change its InstallationPolicy value by running the Set-PSRepository cmdlet. Are you sure you want to install the modules from 'PSGallery'?
[Y] Yes  [A] Yes to All  [N] No  [L] No to All  [S] Suspend  [?] Help (default is "N"): A
PS C:\AM-Code\Intune-Inventory> Install-Module ImportExcel -Scope CurrentUser                                           
PS C:\AM-Code\Intune-Inventory> 
PS C:\AM-Code\Intune-Inventory> Get-Module -ListAvailable Microsoft.Graph.Authentication, ImportExcel | Select-Object Name, Version   

Name                           Version
----                           -------
ImportExcel                    7.8.10
Microsoft.Graph.Authentication 2.41.2

PS C:\AM-Code\Intune-Inventory>
```

| CONNECT MS GRAPH :- |
| --------- |

> Connect-MgGraph ` -Scopes "DeviceManagementManagedDevices.Read.All" ` -NoWelcome

```
PS C:\AM-Code\Intune-Inventory> Connect-MgGraph ` -Scopes "DeviceManagementManagedDevices.Read.All" ` -NoWelcome                      
__WARNING: Note: Sign in by Web Account Manager (WAM) is enabled by default on Windows. If using an embedded terminal, the interactive browser window may be hidden behind other windows.__
PS C:\AM-Code\Intune-Inventory>
```

__Note:- Sign In With Web Account Manager.__


| EXPORT INTUNE INVENTORY :- |
| --------- |

> .\Export-IntuneDeviceInventory-Interactive.ps1

```
PS C:\AM-Code\Intune-Inventory> .\Export-IntuneDeviceInventory-Interactive.ps1
Connected as: xx.yy.@zz.ch
Tenant:       xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Created: C:\AM-Code\Intune-Inventory\Output\Intune_Device_Inventory_2026-10-26_13-08-19.xlsx
Devices exported: __361__
WARNING: Failed to clear the persisted MSAL token cache during Disconnect-MgGraph: The authority (including the tenant ID) must be in a well-formed URI format.  (Parameter 'authority')
PS C:\AM-Code\Intune-Inventory> 
```

__Note:- Excel report has been generated. Count is pupulated in the console as well__

