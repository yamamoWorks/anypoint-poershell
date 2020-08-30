Set-StrictMode -Version 1.0
$ErrorActionPreference = "Stop"

. .\Common.ps1

$Script:Context = [Context]::new()
$Script:Client = [AnypointClilent]::new("https://anypoint.mulesoft.com")

Get-ChildItem -Path $PSScriptRoot\Functions -Filter "*.ps1" | ForEach-Object -Process { . $PSItem.FullName }


Set-Alias Login-Anypoint Connect-ApAccount
Set-Alias Logout-Anypoint Disconnect-ApAccount

Export-ModuleMember `
    -Alias `
    Login-Anypoint, Logout-Anypoint, `
    -Function `
    Connect-ApAccount, Disconnect-ApAccount, `
    Get-ApBusinessGroup, `
    Get-ApEnvironment, `
    Get-ApRoleGroup, Set-ApRoleGroup, `
    Get-ApContext, Set-ApContext, `
    Get-ApApi
