Set-StrictMode -Version 1.0
$ErrorActionPreference = "Stop"

. $PSScriptRoot\Common.ps1

$Script:Context = [Context]::new()
$Script:Client = [AnypointClilent]::new("https://anypoint.mulesoft.com")

Get-ChildItem -Path $PSScriptRoot\Functions -Filter "*.ps1" | ForEach-Object -Process { . $PSItem.FullName }
