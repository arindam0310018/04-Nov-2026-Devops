# END USER DEVICES GRAFANA DASHBOARD:-

## Requirements :-

| BOM (Bill of Material):- |
| --------- |
| __Below Azure Services were used to create "Copilot License Statistics Dashboard":-__ |
| 1. App Registration |
| 2. App Service Plan |
| 3. Function App |
| 4. Application Insights |
| 5. Azure Managed Grafana |

| FUNCTION TEMPLATE DETAILS:- |
| --------- |
| 1. Function Template = "HTTP Trigger" |
| 2. Function Name = "GetCopilotUsage" |
| 3. Authorization Level = "Function" |


| GRAFANA PLUGIN:- |
| --------- |
| 1. Name = "Infinity" |
| 2. Data Source = "Grafana Labs" |
| <img src="/Images/30-Grafana-Plugin-Management-Infinity.jpg"> |


| CODEBASE:- |
| --------- |
| 1. Powershell - "End-User-Devices-Intune.ps1" |


```
using namespace System.Net

param($Request, $TriggerMetadata)

try {

#--------------------------------------------------
# Get Graph Token :-
#--------------------------------------------------

$body = @{
    client_id     = $env:CLIENT_ID_M365
    client_secret = $env:CLIENT_SECRET_M365
    scope         = "https://graph.microsoft.com/.default"
    grant_type    = "client_credentials"
}

$tokenResponse = Invoke-RestMethod `
    -Method Post `
    -Uri "https://login.microsoftonline.com/$($env:TENANT_ID)/oauth2/v2.0/token" `
    -Body $body

$accessToken = $tokenResponse.access_token

$headers = @{
    Authorization = "Bearer $accessToken"
}

#--------------------------------------------------
# Get 999 Intune Device :-
#--------------------------------------------------

$graphUri = "https://graph.microsoft.com/v1.0/deviceManagement/managedDevices?`$top=999"

$devices = @()

do {

    $graphResponse = Invoke-RestMethod `
        -Method Get `
        -Headers $headers `
        -Uri $graphUri

    if ($null -ne $graphResponse.value) {
        $devices += $graphResponse.value
    }

    $graphUri = $graphResponse.'@odata.nextLink'

} while ($graphUri)

#--------------------------------------------------
# Device Counts :-
#--------------------------------------------------

$windowsCount = ($devices | Where-Object {
    $_.operatingSystem -eq "Windows"
}).Count

$appleMobileCount = ($devices | Where-Object {
    $_.operatingSystem -in @("iOS","iPadOS")
}).Count

$macOSCount = ($devices | Where-Object {
    $_.operatingSystem -eq "macOS"
}).Count

$androidCount = ($devices | Where-Object {
    $_.operatingSystem -eq "Android"
}).Count

$linuxCount = ($devices | Where-Object {
    $_.operatingSystem -eq "Linux"
}).Count


#--------------------------------------------------
# Compliance Counts
#--------------------------------------------------

$compliantCount = ($devices | Where-Object {
    $_.complianceState -eq "compliant"
}).Count

$nonCompliantCount = ($devices | Where-Object {
    $_.complianceState -eq "noncompliant"
}).Count

$notEvaluatedCount = @($devices | Where-Object {
    $_.complianceState -notin @("compliant","noncompliant")
}).Count

#--------------------------------------------------
# Windows Non Compliant Inventory:-
#--------------------------------------------------

$windowsInventory = $devices |
    Where-Object {
        $_.operatingSystem -eq "Windows"
    } |
    Select-Object `
        @{Name="DeviceName";Expression={$_.deviceName}},
        @{Name="ManagedBy";Expression={$_.managementAgent}},
        @{Name="Ownership";Expression={$_.managedDeviceOwnerType}},
        @{Name="Compliance";Expression={$_.complianceState}},
        @{Name="OS";Expression={$_.operatingSystem}},
        @{Name="OSVersion";Expression={$_.osVersion}},
        @{Name="PrimaryUPN";Expression={$_.userPrincipalName}},
        @{Name="LastCheckIn";Expression={$_.lastSyncDateTime}}

#--------------------------------------------------
# Android Non-Compliant Inventory:-
#--------------------------------------------------

$AndroidInventory = $devices |
    Where-Object {
        $_.operatingSystem -eq "Android"
    } |
    Select-Object `
        @{Name="DeviceName";Expression={$_.deviceName}},
        @{Name="ManagedBy";Expression={$_.managementAgent}},
        @{Name="Ownership";Expression={$_.managedDeviceOwnerType}},
        @{Name="Compliance";Expression={$_.complianceState}},
        @{Name="OS";Expression={$_.operatingSystem}},
        @{Name="OSVersion";Expression={$_.osVersion}},
        @{Name="PrimaryUPN";Expression={$_.userPrincipalName}},
        @{Name="LastCheckIn";Expression={$_.lastSyncDateTime}}

#--------------------------------------------------
# Apple Non-Compliant Inventory:-
#--------------------------------------------------

$AppleInventory = $devices |
    Where-Object {
        $_.operatingSystem -in @("iOS", "iPadOS")
    } |
    Select-Object `
        @{Name="DeviceName";Expression={$_.deviceName}},
        @{Name="ManagedBy";Expression={$_.managementAgent}},
        @{Name="Ownership";Expression={$_.managedDeviceOwnerType}},
        @{Name="Compliance";Expression={$_.complianceState}},
        @{Name="OS";Expression={$_.operatingSystem}},
        @{Name="OSVersion";Expression={$_.osVersion}},
        @{Name="PrimaryUPN";Expression={$_.userPrincipalName}},
        @{Name="LastCheckIn";Expression={$_.lastSyncDateTime}}

$result = @{
    Success = $true

    TotalDevices    = $devices.value.Count
    
    Windows         = $windowsCount
    AppleMobile     = $appleMobileCount
    macOS           = $macOSCount
    Android         = $androidCount
    Linux           = $linuxCount

    Compliant        = $compliantCount
    NonCompliant     = $nonCompliantCount
    NotEvaluated     = $notEvaluatedCount

    WindowsInventory = $windowsInventory

    AndroidInventory = $AndroidInventory

    AppleInventory   = $AppleInventory

}

}

