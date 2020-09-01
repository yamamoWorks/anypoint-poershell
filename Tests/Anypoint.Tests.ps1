$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.ps1', '.psm1'
Import-Module "$root\$sut" -Force

$Script:PREFIX = "ANYPOINT_POWERSHELL_TEST"

BeforeAll {
    if ($Script:Credential -eq $null) {
        $Script:Credential = Get-Credential
    }
    Login-Anypoint $Script:Credential
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
    Context "RoleGroup" {
        It "Get-ApRoleGroup" {
            foreach ($org in $orgs) {
                $roles = Get-ApRoleGroup -OrganizationId $org.id | Select-Object -First 3
                foreach ($role in $roles) {
                    (Get-ApRoleGroup -OrganizationId $org.id -RoleGroupId $role.role_group_id).role_group_id | Should -Be $role.role_group_id
                    (Get-ApRoleGroup -OrganizationId $org.id -Name $role.name).role_group_id | Should -Be $role.role_group_id
                }        
            }
        }
        It "New-ApRoleGroup - Params" {
            $expected = @{
                name           = "$Script:PREFIX Role01";
                description    = "$Script:PREFIX Role01 Description";
                external_names = @("external_name_001", "external_name_002");
            }
            $new = New-ApRoleGroup -Name $expected.name -Description $expected.description -ExternalNames $expected.external_names
            $actual = Get-ApRoleGroup -RoleGroupId $new.role_group_id
            $actual.name | Should -BeExactly $expected.name
            $actual.description | Should -BeExactly $expected.description
            $actual.external_names | Sort-Object | Should -BeExactly ($expected.external_names | Sort-Object)
        }
        It "New-ApRoleGroup - Object" {
            $expected = @{
                name           = "$Script:PREFIX Role02";
                description    = "$Script:PREFIX Role02 Description";
                external_names = @("external_name_001", "external_name_002");
            }
            $new = $expected | New-ApRoleGroup
            $actual = Get-ApRoleGroup -RoleGroupId $new.role_group_id
            $actual.name | Should -BeExactly $expected.name
            $actual.description | Should -BeExactly $expected.description
            $actual.external_names | Sort-Object | Should -BeExactly ($expected.external_names | Sort-Object)
        }
        It "Set-ApRoleGroup" {
            $expected = Get-ApRoleGroup -Name "$Script:PREFIX Role01";
            $expected.name += " Edit"
            $expected.description += " Edit"
            $expected.external_names += "external_name_003"
            $upd = ($expected | Set-ApRoleGroup -RoleGroupId $expected.role_group_id)
            $actual = Get-ApRoleGroup -RoleGroupId $upd.role_group_id
            $actual.name | Should -BeExactly $expected.name
            $actual.description | Should -BeExactly $expected.description
            $actual.external_names | Sort-Object | Should -BeExactly ($expected.external_names | Sort-Object)
        }
        It "Set-ApRoleGroup - external_names" {
            $expected = Get-ApRoleGroup -Name "$Script:PREFIX Role02";
            $expected.external_names = $expected.external_names | Select-Object -First 1
            $upd = ($expected | Set-ApRoleGroup -RoleGroupId $expected.role_group_id)
            $actual = Get-ApRoleGroup -RoleGroupId $upd.role_group_id
            $actual.external_names | Sort-Object | Should -BeExactly ($expected.external_names | Sort-Object)
        }
        It "Remove-ApRoleGroup" {
            $rg01 = Get-ApRoleGroup -Name "$Script:PREFIX Role01 Edit";
            Remove-ApRoleGroup $rg01.role_group_id
            Get-ApRoleGroup -Name $rg01.name | Should -BeNullOrEmpty
            $rg02 = Get-ApRoleGroup -Name "$Script:PREFIX Role02";
            Remove-ApRoleGroup $rg02.role_group_id
            Get-ApRoleGroup -Name $rg02.name | Should -BeNullOrEmpty
        }
    }
}