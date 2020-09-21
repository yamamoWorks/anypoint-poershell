# CloudHub API
class CloudHub {

    static [string] $BasePath = "/cloudhub/api/v2"

    static [string] Alerts($alertId) {
        return [CloudHub]::BasePath + "/alerts/$alertId"
    }

    static [string] Applications($domain) {
        return [CloudHub]::BasePath + "/applications/$domain"
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

function Get-CloudHubApplication {
    [CmdletBinding()]
    param (
        [Parameter(ParameterSetName = "Id", Mandatory = $true)][string] $Domain,
        [Parameter(ParameterSetName = "Query", Mandatory = $false)][switch] $RetrieveStatistics,
        [Parameter(ParameterSetName = "Query", Mandatory = $false)][int]    $Period,
        [Parameter(ParameterSetName = "Query", Mandatory = $false)][guid] $EnvironmentId = $Script:Context.Environment.id
    )

    process {
        $params = @{
            retrieveStatistics = $RetrieveStatistics
            period             = $PSBoundParameters["Period"]
        }

        $path = [CloudHub]::Applications($Domain)
        Invoke-AnypointApi -Method Get -Path $path -QueryParameters $params -EnvironmentId $EnvironmentId
    }
}

function Start-CloudHubApplication {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][string[]] $Domains,
        [Parameter(Mandatory = $false)][guid] $EnvironmentId = $Script:Context.Environment.id
    )
    
    process {
        ControlCloudHubApplication -Action START -Domains $Domains -EnvironmentId $EnvironmentId
    }
}

function Stop-CloudHubApplication {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][string[]] $Domains,
        [Parameter(Mandatory = $false)][guid] $EnvironmentId = $Script:Context.Environment.id
    )
    
    process {
        ControlCloudHubApplication -Action STOP -Domains $Domains -EnvironmentId $EnvironmentId
    }
}

function Restart-CloudHubApplication {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][string[]] $Domains,
        [Parameter(Mandatory = $false)][guid] $EnvironmentId = $Script:Context.Environment.id
    )
    
    process {
        ControlCloudHubApplication -Action RESTART -Domains $Domains -EnvironmentId $EnvironmentId
    }
}

function Remove-CloudHubApplication {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][string[]] $Domains,
        [Parameter(Mandatory = $false)][guid] $EnvironmentId = $Script:Context.Environment.id
    )
    
    process {
        ControlCloudHubApplication -Action DELETE -Domains $Domains -EnvironmentId $EnvironmentId
    }
}

function Update-CloudHubApplicationRuntimeVersion {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][string[]] $Domains,
        [Parameter(Mandatory = $false)][guid] $EnvironmentId = $Script:Context.Environment.id
    )
    
    process {
        ControlCloudHubApplication -Action UPDATE -Domains $Domains -EnvironmentId $EnvironmentId
    }
}

function ControlCloudHubApplication {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][ValidateSet("START", "STOP", "RESTART", "DELETE", "UPDATE")] $Action,
        [Parameter(Mandatory = $true)][string[]] $Domains,
        [Parameter(Mandatory = $false)][guid] $EnvironmentId = $Script:Context.Environment.id
    )
    
    process {
        $body = @{
            action  = $Action
            domains = $Domains
        }

        $path = [CloudHub]::Applications($null)
        Invoke-AnypointApi -Method Put -Path $path -Body $body -EnvironmentId $EnvironmentId
    }
}


Export-ModuleMember -Function `
    Get-CloudHubAlert, `
    Get-CloudHubApplication, `
    Start-CloudHubApplication, Stop-CloudHubApplication, Restart-CloudHubApplication, Remove-CloudHubApplication, Update-CloudHubApplicationRuntimeVersion