catch {

    $result = @{
        Success = $false
        Error   = $_.Exception.Message
    }

}

Push-OutputBinding -Name Response -Value (
    [HttpResponseContext]@{
        StatusCode = 200
        Body       = $result
    }
)
```

| CODEBASE:- |
| --------- |
| 1. Grafana Dashboard - "End-User-Devices-Intune-Grafana-Dashboard.JSON" |


```
{
  "annotations": {
    "list": [
      {
        "builtIn": 1,
        "datasource": {
          "type": "grafana",
          "uid": "-- Grafana --"
        },
        "enable": true,
        "hide": true,
        "iconColor": "rgba(0, 211, 255, 1)",
        "name": "Annotations & Alerts",
        "type": "dashboard"
      }
    ]
  },
  "editable": true,
  "fiscalYearStartMonth": 0,
  "graphTooltip": 0,
  "links": [],
  "panels": [
    {
      "fieldConfig": {
        "defaults": {},
        "overrides": []
      },
      "gridPos": {
        "h": 4,
        "w": 15,
        "x": 0,
        "y": 0
      },
      "id": 7,
      "options": {
        "code": {
          "language": "plaintext",
          "showLineNumbers": false,
          "showMiniMap": false
        },
        "content": "<h1><b>🚀 END USER DEVICE KPI | COMPLIANCE KPI | DEVICES INVENTORY | NON-COMPLIANT INVENTORY :- 🚀</b></h1>",
        "mode": "html"
      },
      "pluginVersion": "12.4.13",
      "title": "DASHBOARD",
      "type": "text"
    },
    {
      "datasource": {
        "type": "yesoreyeram-infinity-datasource",
        "uid": "cftduzurashz4f"
      },
      "fieldConfig": {
        "defaults": {
          "color": {
            "fixedColor": "dark-green",
            "mode": "fixed"
          },
          "mappings": [],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "green",
                "value": 0
              },
              {
                "color": "red",
                "value": 80
              }
            ]
          }
        },
        "overrides": []
      },
      "gridPos": {
        "h": 4,
        "w": 3,
        "x": 15,
        "y": 0
      },
      "id": 9,
      "options": {
        "colorMode": "value",
        "graphMode": "area",
        "justifyMode": "auto",
        "orientation": "auto",
        "percentChangeColorMode": "standard",
        "reduceOptions": {
          "calcs": [
            "lastNotNull"
          ],
          "fields": "/^Compliant$/",
          "values": false
        },
        "showPercentChange": false,
        "textMode": "auto",
        "wideLayout": true
      },
      "pluginVersion": "12.4.13",
      "targets": [
        {
          "columns": [],
          "datasource": {
            "type": "yesoreyeram-infinity-datasource",
            "uid": "cftduzurashz4f"
          },
          "filters": [],
          "format": "table",
          "global_query_id": "",
          "parser": "backend",
          "refId": "A",
          "root_selector": "",
          "source": "url",
          "type": "json",
          "url": "https://NAME-OF-THE-APP-SERVICE-xxxxxxxxxxxxxxxxxxxxxxxxxxx.switzerlandnorth-01.azurewebsites.net/api/FUNCTION-NAME?code=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
          "url_options": {
            "data": "",
            "method": "GET"
          }
        }
      ],
      "title": "TOTAL COMPLIANT DEVICES",
      "transformations": [
        {
          "id": "extractFields",
          "options": {
            "delimiter": ",",
            "format": "json",
            "source": "Compliant"
          }
        }
      ],
      "type": "stat"
    },
    {
      "datasource": {
        "type": "yesoreyeram-infinity-datasource",
        "uid": "cftduzurashz4f"
      },
      "fieldConfig": {
        "defaults": {
          "color": {
            "fixedColor": "red",
            "mode": "fixed"
          },
          "mappings": [],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "green",
                "value": 0
              },
              {
                "color": "red",
                "value": 80
              }
            ]
          }
        },
        "overrides": []
      },
      "gridPos": {
        "h": 4,
        "w": 3,
        "x": 18,
        "y": 0
      },
      "id": 10,
      "options": {
        "colorMode": "value",
        "graphMode": "area",
        "justifyMode": "auto",
        "orientation": "auto",
        "percentChangeColorMode": "standard",
        "reduceOptions": {
          "calcs": [
            "lastNotNull"
          ],
          "fields": "/^NonCompliant$/",
          "values": false
        },
        "showPercentChange": false,
        "textMode": "auto",
        "wideLayout": true
      },
      "pluginVersion": "12.4.13",
      "targets": [
        {
          "columns": [],
          "datasource": {
            "type": "yesoreyeram-infinity-datasource",
            "uid": "cftduzurashz4f"
          },
          "filters": [],
          "format": "table",
          "global_query_id": "",
          "parser": "backend",
          "refId": "A",
          "root_selector": "",
          "source": "url",
          "type": "json",
          "url": "https://NAME-OF-THE-APP-SERVICE-xxxxxxxxxxxxxxxxxxxxxxxxxxx.switzerlandnorth-01.azurewebsites.net/api/FUNCTION-NAME?code=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
          "url_options": {
            "data": "",
            "method": "GET"
          }
        }
      ],
      "title": "TOTAL NON-COMPLIANT DEVICES",
      "transformations": [
        {
          "id": "extractFields",
          "options": {
            "delimiter": ",",
            "format": "json",
            "source": "NonCompliant"
          }
        }
      ],
      "type": "stat"
    },
    {
      "datasource": {
        "type": "yesoreyeram-infinity-datasource",
        "uid": "cftduzurashz4f"
      },
      "fieldConfig": {
        "defaults": {
          "color": {
            "fixedColor": "dark-yellow",
            "mode": "fixed"
          },
          "mappings": [],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "green",
                "value": 0
              },
              {
                "color": "red",
                "value": 80
              }
            ]
          }
        },
        "overrides": []
      },
      "gridPos": {
        "h": 4,
        "w": 3,
        "x": 21,
        "y": 0
      },
      "id": 11,
      "options": {
        "colorMode": "value",
        "graphMode": "area",
        "justifyMode": "auto",
        "orientation": "auto",
        "percentChangeColorMode": "standard",
        "reduceOptions": {
          "calcs": [
            "lastNotNull"
          ],
          "fields": "/^NotEvaluated$/",
          "values": false
        },
        "showPercentChange": false,
        "textMode": "auto",
        "wideLayout": true
      },
      "pluginVersion": "12.4.13",
      "targets": [
        {
          "columns": [],
          "datasource": {
            "type": "yesoreyeram-infinity-datasource",
            "uid": "cftduzurashz4f"
          },
          "filters": [],
          "format": "table",
          "global_query_id": "",
          "parser": "backend",
          "refId": "A",
          "root_selector": "",
          "source": "url",
          "type": "json",
          "url": "https://NAME-OF-THE-APP-SERVICE-xxxxxxxxxxxxxxxxxxxxxxxxxxx.switzerlandnorth-01.azurewebsites.net/api/FUNCTION-NAME?code=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
          "url_options": {
            "data": "",
            "method": "GET"
          }
        }
      ],
      "title": "TOTAL NOT EVALUATED DEVICES",
      "transformations": [
        {
          "id": "extractFields",
          "options": {
            "delimiter": ",",
            "format": "json",
            "source": "NotEvaluated"
          }
        }
      ],
      "type": "stat"
    },
    {
      "datasource": {
        "type": "yesoreyeram-infinity-datasource",
        "uid": "cftduzurashz4f"
      },
      "fieldConfig": {
        "defaults": {
          "color": {
            "fixedColor": "dark-blue",
            "mode": "fixed"
          },
          "mappings": [],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "green",
                "value": 0
              },
              {
                "color": "red",
                "value": 80
              }
            ]
          }
        },
        "overrides": []
      },
      "gridPos": {
        "h": 3,
        "w": 4,
        "x": 0,
        "y": 4
      },
      "id": 1,
      "options": {
        "colorMode": "value",
        "graphMode": "area",
        "justifyMode": "auto",
        "orientation": "auto",
        "percentChangeColorMode": "standard",
        "reduceOptions": {
          "calcs": [
            "lastNotNull"
          ],
          "fields": "/^TotalDevices$/",
          "values": false
        },
        "showPercentChange": false,
        "textMode": "auto",
        "wideLayout": true
      },
      "pluginVersion": "12.4.13",
      "targets": [
        {
          "columns": [],
          "datasource": {
            "type": "yesoreyeram-infinity-datasource",
            "uid": "cftduzurashz4f"
          },
          "filters": [],
          "format": "table",
          "global_query_id": "",
          "parser": "backend",
          "refId": "A",
          "root_selector": "",
          "source": "url",
          "type": "json",
          "url": "https://NAME-OF-THE-APP-SERVICE-xxxxxxxxxxxxxxxxxxxxxxxxxxx.switzerlandnorth-01.azurewebsites.net/api/FUNCTION-NAME?code=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
          "url_options": {
            "data": "",
            "method": "GET"
          }
        }
      ],
      "title": "TOTAL DEVICES",
      "transformations": [
        {
          "id": "extractFields",
          "options": {
            "delimiter": ",",
            "format": "json",
            "source": "TotalDevices"
          }
        }
      ],
      "type": "stat"
    },
    {
      "datasource": {
        "type": "yesoreyeram-infinity-datasource",
        "uid": "cftduzurashz4f"
      },
      "fieldConfig": {
        "defaults": {
          "color": {
            "fixedColor": "dark-blue",
            "mode": "fixed"
          },
          "mappings": [],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "green",
                "value": 0
              },
              {
                "color": "red",
                "value": 80
              }
            ]
          }
        },
        "overrides": []
      },
      "gridPos": {
        "h": 3,
        "w": 4,
        "x": 4,
        "y": 4
      },
      "id": 2,
      "options": {
        "colorMode": "value",
        "graphMode": "area",
        "justifyMode": "auto",
        "orientation": "auto",
        "percentChangeColorMode": "standard",
        "reduceOptions": {
          "calcs": [
            "lastNotNull"
          ],
          "fields": "/^Windows$/",
          "values": false
        },
        "showPercentChange": false,
        "textMode": "auto",
        "wideLayout": true
      },
      "pluginVersion": "12.4.13",
      "targets": [
        {
          "columns": [],
          "datasource": {
            "type": "yesoreyeram-infinity-datasource",
            "uid": "cftduzurashz4f"
          },
          "filters": [],
          "format": "table",
          "global_query_id": "",
          "parser": "backend",
          "refId": "A",
          "root_selector": "",
          "source": "url",
          "type": "json",
          "url": "https://NAME-OF-THE-APP-SERVICE-xxxxxxxxxxxxxxxxxxxxxxxxxxx.switzerlandnorth-01.azurewebsites.net/api/FUNCTION-NAME?code=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
          "url_options": {
            "data": "",
            "method": "GET"
          }
        }
      ],
      "title": "TOTAL WINDOWS DEVICES",
      "transformations": [
        {
          "id": "extractFields",
          "options": {
            "delimiter": ",",
            "format": "json",
            "source": "Windows"
          }
        }
      ],
      "type": "stat"
    },
    {
      "datasource": {
        "type": "yesoreyeram-infinity-datasource",
        "uid": "cftduzurashz4f"
      },
      "fieldConfig": {
        "defaults": {
          "color": {
            "fixedColor": "dark-blue",
            "mode": "fixed"
          },
          "mappings": [],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "green",
                "value": 0
              },
              {
                "color": "red",
                "value": 80
              }
            ]
          }
        },
        "overrides": []
      },
      "gridPos": {
        "h": 3,
        "w": 4,
        "x": 8,
        "y": 4
      },
      "id": 5,
      "options": {
        "colorMode": "value",
        "graphMode": "area",
        "justifyMode": "auto",
        "orientation": "auto",
        "percentChangeColorMode": "standard",
        "reduceOptions": {
          "calcs": [
            "lastNotNull"
          ],
          "fields": "/^Linux$/",
          "values": false
        },
        "showPercentChange": false,
        "textMode": "auto",
        "wideLayout": true
      },
      "pluginVersion": "12.4.13",
      "targets": [
        {
          "columns": [],
          "datasource": {
            "type": "yesoreyeram-infinity-datasource",
            "uid": "cftduzurashz4f"
          },
          "filters": [],
          "format": "table",
          "global_query_id": "",
          "parser": "backend",
          "refId": "A",
          "root_selector": "",
          "source": "url",
          "type": "json",
          "url": "https://NAME-OF-THE-APP-SERVICE-xxxxxxxxxxxxxxxxxxxxxxxxxxx.switzerlandnorth-01.azurewebsites.net/api/FUNCTION-NAME?code=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
          "url_options": {
            "data": "",
            "method": "GET"
          }
        }
      ],
      "title": "TOTAL LINUX DEVICES",
      "transformations": [
        {
          "id": "extractFields",
          "options": {
            "delimiter": ",",
            "format": "json",
            "source": "Linux"
          }
        }
      ],
      "type": "stat"
    },
    {
      "datasource": {
        "type": "yesoreyeram-infinity-datasource",
        "uid": "cftduzurashz4f"
      },
      "fieldConfig": {
        "defaults": {
          "color": {
            "fixedColor": "dark-blue",
            "mode": "fixed"
          },
          "mappings": [],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "green",
                "value": 0
              },
              {
                "color": "red",
                "value": 80
              }
            ]
          }
        },
        "overrides": []
      },
      "gridPos": {
        "h": 3,
        "w": 4,
        "x": 12,
        "y": 4
      },
      "id": 4,
      "options": {
        "colorMode": "value",
        "graphMode": "area",
        "justifyMode": "auto",
        "orientation": "auto",
        "percentChangeColorMode": "standard",
        "reduceOptions": {
          "calcs": [
            "lastNotNull"
          ],
          "fields": "/^Android$/",
          "values": false
        },
        "showPercentChange": false,
        "textMode": "auto",
        "wideLayout": true
      },
      "pluginVersion": "12.4.13",
      "targets": [
        {
          "columns": [],
          "datasource": {
            "type": "yesoreyeram-infinity-datasource",
            "uid": "cftduzurashz4f"
          },
          "filters": [],
          "format": "table",
          "global_query_id": "",
          "parser": "backend",
          "refId": "A",
          "root_selector": "",
          "source": "url",
          "type": "json",
          "url": "https://NAME-OF-THE-APP-SERVICE-xxxxxxxxxxxxxxxxxxxxxxxxxxx.switzerlandnorth-01.azurewebsites.net/api/FUNCTION-NAME?code=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
          "url_options": {
            "data": "",
            "method": "GET"
          }
        }
      ],
      "title": "TOTAL ANDROID DEVICES",
      "transformations": [
        {
          "id": "extractFields",
          "options": {
            "delimiter": ",",
            "format": "json",
            "source": "Android"
          }
        }
      ],
      "type": "stat"
    },
    {
      "datasource": {
        "type": "yesoreyeram-infinity-datasource",
        "uid": "cftduzurashz4f"
      },
      "fieldConfig": {
        "defaults": {
          "color": {
            "fixedColor": "dark-blue",
            "mode": "fixed"
          },
          "mappings": [],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "green",
                "value": 0
              },
              {
                "color": "red",
                "value": 80
              }
            ]
          }
        },
        "overrides": []
      },
      "gridPos": {
        "h": 3,
        "w": 4,
        "x": 16,
        "y": 4
      },
      "id": 6,
      "options": {
        "colorMode": "value",
        "graphMode": "area",
        "justifyMode": "auto",
        "orientation": "auto",
        "percentChangeColorMode": "standard",
        "reduceOptions": {
          "calcs": [
            "lastNotNull"
          ],
          "fields": "/^macOS$/",
          "values": false
        },
        "showPercentChange": false,
        "textMode": "auto",
        "wideLayout": true
      },
      "pluginVersion": "12.4.13",
      "targets": [
        {
          "columns": [],
          "datasource": {
            "type": "yesoreyeram-infinity-datasource",
            "uid": "cftduzurashz4f"
          },
          "filters": [],
          "format": "table",
          "global_query_id": "",
          "parser": "backend",
          "refId": "A",
          "root_selector": "",
          "source": "url",
          "type": "json",
          "url": "https://NAME-OF-THE-APP-SERVICE-xxxxxxxxxxxxxxxxxxxxxxxxxxx.switzerlandnorth-01.azurewebsites.net/api/FUNCTION-NAME?code=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
          "url_options": {
            "data": "",
            "method": "GET"
          }
        }
      ],
      "title": "TOTAL MAC DEVICES",
      "transformations": [
        {
          "id": "extractFields",
          "options": {
            "delimiter": ",",
            "format": "json",
            "source": "macOS"
          }
        }
      ],
      "type": "stat"
    },
    {
      "datasource": {
        "type": "yesoreyeram-infinity-datasource",
        "uid": "cftduzurashz4f"
      },
      "fieldConfig": {
        "defaults": {
          "color": {
            "fixedColor": "dark-blue",
            "mode": "fixed"
          },
          "mappings": [],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "green",
                "value": 0
              },
              {
                "color": "red",
                "value": 80
              }
            ]
          }
        },
        "overrides": []
      },
      "gridPos": {
        "h": 3,
        "w": 4,
        "x": 20,
        "y": 4
      },
      "id": 3,
      "options": {
        "colorMode": "value",
        "graphMode": "area",
        "justifyMode": "auto",
        "orientation": "auto",
        "percentChangeColorMode": "standard",
        "reduceOptions": {
          "calcs": [
            "lastNotNull"
          ],
          "fields": "/^AppleMobile$/",
          "values": false
        },
        "showPercentChange": false,
        "textMode": "auto",
        "wideLayout": true
      },
      "pluginVersion": "12.4.13",
      "targets": [
        {
          "columns": [],
          "datasource": {
            "type": "yesoreyeram-infinity-datasource",
            "uid": "cftduzurashz4f"
          },
          "filters": [],
          "format": "table",
          "global_query_id": "",
          "parser": "backend",
          "refId": "A",
          "root_selector": "",
          "source": "url",
          "type": "json",
          "url": "https://NAME-OF-THE-APP-SERVICE-xxxxxxxxxxxxxxxxxxxxxxxxxxx.switzerlandnorth-01.azurewebsites.net/api/FUNCTION-NAME?code=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
          "url_options": {
            "data": "",
            "method": "GET"
          }
        }
      ],
      "title": "TOTAL APPLE DEVICES",
      "transformations": [
        {
          "id": "extractFields",
          "options": {
            "delimiter": ",",
            "format": "json",
            "source": "AppleMobile"
          }
        }
      ],
      "type": "stat"
    },
    {
      "datasource": {
        "type": "yesoreyeram-infinity-datasource",
        "uid": "cftduzurashz4f"
      },
      "fieldConfig": {
        "defaults": {
          "color": {
            "mode": "thresholds"
          },
          "custom": {
            "align": "left",
            "cellOptions": {
              "type": "auto"
            },
            "footer": {
              "reducers": []
            },
            "inspect": false
          },
          "mappings": [],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "green",
                "value": 0
              },
              {
                "color": "red",
                "value": 80
              }
            ]
          }
        },
        "overrides": [
          {
            "matcher": {
              "id": "byName",
              "options": "LastCheckIn"
            },
            "properties": [
              {
                "id": "custom.width",
                "value": 272
              },
              {
                "id": "unit",
                "value": "dateTimeAsIso"
              }
            ]
          },
          {
            "matcher": {
              "id": "byName",
              "options": "PrimaryUPN"
            },
            "properties": [
              {
                "id": "custom.width",
                "value": 362
              }
            ]
          },
          {
            "matcher": {
              "id": "byName",
              "options": "Ownership"
            },
            "properties": [
              {
                "id": "custom.width",
                "value": 288
              }
            ]
          },
          {
            "matcher": {
              "id": "byName",
              "options": "DeviceName"
            },
            "properties": [
              {
                "id": "custom.width",
                "value": 463
              }
            ]
          },
          {
            "matcher": {
              "id": "byName",
              "options": "Compliance"
            },
            "properties": [
              {
                "id": "custom.width",
                "value": 270
              }
            ]
          },
          {
            "matcher": {
              "id": "byName",
              "options": "OS"
            },
            "properties": [
              {
                "id": "custom.width",
                "value": 232
              }
            ]
          },
          {
            "matcher": {
              "id": "byName",
              "options": "OSVersion"
            },
            "properties": [
              {
                "id": "custom.width",
                "value": 269
              }
            ]
          },
          {
            "matcher": {
              "id": "byName",
              "options": "ManagedBy"
            },
            "properties": [
              {
                "id": "custom.width",
                "value": 325
              }
            ]
          }
        ]
      },
      "gridPos": {
        "h": 12,
        "w": 24,
        "x": 0,
        "y": 7
      },
      "id": 12,
      "options": {
        "cellHeight": "sm",
        "showHeader": true,
        "sortBy": [
          {
            "desc": false,
            "displayName": "Ownership"
          }
        ]
      },
      "pluginVersion": "12.4.13",
      "targets": [
        {
          "columns": [],
          "datasource": {
            "type": "yesoreyeram-infinity-datasource",
            "uid": "cftduzurashz4f"
          },
          "filters": [],
          "format": "table",
          "global_query_id": "",
          "parser": "backend",
          "refId": "A",
          "root_selector": "WindowsInventory[*]",
          "source": "url",
          "type": "json",
          "url": "https://NAME-OF-THE-APP-SERVICE-xxxxxxxxxxxxxxxxxxxxxxxxxxx.switzerlandnorth-01.azurewebsites.net/api/FUNCTION-NAME?code=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
          "url_options": {
            "data": "",
            "method": "GET"
          }
        }
      ],
      "title": "WINDOWS DEVICES NON COMPLIANT INVENTORY",
      "transformations": [
        {
          "id": "organize",
          "options": {
            "excludeByName": {},
            "includeByName": {},
            "indexByName": {
              "Compliance": 1,
              "DeviceName": 0,
              "LastCheckIn": 7,
              "ManagedBy": 4,
              "OS": 2,
              "OSVersion": 3,
              "Ownership": 5,
              "PrimaryUPN": 6
            },
            "renameByName": {}
          }
        },
        {
          "id": "filterByValue",
          "options": {
            "filters": [
              {
                "config": {
                  "id": "equal",
                  "options": {
                    "value": "noncompliant"
                  }
                },
                "fieldName": "Compliance"
              }
            ],
            "match": "any",
            "type": "include"
          }
        }
      ],
      "type": "table"
    },
    {
      "datasource": {
        "type": "yesoreyeram-infinity-datasource",
        "uid": "cftduzurashz4f"
      },
      "fieldConfig": {
        "defaults": {
          "color": {
            "mode": "thresholds"
          },
          "custom": {
            "align": "left",
            "cellOptions": {
              "type": "auto"
            },
            "footer": {
              "reducers": []
            },
            "inspect": false
          },
          "mappings": [],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "green",
                "value": 0
              },
              {
                "color": "red",
                "value": 80
              }
            ]
          }
        },
        "overrides": [
          {
            "matcher": {
              "id": "byName",
              "options": "LastCheckIn"
            },
            "properties": [
              {
                "id": "custom.width",
                "value": 272
              },
              {
                "id": "unit",
                "value": "dateTimeAsIso"
              }
            ]
          },
          {
            "matcher": {
              "id": "byName",
              "options": "PrimaryUPN"
            },
            "properties": [
              {
                "id": "custom.width",
                "value": 365
              }
            ]
          },
          {
            "matcher": {
              "id": "byName",
              "options": "Ownership"
            },
            "properties": [
              {
                "id": "custom.width",
                "value": 286
              }
            ]
          },
          {
            "matcher": {
              "id": "byName",
              "options": "DeviceName"
            },
            "properties": [
              {
                "id": "custom.width",
                "value": 460
              }
            ]
          },
          {
            "matcher": {
              "id": "byName",
              "options": "Compliance"
            },
            "properties": [
              {
                "id": "custom.width",
                "value": 270
              }
            ]
          },
          {
            "matcher": {
              "id": "byName",
              "options": "OS"
            },
            "properties": [
              {
                "id": "custom.width",
                "value": 235
              }
            ]
          },
          {
            "matcher": {
              "id": "byName",
              "options": "OSVersion"
            },
            "properties": [
              {
                "id": "custom.width",
                "value": 269
              }
            ]
          },
          {
            "matcher": {
              "id": "byName",
              "options": "ManagedBy"
            },
            "properties": [
              {
                "id": "custom.width",
                "value": 326
              }
            ]
          }
        ]
      },
      "gridPos": {
        "h": 5,
        "w": 24,
        "x": 0,
        "y": 19
      },
      "id": 13,
      "options": {
        "cellHeight": "sm",
        "showHeader": true
      },
      "pluginVersion": "12.4.13",
      "targets": [
        {
          "columns": [],
          "datasource": {
            "type": "yesoreyeram-infinity-datasource",
            "uid": "cftduzurashz4f"
          },
          "filters": [],
          "format": "table",
          "global_query_id": "",
          "parser": "backend",
          "refId": "A",
          "root_selector": "AndroidInventory[*]",
          "source": "url",
          "type": "json",
          "url": "https://NAME-OF-THE-APP-SERVICE-xxxxxxxxxxxxxxxxxxxxxxxxxxx.switzerlandnorth-01.azurewebsites.net/api/FUNCTION-NAME?code=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
          "url_options": {
            "data": "",
            "method": "GET"
          }
        }
      ],
      "title": "ANDROID DEVICES NON COMPLIANT INVENTORY",
      "transformations": [
        {
          "id": "organize",
          "options": {
            "excludeByName": {},
            "includeByName": {},
            "indexByName": {
              "Compliance": 1,
              "DeviceName": 0,
              "LastCheckIn": 7,
              "ManagedBy": 4,
              "OS": 2,
              "OSVersion": 3,
              "Ownership": 5,
              "PrimaryUPN": 6
            },
            "renameByName": {}
          }
        },
        {
          "id": "filterByValue",
          "options": {
            "filters": [
              {
                "config": {
                  "id": "equal",
                  "options": {
                    "value": "noncompliant"
                  }
                },
                "fieldName": "Compliance"
              }
            ],
            "match": "any",
            "type": "include"
          }
        }
      ],
      "type": "table"
    },
    {
      "datasource": {
        "type": "yesoreyeram-infinity-datasource",
        "uid": "cftduzurashz4f"
      },
      "fieldConfig": {
        "defaults": {
          "color": {
            "mode": "thresholds"
          },
          "custom": {
            "align": "left",
            "cellOptions": {
              "type": "auto"
            },
            "footer": {
              "reducers": []
            },
            "inspect": false
          },
          "mappings": [],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "green",
                "value": 0
              },
              {
                "color": "red",
                "value": 80
              }
            ]
          }
        },
        "overrides": [
          {
            "matcher": {
              "id": "byName",
              "options": "LastCheckIn"
            },
            "properties": [
              {
                "id": "custom.width",
                "value": 272
              },
              {
                "id": "unit",
                "value": "dateTimeAsIso"
              }
            ]
          },
          {
            "matcher": {
              "id": "byName",
              "options": "PrimaryUPN"
            },
            "properties": [
              {
                "id": "custom.width",
                "value": 366
              }
            ]
          },
          {
            "matcher": {
              "id": "byName",
              "options": "Ownership"
            },
            "properties": [
              {
                "id": "custom.width",
                "value": 286
              }
            ]
          },
          {
            "matcher": {
              "id": "byName",
              "options": "DeviceName"
            },
            "properties": [
              {
                "id": "custom.width",
                "value": 460
              }
            ]
          },
          {
            "matcher": {
              "id": "byName",
              "options": "Compliance"
            },
            "properties": [
              {
                "id": "custom.width",
                "value": 270
              }
            ]
          },
          {
            "matcher": {
              "id": "byName",
              "options": "OS"
            },
            "properties": [
              {
                "id": "custom.width",
                "value": 235
              }
            ]
          },
          {
            "matcher": {
              "id": "byName",
              "options": "OSVersion"
            },
            "properties": [
              {
                "id": "custom.width",
                "value": 269
              }
            ]
          },
          {
            "matcher": {
              "id": "byName",
              "options": "ManagedBy"
            },
            "properties": [
              {
                "id": "custom.width",
                "value": 326
              }
            ]
          }
        ]
      },
      "gridPos": {
        "h": 12,
        "w": 24,
        "x": 0,
        "y": 24
      },
      "id": 15,
      "options": {
        "cellHeight": "sm",
        "showHeader": true
      },
      "pluginVersion": "12.4.13",
      "targets": [
        {
          "columns": [],
          "datasource": {
            "type": "yesoreyeram-infinity-datasource",
            "uid": "cftduzurashz4f"
          },
          "filters": [],
          "format": "table",
          "global_query_id": "",
          "parser": "backend",
          "refId": "A",
          "root_selector": "AppleInventory[*]",
          "source": "url",
          "type": "json",
          "url": "https://NAME-OF-THE-APP-SERVICE-xxxxxxxxxxxxxxxxxxxxxxxxxxx.switzerlandnorth-01.azurewebsites.net/api/FUNCTION-NAME?code=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
          "url_options": {
            "data": "",
            "method": "GET"
          }
        }
      ],
      "title": "APPLE DEVICES NON COMPLIANT INVENTORY",
      "transformations": [
        {
          "id": "organize",
          "options": {
            "excludeByName": {},
            "includeByName": {},
            "indexByName": {
              "Compliance": 1,
              "DeviceName": 0,
              "LastCheckIn": 7,
              "ManagedBy": 4,
              "OS": 2,
              "OSVersion": 3,
              "Ownership": 5,
              "PrimaryUPN": 6
            },
            "renameByName": {}
          }
        },
        {
          "id": "filterByValue",
          "options": {
            "filters": [
              {
                "config": {
                  "id": "equal",
                  "options": {
                    "value": "noncompliant"
                  }
                },
                "fieldName": "Compliance"
              }
            ],
            "match": "any",
            "type": "include"
          }
        }
      ],
      "type": "table"
    }
  ],
  "preload": false,
  "schemaVersion": 42,
  "tags": [],
  "templating": {
    "list": []
  },
  "time": {
    "from": "now-6h",
    "to": "now"
  },
  "timepicker": {},
  "timezone": "browser",
  "title": "End-User-Devices-Dashboard",
  "uid": "mik7qb4",
  "version": 6,
  "weekStart": ""
}
```