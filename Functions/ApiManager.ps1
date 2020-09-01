# API Manager API
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
        [Parameter(Mandatory = $false)][guid] $OrganizationId = $Script:Context.BusinessGroup.id,
        [Parameter(Mandatory = $false)][guid] $EnvironmentId = $Script:Context.Environment.id,
        [Parameter(Mandatory = $false)][string] $AssetId,
        [Parameter(Mandatory = $false)][string] $AutodiscoveryApiName,
        [Parameter(Mandatory = $false)][string] $AutodiscoveryInstanceName
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
        [Parameter(Mandatory = $false)][guid] $OrganizationId = $Script:Context.BusinessGroup.id,
        [Parameter(Mandatory = $false)][guid] $EnvironmentId = $Script:Context.Environment.id,
        [Parameter(Mandatory = $true)][int] $Id
    )

    process {
        $Script:Client.Get([ApiManager]::Apis($OrganizationId, $EnvironmentId) + "/$Id")
    }
}

function Get-ApApiPolicy {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)][guid] $OrganizationId = $Script:Context.BusinessGroup.id,
        [Parameter(Mandatory = $false)][guid] $EnvironmentId = $Script:Context.Environment.id,
        [Parameter(Mandatory = $true)][int] $ApiInstanceId
    )

    process {
        $Script:Client.Get([ApiManager]::Policies($OrganizationId, $EnvironmentId, $ApiInstanceId))
    }
}

function Get-ApApiAlert {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)][guid] $OrganizationId = $Script:Context.BusinessGroup.id,
        [Parameter(Mandatory = $false)][guid] $EnvironmentId = $Script:Context.Environment.id,
        [Parameter(Mandatory = $true)][int] $ApiInstanceId,
        [Parameter(Mandatory = $false)][guid] $Id
    )

    process {
        $Script:Client.Get([ApiManager]::Alerts($OrganizationId, $EnvironmentId, $ApiInstanceId) + "/$Id")
    }
}

function Set-ApApiAlert {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)][guid] $OrganizationId = $Script:Context.BusinessGroup.id,
        [Parameter(Mandatory = $false)][guid] $EnvironmentId = $Script:Context.Environment.id,
        [Parameter(Mandatory = $true)][int] $ApiInstanceId,
        [Parameter(Mandatory = $true)][guid] $Id,
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)][object] $InputObject
    )

    process {
        $Script:Client.Patch([ApiManager]::Alerts($OrganizationId, $EnvironmentId, $ApiInstanceId) + "/$AlertId", $InputObject)
    }
}


Export-ModuleMember -Function `
    Get-ApApi, 
    Get-ApApiInstance,
    Get-ApApiPolicy, 
    Get-ApApiAlert, Set-ApApiAlert
