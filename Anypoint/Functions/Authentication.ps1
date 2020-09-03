function Connect-Account {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)][PSCredential] $Credential,
        [Parameter(Mandatory = $false)][string] $AccessToken
    )

    process {
        $token = $AccessToken

        if (-not [bool]$token) {
            $loginInfo = @{}
            if ([bool]$Credential) {
                $loginInfo.username = $Credential.UserName;
                $loginInfo.password = ConvertToPlainText $Credential.Password
            }
            else {
                $loginInfo.username = Read-Host "Username"
                $loginInfo.password = ConvertToPlainText (Read-Host "Password" -AsSecureString)
            }
            $token = $Script:Client.Post("/accounts/login", $loginInfo).access_token
        }

        $Script:Client.SetAccessToken($token)

        $Script:Context.Account = $Script:Client.Get("/accounts/api/me").user

        $org = $Script:Context.Account.contributorOfOrganizations[0]
        $activeOrganizationId = $Script:Context.Account.properties.cs_auth.activeOrganizationId
        if ([bool]$activeOrganizationId) {
            $org = Get-BusinessGroup -OrganizationId $activeOrganizationId
        }
        $Script:Context.BusinessGroup = $org

        $Script:Context.Environment = (GetDefaultEnvironment $org.id)

        Get-Context
    }
}

function Disconnect-Account {
    [CmdletBinding()]
    param (
    )

    process {
        $Script:Client.ClearAccessToken()
    }
}

function Get-Context {
    [CmdletBinding()]
    param (
    )

    process {
        [PSCustomObject]@{
            Account       = $Script:Context.Account.username
            BusinessGroup = $Script:Context.BusinessGroup.name
            Environment   = $Script:Context.Environment.name
        }
    }
}

function Set-Context {
    [CmdletBinding(DefaultParameterSetName = "BusinessGroup")]
    param (
        [Parameter(ParameterSetName = "BusinessGroup", Mandatory = $true)]
        [Parameter(ParameterSetName = "Environment", Mandatory = $false)]
        [string] $BusinessGroupName,

        [Parameter(ParameterSetName = "Environment", Mandatory = $true)]
        [string] $EnvironmentName
    )

    process {
        if ([bool]$BusinessGroupName) {
            $Script:Context.BusinessGroup = (FirstOrDefaultIfArray (Get-BusinessGroup -Name $BusinessGroupName) $null)
        }

        if ([bool]$EnvironmentName) {
            $Script:Context.Environment = (FirstOrDefaultIfArray (Get-Environment -Name $EnvironmentName) $null)
        }
        else {
            $Script:Context.Environment = (GetDefaultEnvironment $Script:Context.BusinessGroup.id)
        }
        Get-Context
    }
}

function GetDefaultEnvironment ([guid]$orgId) {
    $ev = $null
    $defaultEnvironmentId = $Script:Context.Account.organizationPreferences.$orgId.defaultEnvironment
    
    if ([bool]$defaultEnvironmentId) {
        $ev = Get-Environment -OrganizationId $orgId -EnvironmentId $defaultEnvironmentId
    }

    if ($null -eq $ev) {
        $ev = FirstOrDefaultIfArray (Get-Environment -OrganizationId $orgId | Sort-Object { if ($_.name -eq "Sandbox") { " " } else { $_.name } })
    }

    return $ev
}


Set-Alias Login-Account Connect-Account
Set-Alias Logout-Account Disconnect-Account

Export-ModuleMember `
    -Alias    Login-Account, Logout-Account `
    -Function Connect-Account, Disconnect-Account, Get-Context, Set-Context
