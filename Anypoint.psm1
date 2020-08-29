Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$Script:BaseUrl = "https://anypoint.mulesoft.com"

class Context {
    [psobject] $Account
    [string] $AccessToken
    [psobject] $BusinessGroup
    [psobject] $Environment

    Context([string]$token) {
        $this.AccessToken = $token
    }
}

[Context]$Script:Context = $null

Get-ChildItem -Path $PSScriptRoot\Functions -Filter "*.ps1" | ForEach-Object -Process { . $PSItem.FullName }


Set-Alias Login-ApAccount Connect-ApAccount
Set-Alias Logout-ApAccount Disconnect-ApAccount

Export-ModuleMember `
    -Alias `
    Login-ApAccount, Logout-ApAccount, `
    -Function `
    Connect-ApAccount, Disconnect-ApAccount, `
    Get-ApBusinessGroup, `
    Get-ApEnvironment, `
    Get-ApRoleGroup, Set-ApRoleGroup, `
    Get-ApContext, Set-ApContext
