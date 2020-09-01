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

function Update-ApRoleGroup {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $true)][guid] $RoleGroupId,
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)][object] $InputObject,
        [Parameter(Mandatory = $false)][guid] $OrganizationId = $Script:Context.BusinessGroup.id
    )

    process {
        $url = [AccessManager]::RoleGroups($OrganizationId) + "/$RoleGroupId"
        if ($PSCmdlet.ShouldProcess((FormatUrlAndBody $url $InputObject), "Put")) {
            $Script:Client.Put($url, $InputObject)
        }
    }
}

function Set-ApRoleGroup {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $true)][guid] $RoleGroupId,
        [Parameter(Mandatory = $false)][string] $Name,
        [Parameter(Mandatory = $false)][string] $Description,
        [Parameter(Mandatory = $false)][string[]] $ExternalNames,
        [Parameter(Mandatory = $false)][guid] $OrganizationId = $Script:Context.BusinessGroup.id
    )

    process {
        $object = Get-ApRoleGroup -RoleGroupId $RoleGroupId -OrganizationId $OrganizationId
        if ([bool]$Name) {
            $object.name = $Name
        }
        if ([bool]$Description) {
            $object.description = $Description
        }
        if ($null -ne $ExternalNames) {
            $object.external_names = $ExternalNames
        }
        $object | Update-ApRoleGroup -RoleGroupId $RoleGroupId -OrganizationId $OrganizationId
    }
}

function New-ApRoleGroup {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(ParameterSetName = "Object", Mandatory = $true, ValueFromPipeline = $true)][object] $InputObject,
        [Parameter(ParameterSetName = "Params", Mandatory = $true)][string] $Name,
        [Parameter(ParameterSetName = "Params", Mandatory = $false)][string] $Description,
        [Parameter(ParameterSetName = "Params", Mandatory = $false)][string[]] $ExternalNames,
        [Parameter(Mandatory = $false)][guid] $OrganizationId = $Script:Context.BusinessGroup.id
    )

    process {
        if ([bool]$InputObject) {
            $object = $InputObject
        }
        else {
            $object = @{ 
                name           = $Name;
                description    = $Description;
                external_names = $ExternalNames
            }
        }

        $url = [AccessManager]::RoleGroups($OrganizationId)
        if ($PSCmdlet.ShouldProcess((FormatUrlAndBody $url $object), "Post")) {
            $Script:Client.Post($url, $object)
        }
    }
}

function Remove-ApRoleGroup {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $true)][guid] $RoleGroupId,
        [Parameter(Mandatory = $false)][guid] $OrganizationId = $Script:Context.BusinessGroup.id
    )

    process {
        $url = [AccessManager]::RoleGroups($OrganizationId) + "/$RoleGroupId"
        if ($PSCmdlet.ShouldProcess($url, "Delete")) {
            $Script:Client.Delete($url)
        }
    }
}

function Add-ApRoleGroupExternalName {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $true)][guid] $RoleGroupId,
        [Parameter(Mandatory = $true)][string[]] $ExternalNames,
        [Parameter(Mandatory = $false)][guid] $OrganizationId = $Script:Context.BusinessGroup.id
    )

    process {
        $object = Get-ApRoleGroup -RoleGroupId $RoleGroupId -OrganizationId $OrganizationId
        $object.external_names += $ExternalNames
        $object | Update-ApRoleGroup -RoleGroupId $RoleGroupId -OrganizationId $OrganizationId
    }
}

function Remove-ApRoleGroupExternalName {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $true)][guid] $RoleGroupId,
        [Parameter(Mandatory = $true)][string[]] $ExternalNames,
        [Parameter(Mandatory = $false)][guid] $OrganizationId = $Script:Context.BusinessGroup.id
    )

    process {
        $object = Get-ApRoleGroup -RoleGroupId $RoleGroupId -OrganizationId $OrganizationId
        $object.external_names = $object.external_names | Where-Object { $ExternalNames -notcontains $_ }
        $object | Update-ApRoleGroup -RoleGroupId $RoleGroupId -OrganizationId $OrganizationId
    }
}

Export-ModuleMember -Function `
    Get-ApBusinessGroup, `
    Get-ApEnvironment, `
    Get-ApRoleGroup, Set-ApRoleGroup, Update-ApRoleGroup, New-ApRoleGroup, Remove-ApRoleGroup, `
    Get-ApContext, Set-ApContext, `
    Add-ApRoleGroupExternalName, Remove-ApRoleGroupExternalName
