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