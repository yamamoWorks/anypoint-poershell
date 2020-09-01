$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.ps1', '.psm1'
Import-Module "$root\$sut" -Force

BeforeAll {
    if ($Script:Credential -eq $null) {
        $Script:Credential = Get-Credential
    }
}

Describe "Authentication" {
    It "Login" {
        $actual = Login-Anypoint $Script:Credential
        $actual.Account | Should -Be $Script:Credential.UserName
    }
    It "ApContext" {
        $orgs = Get-ApBusinessGroup | Select-Object -First 2
        foreach ($org in $orgs) {
            $envs = Get-ApEnvironment -OrganizationId $org.id | Select-Object -First 2
            foreach ($ev in $envs) {
                Set-ApContext -BusinessGroupName $org.name -EnvironmentName $ev.name
                $actual = Get-ApContext
                $actual.BusinessGroup | Should -Be $org.name
                $actual.Environment | Should -Be $ev.name
            }
        }
    }
    It "Logout" {
        Logout-Anypoint
        { Get-ApEnvironment } | Should -Throw "Response status code does not indicate success: 401 (Unauthorized)."
    }
}

Describe "Access Manager" {
    BeforeAll {
        Login-Anypoint $Script:Credential       
        $orgs = Get-ApBusinessGroup | Select-Object -First 3
        $orgs | Out-Null  
    }
    It "BusinessGroup" {
        foreach ($org in $orgs) {
            (Get-ApBusinessGroup -OrganizationId $org.id).id | Should -Be $org.id
            (Get-ApBusinessGroup -Name $org.name).id | Should -Be $org.id
        }
    }
    It "Environment" {
        foreach ($org in $orgs) {
            $envs = Get-ApEnvironment -OrganizationId $org.id | Select-Object -First 3
            foreach ($ev in $envs) {
                (Get-ApEnvironment -OrganizationId $org.id -EnvironmentId $ev.id).id | Should -Be $ev.id
                (Get-ApEnvironment -OrganizationId $org.id -Name $ev.name).id | Should -Be $ev.id
                (Get-ApEnvironment -OrganizationId $org.id -Name $ev.name -Type $ev.type).id | Should -Be $ev.id
                (Get-ApEnvironment -OrganizationId $org.id -Name $ev.name -IsProduction $ev.isProduction).id | Should -Be $ev.id
            }
        }
    }
    It "RoleGroup" {
        foreach ($org in $orgs) {
            $roles = Get-ApRoleGroup -OrganizationId $org.id | Select-Object -First 3
            foreach ($role in $roles) {
                (Get-ApRoleGroup -OrganizationId $org.id -RoleGroupId $role.role_group_id).role_group_id | Should -Be $role.role_group_id
                (Get-ApRoleGroup -OrganizationId $org.id -Name $role.name).role_group_id | Should -Be $role.role_group_id
            }        
        }
    }
}
