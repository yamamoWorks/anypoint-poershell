# CloudHub API
class CloudHub {

    static [string] $BasePath = "/cloudhub/api/v2"

    static [string] Alerts() {
        return [CloudHub]::BasePath + "/alerts"
    }
}

function Get-CloudHubAlert {
    [CmdletBinding()]
    param (
        [Parameter(ParameterSetName = "Single", Mandatory = $true)][guid] $AlertId,
        [Parameter(ParameterSetName = "Multiple", Mandatory = $false)][string] $ApplicationName,
        [Parameter(ParameterSetName = "Multiple", Mandatory = $false)][guid] $EnvironmentId = $Script:Context.Environment.id,
        [Parameter(ParameterSetName = "Multiple", Mandatory = $false)][int] $Offset,
        [Parameter(ParameterSetName = "Multiple", Mandatory = $false)][int] $Limit
    )

    process {
        $params = @{
            resource = $ApplicationName
            offset   = $PSBoundParameters["Offset"]
            limit    = $PSBoundParameters["Limit"]
        }

        $headers = @{
            "X-ANYPNT-ENV-ID" = $EnvironmentId 
        }

        $Script:Client.Get([CloudHub]::Alerts() + "/$AlertId", $params, $headers) | Expand-Property -propertyName "data"
    }
}


Export-ModuleMember -Function `
    Get-CloudHubAlert