# Authentication

function Connect-ApAccount {
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
            $token = (Invoke-RestMethod -Method Post -Uri "$Script:BaseUrl/accounts/login" -Body ($loginInfo | ConvertTo-Json) -ContentType "application/json").access_token
        }

        $context = [Context]::new($token)
        $Script:Context = $context
        $context.Account = [RestApi]::Get("$Script:BaseUrl/accounts/api/me").user
        $context.BusinessGroup = $context.Account.contributorOfOrganizations[0]
        $envs = Get-ApEnvironment -OrganizationId $context.BusinessGroup.id
        $context.Environment = ($envs | Sort-Object { if ($_.name -eq "Sandbox") { " " } else { $_.name } })[0]
        Get-ApContext
    }
}

function Disconnect-ApAccount {
    [CmdletBinding()]
    param (
    )

    process {
        $Script:Context = $null
    }
}

function Get-ApContext {
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

function Set-ApContext {
    [CmdletBinding()]
    param (
        [Parameter(ParameterSetName = "BusinessGroup", Mandatory = $true)]
        [Parameter(ParameterSetName = "Environment", Mandatory = $false)]
        [string] $BusinessGroupName,

        [Parameter(ParameterSetName = "Environment", Mandatory = $true)]
        [string] $EnvironmentName
    )

    process {
        if ([bool]$BusinessGroupName) {
            $Script:Context.BusinessGroup = (FirstOrDefaultIfArray (Get-ApBusinessGroup -Name $BusinessGroupName) $null)
        }
        if ([bool]$EnvironmentName) {
            $Script:Context.Environment = (FirstOrDefaultIfArray (Get-ApEnvironment -Name $EnvironmentName) $null)
        }
        Get-ApContext
    }
}