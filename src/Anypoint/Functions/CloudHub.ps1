# CloudHub API
class CloudHub {

    static [string] $BasePath = "/cloudhub/api/v2"

    static [string] Alerts($alertId) {
        return [CloudHub]::BasePath + "/alerts/$alertId"
    }
}

function Get-CloudHubAlert {
    [CmdletBinding()]
    param (
        [Parameter(ParameterSetName = "Id", Mandatory = $true)][guid] $AlertId,
        [Parameter(ParameterSetName = "Query", Mandatory = $false)][string] $ApplicationName,
        [Parameter(ParameterSetName = "Query", Mandatory = $false)][guid] $EnvironmentId = $Script:Context.Environment.id,
        [Parameter(ParameterSetName = "Query", Mandatory = $false)][int] $Offset,
        [Parameter(ParameterSetName = "Query", Mandatory = $false)][int] $Limit
    )

    process {
        $params = @{
            resource = $ApplicationName
            offset   = $PSBoundParameters["Offset"]
            limit    = $PSBoundParameters["Limit"]
        }

        $path = [CloudHub]::Alerts($AlertId)
        Invoke-AnypointApi -Method Get -Path $path -QueryParameters $params -EnvironmentId $EnvironmentId | Expand-Property -propertyName "data"
    }
}


Export-ModuleMember -Function `
    Get-CloudHubAlert