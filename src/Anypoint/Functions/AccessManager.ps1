# Access Management API
class AccessManager {

    static [string] $BasePath = "/accounts/api"

    static [string] Organizations() {
        return [AccessManager]::BasePath + "/organizations"
    }

    static [string] Organizations($orgid) {
        return [AccessManager]::BasePath + "/organizations/$orgid"
    }

    static [string] Environments($orgid, $environmentsId) {
        return [AccessManager]::BasePath + "/organizations/$orgid/environments/$environmentsId"
    }

    static [string] RoleGroups($orgid) {
        return [AccessManager]::BasePath + "/organizations/$orgid/rolegroups"
    }

    static [string] RoleGroups($orgid, $roleGroupId) {
        return [AccessManager]::BasePath + "/organizations/$orgid/rolegroups/$roleGroupId"
    }

    static [string] Users($orgid) {
        return [AccessManager]::BasePath + "/organizations/$orgid/users"
    }

    static [string] Users($orgid, $userId) {
        return [AccessManager]::BasePath + "/organizations/$orgid/users/$userId"
    }

    static [string] Me() {
        return [AccessManager]::BasePath + "/me"
    }
}


function Get-BusinessGroup {
    [CmdletBinding(DefaultParameterSetName = "ByName")]
    param (
        [Parameter(ParameterSetName = "Id", Mandatory = $true)][guid] $OrganizationId,
        [Parameter(ParameterSetName = "ByName", Mandatory = $false)][string] $Name
    )

    process {
        if ([bool]$OrganizationId) {
            $path = [AccessManager]::Organizations($OrganizationId)
            Invoke-AnypointApi -Method Get -Path $path
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

function New-BusinessGroup {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][string] $Name,
        [Parameter(Mandatory = $true)][guid]   $ParentOrganizationId,
        [Parameter(Mandatory = $true)][guid]   $OwnerId
    )

    process {
        $object = @{ 
            name                 = $Name
            parentOrganizationId = $ParentOrganizationId
            ownerId              = $OwnerId
        }

        $path = [AccessManager]::Organizations()
        Invoke-AnypointApi -Method Post -Path $path -Body $object
    }
}


function Get-Environment {
    [CmdletBinding(DefaultParameterSetName = "Query")]
    param (
        [Parameter(ParameterSetName = "Id", Mandatory = $true)][guid] $EnvironmentId,
        [Parameter(ParameterSetName = "Query", Mandatory = $false)][ValidateSet("Production", "Sandbox", "Design")][string] $Type,
        [Parameter(ParameterSetName = "Query", Mandatory = $false)][ValidateSet($true, $false, $null)] $IsProduction,
        [Parameter(ParameterSetName = "Query", Mandatory = $false)][string] $Name,
        [Parameter(Mandatory = $false)][guid] $OrganizationId = $Script:Context.BusinessGroup.id,
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)][PSCustomObject] $BusinessGroup
    )

    process {
        $params = @{
            type         = $Type.ToLower();
            isProduction = $IsProduction;
            name         = $Name;
        }

        if ([bool]$BusinessGroup) {
            $OrganizationId = GetRequiredValue $BusinessGroup "id"
        }

        $path = [AccessManager]::Environments($OrganizationId, $EnvironmentId)
        Invoke-AnypointApi -Method Get -Path $path -QueryParameters $params | Expand-Property -propertyName "data"
    }
}

function Get-RoleGroup {
    [CmdletBinding(DefaultParameterSetName = "Query")]
    param (
        [Parameter(ParameterSetName = "Id", Mandatory = $true)][guid] $RoleGroupId,
        [Parameter(ParameterSetName = "Query", Mandatory = $false)][string] $Name,
        [Parameter(Mandatory = $false)][guid] $OrganizationId = $Script:Context.BusinessGroup.id,
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)][PSCustomObject] $BusinessGroup
    )

    process {
        if ([bool]$BusinessGroup) {
            $OrganizationId = GetRequiredValue $BusinessGroup "id"
        }

        $path = [AccessManager]::RoleGroups($OrganizationId, $RoleGroupId)
        $roles = Invoke-AnypointApi -Method Get -Path $path | Expand-Property -propertyName "data"
        if ([bool]$Name) {
            $roles | Where-Object { $_.name -eq $Name }
        }
        else {
            $roles
        }
    }
}

