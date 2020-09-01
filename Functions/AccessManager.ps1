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
        [Parameter(ParameterSetName = "Single", Mandatory = $false)][guid] $OrganizationId,
        [Parameter(ParameterSetName = "Multiple", Mandatory = $false)][string] $Name
    )

    process {
        if ([bool]$OrganizationId) {
            $Script:Client.Get([AccessManager]::Organizations($OrganizationId))
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
        [Parameter(ParameterSetName = "Single", Mandatory = $false)][guid] $EnvironmentId,
        [Parameter(ParameterSetName = "Multiple", Mandatory = $false)][ValidateSet("Production", "Sandbox", "Design")] $Type,
        [Parameter(ParameterSetName = "Multiple", Mandatory = $false)][ValidateSet($true, $false, $null)] $IsProduction,
        [Parameter(ParameterSetName = "Multiple", Mandatory = $false)][string] $Name,
        [Parameter(Mandatory = $false)][guid] $OrganizationId = $Script:Context.BusinessGroup.id
    )

    process {
        $params = @{
            type         = "$Type".ToLower();
            isProduction = $IsProduction;
            name         = $Name;
        }
        $Script:Client.Get([AccessManager]::Environments($OrganizationId, $EnvironmentId), $params) | Expand-Property -propertyName "data"
    }
}

function Get-ApRoleGroup {
    [CmdletBinding(DefaultParameterSetName = "Multiple")]
    param (
        [Parameter(ParameterSetName = "Single", Mandatory = $false)][guid] $RoleGroupId,
        [Parameter(ParameterSetName = "Multiple", Mandatory = $false)][string] $Name,
        [Parameter(Mandatory = $false)][guid] $OrganizationId = $Script:Context.BusinessGroup.id
    )

    process {
        $roles = $Script:Client.Get([AccessManager]::RoleGroups($OrganizationId) + "/$RoleGroupId") | Expand-Property -propertyName "data"
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
        [Parameter(Mandatory = $true)][guid] $RoleGroupId,
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)][object] $InputObject,
        [Parameter(Mandatory = $false)][guid] $OrganizationId = $Script:Context.BusinessGroup.id
    )

    process {
        $url = [AccessManager]::RoleGroups($OrganizationId) + "/$RoleGroupId"
        if ($PSCmdlet.ShouldProcess($url, "Put")) {
            $Script:Client.Put($url, $InputObject)
        }
    }
}


Export-ModuleMember -Function `
    Get-ApBusinessGroup, 
    Get-ApEnvironment,
    Get-ApRoleGroup, Set-ApRoleGroup,
    Get-ApContext, Set-ApContext
