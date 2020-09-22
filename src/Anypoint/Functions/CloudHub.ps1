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

$Script:WorkerType = @{
    0.1 = "Micro"
    0.2 = "Small"
    1   = "Medium"
    2   = "Large"
    4   = "xLarge"
    8   = "xxLarge"
    16  = "4xLarge"    
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

function New-CloudHubApplication {
    [CmdletBinding()]
    param (
        [Parameter(ParameterSetName = "Params", Mandatory = $true)][string] $Domain,
        [Parameter(ParameterSetName = "Params", Mandatory = $true)][System.IO.FileInfo] $JarFile,
        [Parameter(ParameterSetName = "Params", Mandatory = $false)][switch] $AutoStart = $false,
        [Parameter(ParameterSetName = "Params", Mandatory = $false)][ValidateSet(0.1, 0.2, 1, 2, 4, 8, 16)] $WorkerSize = 0.1,
        [Parameter(ParameterSetName = "Params", Mandatory = $false)][int] $Workers = 1,
        [Parameter(ParameterSetName = "Params", Mandatory = $false)][ValidatePattern("\d*\.\d*\.\d*")][string] $RuntimeVersion,
        [Parameter(ParameterSetName = "Params", Mandatory = $false)][ValidateSet( "us-east-1", "us-east-2", "us-west-1", "us-west-2", "ca-central-1", "eu-west-1", "eu-central-1", "eu-west-2", "ap-northeast-1", "ap-southeast-1", "ap-southeast-2", "sa-east-1")] $Region,
        [Parameter(ParameterSetName = "Params", Mandatory = $false)][switch] $AutoRestart,
        [Parameter(ParameterSetName = "Params", Mandatory = $false)][switch] $PersistentQueues,
        [Parameter(ParameterSetName = "Params", Mandatory = $false)][switch] $EncryptPersistentQueues,
        [Parameter(ParameterSetName = "Params", Mandatory = $false)][switch] $DisableCloudHubLog,
        [Parameter(ParameterSetName = "Params", Mandatory = $false)][switch] $UseObjectStoreV2,
        [Parameter(ParameterSetName = "Params", Mandatory = $false)][object] $Properties,
        [Parameter(ParameterSetName = "Params", Mandatory = $false)][object[]] $LogLevels,
        [Parameter(ParameterSetName = "Params", Mandatory = $false)][switch] $UseStaticIP,
        [Parameter(ParameterSetName = "Pipeline", Mandatory = $true, ValueFromPipeline = $true)][object] $AppInfoJson,
        [Parameter(Mandatory = $false)][guid] $EnvironmentId = $Script:Context.Environment.id
    )
    
    process {
        $app = @{
            autoStart = $AutoStart
            file      = $JarFile
        }

        if ([bool]$AppInfoJson) {
            $app.appInfoJson = $AppInfoJson | ConvertTo-Json
        }
        else {
            $appInfo = @{
                domain  = $Domain
                workers = @{
                    amount = $Workers
                    type   = @{
                        name = $Script:WorkerType[$WorkerSize]
                    }
                }
            }

            if ([bool]$RuntimeVersion) {
                $appInfo.muleVersion = @{ version = $RuntimeVersion }
            }
            if ([bool]$Region) {
                $appInfo.region = $Region
            }
            if ([bool]$AutoRestart) {
                $appInfo.monitoringAutoRestart = $true
            }
            if ([bool]$PersistentQueues) {
                $appInfo.persistentQueues = $true
            }
            if ([bool]$EncryptPersistentQueues) {
                $appInfo.persistentQueuesEncrypted = $true
            }
            if ([bool]$DisableCloudHubLog) {
                $appInfo.loggingCustomLog4JEnabled = $true
            }
            if ([bool]$UseObjectStoreV2) {
                $appInfo.objectStoreV1 = $false
            }
            if ([bool]$Properties) {
                $appInfo.properties = $Properties
            }
            if ([bool]$LogLevels) {
                $appInfo.logLevels = $LogLevels
            }
            if ([bool]$UseStaticIP) {
                $appInfo.staticIPsEnabled = $true
            }

            $app.appInfoJson = $appInfo | ConvertTo-Json
        }

        $path = [CloudHub]::Applications($null)
        Invoke-AnypointApi -Method Post -Path $path -Body $app -EnvironmentId $EnvironmentId -MultipartForm
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
    Get-CloudHubApplication, New-CloudHubApplication, `
    Start-CloudHubApplication, Stop-CloudHubApplication, Restart-CloudHubApplication, Remove-CloudHubApplication, Update-CloudHubApplicationRuntimeVersion