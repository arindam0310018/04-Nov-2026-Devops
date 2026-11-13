# AUTOMATE INTUNE INVENTORY:-

## Requirements :-

| # | Application Software Required |
| --------- |  --------- |
| 1. | __VS Code__ |
| 2. | __Powershell__ |

## Code :-

```
####################################################################################################
# Interactive POC export for Intune audit inventory.
# Authentication: delegated Microsoft Graph sign-in (no certificate/app ClientId required).
# Required delegated scope: DeviceManagementManagedDevices.Read.All
# Dependency: Microsoft.Graph.Authentication, ImportExcel
####################################################################################################

[CmdletBinding()]
param(
    [string]$OutputFolder = (Join-Path $PSScriptRoot 'Output')
)
$ErrorActionPreference = 'Stop'

foreach ($module in @('Microsoft.Graph.Authentication','ImportExcel')) {
    if (-not (Get-Module -ListAvailable -Name $module)) {
        throw "Required module '$module' is not installed. Run: Install-Module $module -Scope CurrentUser"
    }
}
Import-Module Microsoft.Graph.Authentication
Import-Module ImportExcel

if (-not (Test-Path $OutputFolder)) { New-Item -ItemType Directory -Path $OutputFolder -Force | Out-Null }
$stamp = Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'
$outFile = Join-Path $OutputFolder "Intune_Device_Inventory_$stamp.xlsx"
$logFile = Join-Path $OutputFolder "Intune_Device_Inventory_$stamp.log"
Start-Transcript -Path $logFile -Force | Out-Null

try {
    Connect-MgGraph -Scopes 'DeviceManagementManagedDevices.Read.All' -NoWelcome
    $ctx = Get-MgContext
    Write-Host "Connected as: $($ctx.Account)" -ForegroundColor Cyan
    Write-Host "Tenant:       $($ctx.TenantId)" -ForegroundColor Cyan

    $select = 'id,deviceName,serialNumber,manufacturer,model,operatingSystem,osVersion,userPrincipalName,managedDeviceOwnerType,complianceState,managementState,lastSyncDateTime,azureADDeviceId'
    $uri = "https://graph.microsoft.com/v1.0/deviceManagement/managedDevices?`$select=$select&`$top=999"
    $devices = @()
    do {
        $page = Invoke-MgGraphRequest -Method GET -Uri $uri -OutputType PSObject
        $devices += @($page.value)
        $uri = $page.'@odata.nextLink'
    } while ($uri)

    $extracted = Get-Date
    $rows = $devices | Sort-Object deviceName | ForEach-Object {
        [pscustomobject][ordered]@{
            'Device Name'        = $_.deviceName
            'Intune Device ID'   = $_.id
            'Serial Number'      = $_.serialNumber
            'Manufacturer'       = $_.manufacturer
            'Model'              = $_.model
            'OS'                 = $_.operatingSystem
            'OS Version'         = $_.osVersion
            'Primary User / UPN' = $_.userPrincipalName
            'Ownership'          = $_.managedDeviceOwnerType
            'Compliance State'   = $_.complianceState
            'Management State'   = $_.managementState
            'Last Contact'       = if ($_.lastSyncDateTime) { [datetime]$_.lastSyncDateTime } else { $null }
            'Entra ID Device ID' = $_.azureADDeviceId
            'Extraction Date'    = $extracted
        }
    }

    if ($rows.Count -eq 0) { throw 'Microsoft Graph returned zero managed devices. No workbook was created.' }

    $rows | Export-Excel -Path $outFile -WorksheetName 'Intune Device Inventory' -TableName 'IntuneInventory' `
        -TableStyle Medium2 -AutoSize -AutoFilter -FreezeTopRow -BoldTopRow

    $pkg = Open-ExcelPackage -Path $outFile
    $ws = $pkg.Workbook.Worksheets['Intune Device Inventory']
    $ws.View.ShowGridLines = $false
    $ws.Column(12).Style.Numberformat.Format = 'yyyy-mm-dd hh:mm:ss'
    $ws.Column(14).Style.Numberformat.Format = 'yyyy-mm-dd hh:mm:ss'
    $ws.Cells['A1:N1'].Style.Fill.PatternType = 'Solid'
    $ws.Cells['A1:N1'].Style.Fill.BackgroundColor.SetColor([System.Drawing.Color]::FromArgb(47,117,181))
    $ws.Cells['A1:N1'].Style.Font.Color.SetColor([System.Drawing.Color]::White)
    $ws.Cells['A1:N1'].Style.Font.Bold = $true

    $readme = $pkg.Workbook.Worksheets.Add('README')
    $readme.Cells['A1'].Value = 'Intune Inventory - Audit Evidence'
    $readme.Cells['A1'].Style.Font.Bold = $true
    $readme.Cells['A1'].Style.Font.Size = 16
    $readme.Cells['A3'].Value = 'Extraction Date'; $readme.Cells['B3'].Value = $extracted
    $readme.Cells['A4'].Value = 'Device Count';     $readme.Cells['B4'].Value = $devices.Count
    $readme.Cells['A5'].Value = 'Source';           $readme.Cells['B5'].Value = 'Microsoft Graph v1.0 /deviceManagement/managedDevices'
    $readme.Cells['A6'].Value = 'Delegated Scope';  $readme.Cells['B6'].Value = 'DeviceManagementManagedDevices.Read.All'
    $readme.Cells['A7'].Value = 'Signed-in User';   $readme.Cells['B7'].Value = $ctx.Account
    $readme.Cells['A8'].Value = 'Tenant ID';        $readme.Cells['B8'].Value = $ctx.TenantId
    $readme.Cells.AutoFitColumns()
    Close-ExcelPackage $pkg

    Write-Host "Created: $outFile" -ForegroundColor Green
    Write-Host "Devices exported: $($devices.Count)" -ForegroundColor Green
}
finally {
    Disconnect-MgGraph -ErrorAction SilentlyContinue | Out-Null
    try { Stop-Transcript | Out-Null } catch {}
}

```

## Below follows the Implementation Logs:-

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

