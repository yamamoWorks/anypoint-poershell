Set-StrictMode -Version 1.0
$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.Web

. $PSScriptRoot\Common.ps1
. $PSScriptRoot\ApiClient.ps1

Get-ChildItem -Path $PSScriptRoot\Functions -Filter "*.ps1" | ForEach-Object -Process { . $PSItem.FullName }
