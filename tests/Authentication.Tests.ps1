$root = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
Import-Module "$root\src\Anypoint\Anypoint.psm1" -Force

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
        $actual = Login-Account $Script:Credential
        $actual.Account | Should -Be $Script:Credential.UserName
    }
    It "ApContext" {
        $orgs = Get-BusinessGroup | Select-Object -First 2
        foreach ($org in $orgs) {
            $envs = Get-Environment -OrganizationId $org.id | Select-Object -First 2
            foreach ($ev in $envs) {
                $actual = Set-Context -BusinessGroupName $org.name -EnvironmentName $ev.name
                $actual.BusinessGroup | Should -BeExactly $org.name
                $actual.Environment | Should -BeExactly $ev.name
            }
        }
    }
    It "Logout" {
        $orgId = (Get-BusinessGroup | Select-Object -First 1).id
        Logout-Account
        { Get-BusinessGroup -OrganizationId $orgId } | Should -Throw "Response status code does not indicate success: 401 (Unauthorized)."
    }
}
