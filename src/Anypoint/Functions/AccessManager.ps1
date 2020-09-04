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

    static [string] Users($organizationId) {
        return [AccessManager]::Organizations($organizationId) + "/users"
    }
}


function Get-BusinessGroup {
    [CmdletBinding(DefaultParameterSetName = "Multiple")]
    param (
        [Parameter(ParameterSetName = "Single", Mandatory = $true)][guid] $OrganizationId,
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

function Get-Environment {
    [CmdletBinding(DefaultParameterSetName = "Multiple")]
    param (
        [Parameter(ParameterSetName = "Single", Mandatory = $true)][guid] $EnvironmentId,
        [Parameter(ParameterSetName = "Multiple", Mandatory = $false)][ValidateSet("Production", "Sandbox", "Design")][string] $Type,
        [Parameter(ParameterSetName = "Multiple", Mandatory = $false)][ValidateSet($true, $false, $null)] $IsProduction,
        [Parameter(ParameterSetName = "Multiple", Mandatory = $false)][string] $Name,
        [Parameter(Mandatory = $false)][guid] $OrganizationId = $Script:Context.BusinessGroup.id
    )

    process {
        $params = @{
            type         = $Type.ToLower();
            isProduction = $IsProduction;
            name         = $Name;
        }
        $Script:Client.Get([AccessManager]::Environments($OrganizationId, $EnvironmentId), $params) | Expand-Property -propertyName "data"
    }
}

function Get-RoleGroup {
    [CmdletBinding(DefaultParameterSetName = "Multiple")]
    param (
        [Parameter(ParameterSetName = "Single", Mandatory = $true)][guid] $RoleGroupId,
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

function Update-RoleGroup {
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

function Set-RoleGroup {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $true)][guid] $RoleGroupId,
        [Parameter(Mandatory = $false)][string] $Name,
        [Parameter(Mandatory = $false)][string] $Description,
        [Parameter(Mandatory = $false)][string[]] $ExternalNames,
        [Parameter(Mandatory = $false)][guid] $OrganizationId = $Script:Context.BusinessGroup.id
    )

    process {
        $object = Get-RoleGroup -RoleGroupId $RoleGroupId -OrganizationId $OrganizationId
        if ([bool]$Name) {
            $object.name = $Name
        }
        if ([bool]$Description) {
            $object.description = $Description
        }
        if ($null -ne $ExternalNames) {
            $object.external_names = $ExternalNames
        }
        $object | Update-RoleGroup -RoleGroupId $RoleGroupId -OrganizationId $OrganizationId
    }
}

function New-RoleGroup {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(ParameterSetName = "Pipeline", Mandatory = $true, ValueFromPipeline = $true)][object] $InputObject,
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
                name           = $Name
                description    = $Description
                external_names = $ExternalNames
            }
        }

        $url = [AccessManager]::RoleGroups($OrganizationId)
        if ($PSCmdlet.ShouldProcess((FormatUrlAndBody $url $object), "Post")) {
            $Script:Client.Post($url, $object)
        }
    }
}

function Remove-RoleGroup {
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

function Add-RoleGroupExternalName {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $true)][guid] $RoleGroupId,
        [Parameter(Mandatory = $true)][string[]] $ExternalNames,
        [Parameter(Mandatory = $false)][guid] $OrganizationId = $Script:Context.BusinessGroup.id
    )

    process {
        $object = Get-RoleGroup -RoleGroupId $RoleGroupId -OrganizationId $OrganizationId
        $object.external_names += $ExternalNames
        $object | Update-RoleGroup -RoleGroupId $RoleGroupId -OrganizationId $OrganizationId
    }
}

function Remove-RoleGroupExternalName {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $true)][guid] $RoleGroupId,
        [Parameter(Mandatory = $true)][string[]] $ExternalNames,
        [Parameter(Mandatory = $false)][guid] $OrganizationId = $Script:Context.BusinessGroup.id
    )

    process {
        $object = Get-RoleGroup -RoleGroupId $RoleGroupId -OrganizationId $OrganizationId
        $object.external_names = $object.external_names | Where-Object { $ExternalNames -notcontains $_ }
        $object | Update-RoleGroup -RoleGroupId $RoleGroupId -OrganizationId $OrganizationId
    }
}

