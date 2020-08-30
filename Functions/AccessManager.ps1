# Access Management API
class AccessManager {

    static [string] $BasePath = "/accounts/api"

    static [string] Organizations($organizationId) {
        return [AccessManager]::BasePath + "/organizations/$organizationId"
    }

    static [string] Environments($organizationId, $environmentsId) {
        return [AccessManager]::BasePath + "/organizations/$organizationId/environments/$environmentsId"
    }

    static [string] RoleGroups($organizationId) {
        return [AccessManager]::Organizations($organizationId) + "/rolegroups"
    }
}


function Get-ApBusinessGroup {
    [CmdletBinding(DefaultParameterSetName = "Multiple")]
    param (
        [Parameter(ParameterSetName = "Single", Mandatory = $false)][guid] $Id,
        [Parameter(ParameterSetName = "Multiple", Mandatory = $false)][string] $Name
    )

    process {
        if ([bool]$Id) {
            $Script:Client.Get([AccessManager]::Organizations($Id))
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
            type         = "$Type".ToLower();
            isProduction = $IsProduction;
            name         = $Name;
        }
        $Script:Client.Get([AccessManager]::Environments($OrganizationId, $Id), $params) | Step-Property -propertyName "data"
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
        $roles = $Script:Client.Get([AccessManager]::RoleGroups($OrganizationId) + "/$Id") | Step-Property -propertyName "data"
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
        $url = [AccessManager]::RoleGroups($OrganizationId) + "/$Id"
        if ($PSCmdlet.ShouldProcess($url, "Put")) {
            $Script:Client.Put($url, $InputObject)
        }
    }
}


Export-ModuleMember -Function @(
    "Get-ApBusinessGroup", 
    "Get-ApEnvironment",
    "Get-ApRoleGroup", "Set-ApRoleGroup",
    "Get-ApContext", "Set-ApContext"
)