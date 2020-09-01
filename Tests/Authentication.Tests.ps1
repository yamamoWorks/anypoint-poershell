$root = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
Import-Module "$root\Anypoint.psm1" -Force

$Script:PREFIX = "ANYPOINT_POWERSHELL_TEST"

BeforeAll {
    if ($Script:Credential -eq $null) {
        $Script:Credential = Get-Credential
    }
}

Describe "Authentication" {
    BeforeEach {
        Start-Sleep -Milliseconds 3000
    }
    It "Login" {
        $actual = Login-Anypoint $Script:Credential
        $actual.Account | Should -Be $Script:Credential.UserName
    }
    It "ApContext" {
        $orgs = Get-ApBusinessGroup | Select-Object -First 2
        foreach ($org in $orgs) {
            $envs = Get-ApEnvironment -OrganizationId $org.id | Select-Object -First 2
            foreach ($ev in $envs) {
                $actual = Set-ApContext -BusinessGroupName $org.name -EnvironmentName $ev.name
                $actual.BusinessGroup | Should -BeExactly $org.name
                $actual.Environment | Should -BeExactly $ev.name
            }
        }
    }
    It "Logout" {
        Logout-Anypoint
        { Get-ApEnvironment } | Should -Throw "Response status code does not indicate success: 401 (Unauthorized)."
    }
}