function Update-RoleGroup {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)][object] $InputObject
    )

    process {
        $RoleGroupId = GetRequiredValue $InputObject "role_group_id"
        $OrganizationId = GetRequiredValue $InputObject "org_id"

        $path = [AccessManager]::RoleGroups($OrganizationId, $RoleGroupId)
        Invoke-AnypointApi -Method Put -Path $path -Body $InputObject
    }
}

function Set-RoleGroup {
    [CmdletBinding()]
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
        $object | Update-RoleGroup
    }
}

function New-RoleGroup {
    [CmdletBinding()]
    param (
        [Parameter(ParameterSetName = "Params", Mandatory = $true)][string] $Name,
        [Parameter(ParameterSetName = "Params", Mandatory = $false)][string] $Description,
        [Parameter(ParameterSetName = "Params", Mandatory = $false)][string[]] $ExternalNames,
        [Parameter(ParameterSetName = "Pipeline", Mandatory = $true, ValueFromPipeline = $true)][object] $InputObject,
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

        $path = [AccessManager]::RoleGroups($OrganizationId)
        Invoke-AnypointApi -Method Post -Path $path -Body $object
    }
}

function Remove-RoleGroup {
    [CmdletBinding()]
    param (
        [Parameter(ParameterSetName = "Id", Mandatory = $true)][guid] $RoleGroupId,
        [Parameter(ParameterSetName = "Id", Mandatory = $false)][guid] $OrganizationId = $Script:Context.BusinessGroup.id,
        [Parameter(ParameterSetName = "Pipeline", Mandatory = $true, ValueFromPipeline = $true)][object] $RoleGroup
    )

    process {
        if ([bool]$RoleGroup) {
            $RoleGroupId = GetRequiredValue $RoleGroup "role_group_id"
            $OrganizationId = GetRequiredValue $RoleGroup "org_id"
        }

        $path = [AccessManager]::RoleGroups($OrganizationId, $RoleGroupId)
        Invoke-AnypointApi -Method Delete -Path $path
    }
}

function Add-RoleGroupExternalName {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][guid] $RoleGroupId,
        [Parameter(Mandatory = $true)][string[]] $ExternalNames,
        [Parameter(Mandatory = $false)][guid] $OrganizationId = $Script:Context.BusinessGroup.id
    )

    process {
        $object = Get-RoleGroup -RoleGroupId $RoleGroupId -OrganizationId $OrganizationId
        $object.external_names += $ExternalNames
        $object | Update-RoleGroup
    }
}

function Remove-RoleGroupExternalName {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][guid] $RoleGroupId,
        [Parameter(Mandatory = $true)][string[]] $ExternalNames,
        [Parameter(Mandatory = $false)][guid] $OrganizationId = $Script:Context.BusinessGroup.id
    )

    process {
        $object = Get-RoleGroup -RoleGroupId $RoleGroupId -OrganizationId $OrganizationId
        $object.external_names = $object.external_names | Where-Object { $ExternalNames -notcontains $_ }
        $object | Update-RoleGroup
    }
}

function Get-User {
    [CmdletBinding(DefaultParameterSetName = "Query")]
    param (
        [Parameter(ParameterSetName = "Id", Mandatory = $true)][guid] $UserId,
        [Parameter(ParameterSetName = "Query", Mandatory = $false)][ValidateSet("Host", "Proxy", "All")][string] $Type,
        [Parameter(ParameterSetName = "Query", Mandatory = $false)][ValidateRange(0, [int]::MaxValue)][int] $Offset,
        [Parameter(ParameterSetName = "Query", Mandatory = $false)][ValidateRange(0, 500)][int] $Limit,
        [Parameter(Mandatory = $false)][guid] $OrganizationId = $Script:Context.BusinessGroup.id
    )
    
    process {
        $params = @{
            type   = $Type.ToLower()
            offset = $PSBoundParameters["Offset"]
            limit  = $PSBoundParameters["Limit"]
        }
        $path = [AccessManager]::Users($OrganizationId, $UserId)
        Invoke-AnypointApi -Method Get -Path $path -QueryParameters $params | Expand-Property -propertyName "data"
    }    
}

