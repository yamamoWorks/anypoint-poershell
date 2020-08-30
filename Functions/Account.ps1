# Access Management API
$Script:AccountApi = "/accounts/api"

function Get-ApBusinessGroup {
    [CmdletBinding(DefaultParameterSetName = "Multiple")]
    param (
        [Parameter(ParameterSetName = "Single", Mandatory = $false)][guid] $Id,
        [Parameter(ParameterSetName = "Multiple", Mandatory = $false)][string] $Name
    )

    process {
        if ([bool]$Id) {
            $Script:Client.Get("$Script:AccountApi/organizations/$Id")
        }
        else {  
            $orgs = $Script:Context.Account.contributorOfOrganizations          
            if ([bool]$Name) {
                $orgs | Where-Object { $_.name -eq $Name }
            }
            else {
                $orgs
            }
        }
    }
}

function Get-ApEnvironment {
    [CmdletBinding(DefaultParameterSetName = "Multiple")]
    param (
        [Parameter(Mandatory = $false)][guid] $OrganizationId = $Script:Context.BusinessGroup.id,
        [Parameter(ParameterSetName = "Single", Mandatory = $false)][guid] $Id,
        [Parameter(ParameterSetName = "Multiple", Mandatory = $false)][ValidateSet("Production", "Sandbox", "Design")] $Type,
        [Parameter(ParameterSetName = "Multiple", Mandatory = $false)][ValidateSet($true, $false, $null)] $IsProduction,
        [Parameter(ParameterSetName = "Multiple", Mandatory = $false)][string] $Name
    )

    process {
        $params = @{
            type = "$Type".ToLower();
            isProduction = $IsProduction;
            name = $Name;
        }
        $Script:Client.Get("$Script:AccountApi/organizations/$OrganizationId/environments/$Id", $params) | Step-Property -propertyName "data"
    }
}

function Get-ApRoleGroup {
    [CmdletBinding(DefaultParameterSetName = "Multiple")]
    param (
        [Parameter(Mandatory = $false)][guid] $OrganizationId = $Script:Context.BusinessGroup.id,
        [Parameter(ParameterSetName = "Single", Mandatory = $false)][guid] $Id,
        [Parameter(ParameterSetName = "Multiple", Mandatory = $false)][string] $Name
    )

    process {
        $roles = $Script:Client.Get("$Script:AccountApi/organizations/$OrganizationId/rolegroups/$Id") | Step-Property -propertyName "data"
        if ([bool]$Name) {
            $roles | Where-Object { $_.name -eq $Name }
        }
        else {
            $roles
        }
    }
}

function Set-ApRoleGroup {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $false)][guid] $OrganizationId = $Script:Context.BusinessGroup.id,
        [Parameter(Mandatory = $true)][guid] $Id,
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)][object] $InputObject
    )

    process {
        $url = "$Script:AccountApi/organizations/$OrganizationId/rolegroups/$Id"
        if ($PSCmdlet.ShouldProcess($url, "Put")) {
            $Script:Client.Put($url, $InputObject)
        }
    }
}