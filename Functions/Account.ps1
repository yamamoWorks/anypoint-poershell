# Access Management API
$Script:AccountApi = "$Script:BaseUrl/accounts/api"

function Get-ApBusinessGroup {
    [CmdletBinding(DefaultParameterSetName = "Multiple")]
    param (
        [Parameter(ParameterSetName = "Single", Mandatory = $false)][guid] $Id,
        [Parameter(ParameterSetName = "Multiple", Mandatory = $false)][string] $Name
    )

    process {
        if ([bool]$Id) {
            [RestApi]::Get("$Script:AccountApi/organizations/$Id")
        }
        else {  
            $orgs = $Script:Context.Account.contributorOfOrganizations          
            if ([bool]$Name) {
                $orgs | Search-Object { $_.name -eq $Name } -throwIfNotExist ([Messages]::NotExistOrNoPermission -f $Name)
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
        [Parameter(ParameterSetName = "Multiple", Mandatory = $false)][string] $Name
    )

    process {
        $envs = [RestApi]::Get("$Script:AccountApi/organizations/$OrganizationId/environments/$Id")
        if ([bool]$Name) {
            $envs | Search-Object { $_.name -eq $Name } -throwIfNotExist ([Messages]::NotExistOrNoPermission -f $Name)
        }
        else {
            $envs
        }
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
        $roles = [RestApi]::Get("$Script:AccountApi/organizations/$OrganizationId/rolegroups/$Id")
        if ([bool]$Name) {
            $roles | Search-Object { $_.name -eq $Name } -throwIfNotExist ([Messages]::NotExistOrNoPermission -f $Name)
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
            [RestApi]::Put($url, $InputObject)
        }
    }
}