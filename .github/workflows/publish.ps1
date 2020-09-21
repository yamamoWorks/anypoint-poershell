Param([string] $NuGetApiKey)
$ErrorActionPreference="Stop"

Import-Module PowerShellGet -Force
Publish-Module -Path .\src\Anypoint -NuGetApiKey $NuGetApiKey

trap {
    $host.SetShouldExit($LASTEXITCODE)
}