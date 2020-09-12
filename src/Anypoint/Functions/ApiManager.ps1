# API Manager API
class ApiManager {

    static [string] $BasePath = "/apimanager/api/v1"

    static [string] Organizations($orgid) {
        return [ApiManager]::BasePath + "/organizations/$orgid"
    }

    static [string] Environments($orgid, $environmentsId) {
        return [ApiManager]::BasePath + "/organizations/$orgid/environments/$environmentsId"
    }

    static [string] Apis($orgid, $environmentsId) {
        return [ApiManager]::BasePath + "/organizations/$orgid/environments/$environmentsId/apis"
    }

    static [string] Apis($orgid, $environmentsId, $environmentApiId) {
        return [ApiManager]::BasePath + "/organizations/$orgid/environments/$environmentsId/apis/$environmentApiId"
    }

    static [string] Policies($orgid, $environmentsId, $environmentApiId) {
        return [ApiManager]::BasePath + "/organizations/$orgid/environments/$environmentsId/apis/$environmentApiId/policies"
    }

    static [string] Alerts($orgid, $environmentsId, $environmentApiId, $alertId) {
        return [ApiManager]::BasePath + "/organizations/$orgid/environments/$environmentsId/apis/$environmentApiId/alerts/$alertId"
    }
}

function Get-Api {
    [CmdletBinding(DefaultParameterSetName = "Query")]
    param (
        [Parameter(ParameterSetName = "Query", Mandatory = $false)][string] $AssetId,
        [Parameter(ParameterSetName = "Query", Mandatory = $false)][string] $AutodiscoveryApiName,
        [Parameter(ParameterSetName = "Query", Mandatory = $false)][string] $AutodiscoveryInstanceName,
        [Parameter(ParameterSetName = "Query", Mandatory = $false)][guid]   $EnvironmentId = $Script:Context.Environment.id,
        [Parameter(ParameterSetName = "Query", Mandatory = $false)][guid]   $OrganizationId = $Script:Context.BusinessGroup.id,
        [Parameter(ParameterSetName = "Pipeline", Mandatory = $true, ValueFromPipeline = $true)][object] $Environment
    )

    process {
        if ([bool]$Environment) {
            $OrganizationId = GetRequiredValue $Environment "organizationId"
            $EnvironmentId = GetRequiredValue $Environment "id"
        }

        $params = @{
            assetId                   = $AssetId;
            autodiscoveryApiName      = $AutodiscoveryApiName;
            autodiscoveryInstanceName = $AutodiscoveryInstanceName;
        }

        $path = [ApiManager]::Apis($OrganizationId, $EnvironmentId)
        Invoke-AnypointApi -Method Get -Path $path -QueryParameters $params | Expand-Property -propertyName "assets"
    }
}

function Get-ApiInstance {
    [CmdletBinding()]
    param (
        [Parameter(ParameterSetName = "Query", Mandatory = $true)][int]     $ApiInstanceId,
        [Parameter(ParameterSetName = "Query", Mandatory = $false)][switch] $IncludeTlsContexts,
        [Parameter(ParameterSetName = "Query", Mandatory = $false)][guid]   $EnvironmentId = $Script:Context.Environment.id,
        [Parameter(ParameterSetName = "Query", Mandatory = $false)][guid]   $OrganizationId = $Script:Context.BusinessGroup.id,
        [Parameter(ParameterSetName = "Pipeline", Mandatory = $true, ValueFromPipeline = $true)][object] $Api
    )

    process {
        if ([bool]$Api) {
            foreach ($api in $Api.apis) {
                Get-ApiInstance `
                    -ApiInstanceId (GetRequiredValue $api "id") `
                    -OrganizationId (GetRequiredValue $api "organizationId") `
                    -EnvironmentId (GetRequiredValue $api "environmentId") `
                    -IncludeTlsContexts:$IncludeTlsContexts
            }
        }
        else {
            $params = @{
                includeTlsContexts = $IncludeTlsContexts
            }

            $path = [ApiManager]::Apis($OrganizationId, $EnvironmentId, $ApiInstanceId)
            Invoke-AnypointApi -Method Get -Path $path -QueryParameters $params
        }
    }
}

function Get-ApiPolicy {
    [CmdletBinding()]
    param (
        [Parameter(ParameterSetName = "Query", Mandatory = $true)][int] $ApiInstanceId,
        [Parameter(ParameterSetName = "Query", Mandatory = $false)][guid] $EnvironmentId = $Script:Context.Environment.id,
        [Parameter(ParameterSetName = "Query", Mandatory = $false)][guid] $OrganizationId = $Script:Context.BusinessGroup.id,
        [Parameter(ParameterSetName = "Pipeline", Mandatory = $true, ValueFromPipeline = $true)][object] $ApiInstance
    )

    process {
        if ([bool]$ApiInstance) {
            $OrganizationId = GetRequiredValue $ApiInstance "organizationId"
            $EnvironmentId = GetRequiredValue $ApiInstance "environmentId"
            $ApiInstanceId = GetRequiredValue $ApiInstance "id"
        }

        $path = [ApiManager]::Policies($OrganizationId, $EnvironmentId, $ApiInstanceId)
        Invoke-AnypointApi -Method Get -Path $path | Expand-Property -propertyName "policies"
    }
}

function Get-ApiAlert {
    [CmdletBinding()]
    param (
        [Parameter(ParameterSetName = "Query", Mandatory = $true)][int] $ApiInstanceId,
        [Parameter(ParameterSetName = "Query", Mandatory = $false)][guid] $AlertId,
        [Parameter(ParameterSetName = "Query", Mandatory = $false)][guid] $EnvironmentId = $Script:Context.Environment.id,
        [Parameter(ParameterSetName = "Query", Mandatory = $false)][guid] $OrganizationId = $Script:Context.BusinessGroup.id,
        [Parameter(ParameterSetName = "Pipeline", Mandatory = $true, ValueFromPipeline = $true)][object] $ApiInstance
    )

    process {
        if ([bool]$ApiInstance) {
            $OrganizationId = GetRequiredValue $ApiInstance "organizationId"
            $EnvironmentId = GetRequiredValue $ApiInstance "environmentId"
            $ApiInstanceId = GetRequiredValue $ApiInstance "id"
        }

        $path = [ApiManager]::Alerts($OrganizationId, $EnvironmentId, $ApiInstanceId, $AlertId)
        Invoke-AnypointApi -Method Get -Path $path
    }
}

function Update-ApiAlert {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)][object] $InputObject
    )

    process {
        $OrganizationId = GetRequiredValue $InputObject "organizationId"
        $EnvironmentId = GetRequiredValue $InputObject "environmentId"
        $ApiInstanceId = GetRequiredValue $InputObject "api.id"
        $AlertId = GetRequiredValue $InputObject "id"

        $path = [ApiManager]::Alerts($OrganizationId, $EnvironmentId, $ApiInstanceId, $AlertId)
        Invoke-AnypointApi -Method Patch -Path $path -Body $InputObject
    }
}


Export-ModuleMember -Function `
    Get-Api, `
    Get-ApiInstance, `
    Get-ApiPolicy, `
    Get-ApiAlert, Update-ApiAlert
