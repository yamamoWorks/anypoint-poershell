# API Manager API
$Script:ApiManagerApi = "/apimanager/api/v1"

function Get-ApApi {
    [CmdletBinding(DefaultParameterSetName = "Multiple")]
    param (
        [Parameter(Mandatory = $false)][guid] $OrganizationId = $Script:Client.BusinessGroup.id,
        [Parameter(Mandatory = $false)][guid] $EnvironmentId = $Script:Client.Environment.id
    )

    process {
        $roles = $Script:Client.Get("$Script:ApiManagerApi/organizations/$OrganizationId/environments/$EnvironmentId/apis") | Step-Property -propertyName "assets"
        $roles
    }
}