function Get-User {
    [CmdletBinding(DefaultParameterSetName = "Multiple")]
    param (
        [Parameter(ParameterSetName = "Single", Mandatory = $true)][guid] $UserId,
        [Parameter(ParameterSetName = "Multiple", Mandatory = $false)][ValidateSet("Host", "Proxy", "All")][string] $Type,
        [Parameter(ParameterSetName = "Multiple", Mandatory = $false)][guid] $OrganizationId = $Script:Context.BusinessGroup.id,
        [Parameter(ParameterSetName = "Multiple", Mandatory = $false)][ValidateRange(0, [int]::MaxValue)][int] $Offset = 0,
        [Parameter(ParameterSetName = "Multiple", Mandatory = $false)][ValidateRange(0, 500)][int] $Limit = 25
    )
    
    process {
        $params = @{
            type   = $Type.ToLower()
            offset = $PSBoundParameters["Offset"]
            limit  = $PSBoundParameters["Limit"]
        }
        $Script:Client.Get([AccessManager]::Users($OrganizationId) + "/$UserId", $params) | Expand-Property -propertyName "data"
    }    
}

function New-User {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(ParameterSetName = "Pipeline", Mandatory = $true, ValueFromPipeline = $true)][object] $InputObject,
        [Parameter(ParameterSetName = "Params", Mandatory = $true)][string] $Username,
        [Parameter(ParameterSetName = "Params", Mandatory = $false)][string] $FirstName,
        [Parameter(ParameterSetName = "Params", Mandatory = $false)][string] $LastName,
        [Parameter(ParameterSetName = "Params", Mandatory = $false)][string] $Email,
        [Parameter(ParameterSetName = "Params", Mandatory = $false)][string] $PhoneNumber,
        [Parameter(ParameterSetName = "Params", Mandatory = $true)][securestring] $Password,
        [Parameter(Mandatory = $false)][guid] $OrganizationId = $Script:Context.BusinessGroup.id
    )
    
    process {
        if ([bool]$InputObject) {
            $object = $InputObject
        }
        else {
            $object = ConvertDictionayToHashtable $PSBoundParameters `
                -Target "username", "firstName", "lastName", "email", "phoneNumber", "password"
        }

        $url = [AccessManager]::Users($OrganizationId)
        if ($PSCmdlet.ShouldProcess((FormatUrlAndBody $url $object), "Post")) {
            $Script:Client.Post($url, $object)
        }
    }
    
}

function Set-User {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $true)][guid] $UserId,
        [Parameter(ParameterSetName = "Pipeline", Mandatory = $true, ValueFromPipeline = $true)][object] $InputObject,
        [Parameter(ParameterSetName = "Params", Mandatory = $false)][string] $FirstName,
        [Parameter(ParameterSetName = "Params", Mandatory = $false)][string] $LastName,
        [Parameter(ParameterSetName = "Params", Mandatory = $false)][string] $Email,
        [Parameter(ParameterSetName = "Params", Mandatory = $false)][string] $PhoneNumber,
        [Parameter(ParameterSetName = "Params", Mandatory = $false)][bool] $Enabled,
        [Parameter(ParameterSetName = "Params", Mandatory = $false)][object] $Properties,
        [Parameter(Mandatory = $false)][guid] $OrganizationId = $Script:Context.BusinessGroup.id
    )
    
    process {
        if ([bool]$InputObject) {
            $object = $InputObject
        }
        else {
            $object = ConvertDictionayToHashtable $PSBoundParameters `
                -Target "firstName", "lastName", "email", "phoneNumber", "enabled", "properties"
        }

        $url = [AccessManager]::Users($OrganizationId) + "/$UserId"
        if ($PSCmdlet.ShouldProcess((FormatUrlAndBody $url $object), "Put")) {
            $Script:Client.Put($url, $object)
        }
    }    
}

function Remove-User {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $true)][guid[]] $UserId,
        [Parameter(Mandatory = $false)][guid] $OrganizationId = $Script:Context.BusinessGroup.id
    )
    
    process {
        if ($UserId.Count -eq 1) {
            $url = [AccessManager]::Users($OrganizationId) + "/$UserId"
            if ($PSCmdlet.ShouldProcess($url, "Delete")) {
                $Script:Client.Delete($url)
            }
        }
        else {
            $url = [AccessManager]::Users($OrganizationId)
            if ($PSCmdlet.ShouldProcess((FormatUrlAndBody $url $UserId.Guid), "Delete")) {
                $Script:Client.Delete($url, $null, $UserId.Guid)
            }
        }
    }    
}

Export-ModuleMember -Function `
    Get-BusinessGroup, `
    Get-Environment, `
    Get-RoleGroup, Set-RoleGroup, Update-RoleGroup, New-RoleGroup, Remove-RoleGroup, `
    Get-Context, Set-Context, `
    Add-RoleGroupExternalName, Remove-RoleGroupExternalName, `
    Get-User, New-User, Set-User, Remove-User
