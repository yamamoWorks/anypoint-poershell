$root = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
Import-Module "$root\src\Anypoint\Anypoint.psm1" -Force

$Script:PREFIX = "ANYPOINT_PS"

BeforeAll {
    if ($Script:Credential -eq $null) {
        $Script:Credential = Get-Credential
    }
    Login-Account $Script:Credential
}

Describe "Asset" {
    BeforeAll {
        $now = Get-Date -Format 'yyMMddHHmmss'
        $now | Out-Null
    }
    BeforeEach {
        Start-Sleep -Milliseconds 3000
    }
    It "New HTTP Asset" {
        $expected = @{
            name       = "$Script:PREFIX-HTTP-$now"
            assetId    = "$Script:PREFIX-http-$now"
            version    = "1.0.0"
            apiVersion = "v1"
        }

        $actual = New-ExchangeAsset -Classifier HTTP -Name $expected.name -AssetId $expected.assetId -Version $expected.version -ApiVersion $expected.apiVersion
        $actual.groupId
        $actual.assetId

        $actual.name       | Should -BeExactly $expected.name
        $actual.assetId    | Should -BeExactly $expected.assetId
        $actual.version    | Should -BeExactly $expected.version
        $actual.apiVersion | Should -BeExactly $expected.apiVersion
    }
    It "Get Asset" {
        $expected = Get-ExchangeAsset | Select-Object -First 1

        $actual = Get-ExchangeAsset -GroupId $expected.groupId -AssetId $expected.assetId

        $actual.groupId | Should -BeExactly $expected.groupId
        $actual.assetId | Should -BeExactly $expected.assetId
    }
    It "Search Asset" {
        $actual = Search-ExchangeAsset -Search 'Einstein Analytics "Mule 4"' -Domain "anypoint-platform-legacy"

        $actual.groupId | Should -BeExactly "com.mulesoft.connectors"
        $actual.assetId | Should -BeExactly "mule-sfdc-analytics-connector"
        $actual.name    | Should -BeExactly "Salesforce Einstein Analytics Connector - Mule 4"
    }
    It "Remove Asset" {
        $list = Search-ExchangeAsset -Search "$Script:PREFIX-"

        foreach ($item in $list) {
            Remove-ExchangeAsset -GroupId $item.groupId -AssetId $item.assetId -HardDelete
            { Get-ExchangeAsset -GroupId $item.groupId -AssetId $item.assetId } | Should -Throw
        }
    }
}
