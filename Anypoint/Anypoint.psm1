Set-StrictMode -Version 1.0
$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.Web

. $PSScriptRoot\Common.ps1

$Script:Context = [Context]::new()
$Script:Client = [AnypointClilent]::new("https://anypoint.mulesoft.com")

Get-ChildItem -Path $PSScriptRoot\Functions -Filter "*.ps1" | ForEach-Object -Process { . $PSItem.FullName }