function New-User {
    [CmdletBinding()]
    param (
        [Parameter(ParameterSetName = "Params", Mandatory = $true)][string] $Username,
        [Parameter(ParameterSetName = "Params", Mandatory = $false)][string] $FirstName,
        [Parameter(ParameterSetName = "Params", Mandatory = $false)][string] $LastName,
        [Parameter(ParameterSetName = "Params", Mandatory = $false)][string] $Email,
        [Parameter(ParameterSetName = "Params", Mandatory = $false)][string] $PhoneNumber,
        [Parameter(ParameterSetName = "Params", Mandatory = $true)][securestring] $Password,
        [Parameter(ParameterSetName = "Pipeline", Mandatory = $true, ValueFromPipeline = $true)][object] $InputObject,
        [Parameter(Mandatory = $false)][guid] $OrganizationId = $Script:Context.BusinessGroup.id
    )
    
    process {
        if ([bool]$InputObject) {
            $user = $InputObject
        }
        else {
            $user = @{}
            BindModel -Model $user -BoundParameters $PSBoundParameters `
                -Properties "username", "firstName", "lastName", "email", "phoneNumber", "password"
        }

        $path = [AccessManager]::Users($OrganizationId)
        Invoke-AnypointApi -Method Post -Path $path -Body $user
    }    
}

function Update-User {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)][object] $InputObject
    )
   
    process {
        $UserId = GetRequiredValue $InputObject "id"
        $OrganizationId = GetRequiredValue $InputObject "organizationId"

        $path = [AccessManager]::Users($OrganizationId, $UserId)
        Invoke-AnypointApi -Method Put -Path $path -Body $InputObject
    }    
}

function Set-User {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][guid] $UserId,
        [Parameter(Mandatory = $false)][string] $FirstName,
        [Parameter(Mandatory = $false)][string] $LastName,
        [Parameter(Mandatory = $false)][string] $Email,
        [Parameter(Mandatory = $false)][string] $PhoneNumber,
        [Parameter(Mandatory = $false)][bool] $Enabled,
        [Parameter(Mandatory = $false)][object] $Properties,
        [Parameter(Mandatory = $false)][guid] $OrganizationId = $Script:Context.BusinessGroup.id
    )
    
    process {
        $user = Get-User -UserId $UserId -OrganizationId $OrganizationId

        BindModel -Model $user -BoundParameters $PSBoundParameters `
            -Properties "firstName", "lastName", "email", "phoneNumber", "enabled", "properties"

        $user | Update-User
    }    
}

function Remove-User {
    [CmdletBinding()]
    param (
        [Parameter(ParameterSetName = "Id", Mandatory = $true)][guid[]] $UserId,
        [Parameter(ParameterSetName = "Id", Mandatory = $false)][guid] $OrganizationId = $Script:Context.BusinessGroup.id,
        [Parameter(ParameterSetName = "Pipeline", Mandatory = $true, ValueFromPipeline = $true)][object] $User
    )
    
    process {
        if ([bool]$User) {
            $UserId = GetRequiredValue $User "id"
            $OrganizationId = GetRequiredValue $User "organizationId"
        }
        
        if ($UserId.Count -eq 1) {
            $path = [AccessManager]::Users($OrganizationId, $UserId)
            Invoke-AnypointApi -Method Delete -Path $path
        }
        else {
            $path = [AccessManager]::Users($OrganizationId)
            Invoke-AnypointApi -Method Delete -Path $path -Body $UserId.Guid
        }
    }    
}


Export-ModuleMember -Function `
    Get-BusinessGroup, New-BusinessGroup, `
    Get-Environment, `
    Get-RoleGroup, Set-RoleGroup, Update-RoleGroup, New-RoleGroup, Remove-RoleGroup, `
    Get-Context, Set-Context, `
    Add-RoleGroupExternalName, Remove-RoleGroupExternalName, `
    Get-User, New-User, Update-User, Set-User, Remove-User
