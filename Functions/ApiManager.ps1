﻿# API Manager API
class ApiManager {

    static [string] $BasePath = "/apimanager/api/v1"

    static [string] Organizations($organizationId) {
        return [ApiManager]::BasePath + "/organizations/$organizationId"
    }

    static [string] Environments($organizationId, $environmentsId) {
        return [ApiManager]::BasePath + "/organizations/$organizationId/environments/$environmentsId"
    }

    static [string] Apis($organizationId, $environmentsId) {
        return [ApiManager]::Environments($organizationId, $environmentsId) + "/apis"
    }

    static [string] Policies($organizationId, $environmentsId, $environmentApiId) {
        return [ApiManager]::Environments($organizationId, $environmentsId) + "/apis/$environmentApiId/policies"
    }

    static [string] Alerts($organizationId, $environmentsId, $environmentApiId) {
        return [ApiManager]::Environments($organizationId, $environmentsId) + "/apis/$environmentApiId/alerts"
    }
}

function Get-ApApi {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)][string] $AssetId,
        [Parameter(Mandatory = $false)][string] $AutodiscoveryApiName,
        [Parameter(Mandatory = $false)][string] $AutodiscoveryInstanceName,
        [Parameter(Mandatory = $false)][guid] $EnvironmentId = $Script:Context.Environment.id,
        [Parameter(Mandatory = $false)][guid] $OrganizationId = $Script:Context.BusinessGroup.id
    )

    process {
        $params = @{
            assetId                   = $AssetId;
            autodiscoveryApiName      = $AutodiscoveryApiName;
            autodiscoveryInstanceName = $AutodiscoveryInstanceName;
        }
        $Script:Client.Get([ApiManager]::Apis($OrganizationId, $EnvironmentId), $params) | Step-Property -propertyName "assets"
    }
}

function Get-ApApiInstance {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][int] $ApiInstanceId,
        [Parameter(Mandatory = $false)][guid] $EnvironmentId = $Script:Context.Environment.id,
        [Parameter(Mandatory = $false)][guid] $OrganizationId = $Script:Context.BusinessGroup.id
    )

    process {
        $Script:Client.Get([ApiManager]::Apis($OrganizationId, $EnvironmentId) + "/$ApiInstanceId")
    }
}

function Get-ApApiPolicy {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][int] $ApiInstanceId,
        [Parameter(Mandatory = $false)][guid] $EnvironmentId = $Script:Context.Environment.id,
        [Parameter(Mandatory = $false)][guid] $OrganizationId = $Script:Context.BusinessGroup.id
    )

    process {
        $Script:Client.Get([ApiManager]::Policies($OrganizationId, $EnvironmentId, $ApiInstanceId)) | Step-Property -propertyName "policies"
    }
}

function Get-ApApiAlert {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][int] $ApiInstanceId,
        [Parameter(Mandatory = $false)][guid] $AlertId,
        [Parameter(Mandatory = $false)][guid] $EnvironmentId = $Script:Context.Environment.id,
        [Parameter(Mandatory = $false)][guid] $OrganizationId = $Script:Context.BusinessGroup.id
    )

    process {
        $Script:Client.Get([ApiManager]::Alerts($OrganizationId, $EnvironmentId, $ApiInstanceId) + "/$AlertId")
    }
}

function Set-ApApiAlert {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][int] $ApiInstanceId,
        [Parameter(Mandatory = $true)][guid] $AlertId,
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)][object] $InputObject,
        [Parameter(Mandatory = $false)][guid] $EnvironmentId = $Script:Context.Environment.id,
        [Parameter(Mandatory = $false)][guid] $OrganizationId = $Script:Context.BusinessGroup.id
    )

    process {
        $Script:Client.Patch([ApiManager]::Alerts($OrganizationId, $EnvironmentId, $ApiInstanceId) + "/$AlertId", $InputObject)
    }
}


Export-ModuleMember -Function `
    Get-ApApi, `
    Get-ApApiInstance, `
    Get-ApApiPolicy, `
    Get-ApApiAlert, Set-ApApiAlert
