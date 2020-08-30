# API Manager API
$Script:ApiManagerApi = "/apimanager/api/v1"

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
        $Script:Client.Get("$Script:ApiManagerApi/organizations/$OrganizationId/environments/$EnvironmentId/apis", $params) | Step-Property -propertyName "assets"
    }
}

function Get-ApApiInstance {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)][guid] $OrganizationId = $Script:Context.BusinessGroup.id,
        [Parameter(Mandatory = $false)][guid] $EnvironmentId = $Script:Context.Environment.id,
        [Parameter(Mandatory = $false)][int] $Id
    )

    process {
        $Script:Client.Get("$Script:ApiManagerApi/organizations/$OrganizationId/environments/$EnvironmentId/apis/$Id")
    }
}
