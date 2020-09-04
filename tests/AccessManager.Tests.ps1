$VerbosePreference = "Continue"

$root = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
Import-Module "$root\src\Anypoint\Anypoint.psm1" -Force

$Script:PREFIX = "ANYPOINT_POWERSHELL_TEST"

BeforeAll {
    if ($Script:Credential -eq $null) {
        $Script:Credential = Get-Credential
    }
    Login-Account $Script:Credential
}

Describe "Basic" {
    BeforeAll {
        $orgs = Get-BusinessGroup | Select-Object -First 3
        $orgs | Out-Null
    }
    BeforeEach {
        Start-Sleep -Milliseconds 3000
    }
    It "Get-BusinessGroup" {
        foreach ($org in $orgs) {
            (Get-BusinessGroup -OrganizationId $org.id).id | Should -Be $org.id
            (Get-BusinessGroup -Name $org.name).id | Should -Be $org.id
        }
    }
    It "Get-Environment" {
        foreach ($org in $orgs) {
            $envs = Get-Environment -OrganizationId $org.id | Select-Object -First 3
            foreach ($ev in $envs) {
                (Get-Environment -OrganizationId $org.id -EnvironmentId $ev.id).id | Should -Be $ev.id
                (Get-Environment -OrganizationId $org.id -Name $ev.name).id | Should -Be $ev.id
                (Get-Environment -OrganizationId $org.id -Name $ev.name -Type $ev.type).id | Should -Be $ev.id
                (Get-Environment -OrganizationId $org.id -Name $ev.name -IsProduction $ev.isProduction).id | Should -Be $ev.id
            }
        }
    } 
    It "Get-RoleGroup" {
        foreach ($org in $orgs) {
            $roles = Get-RoleGroup -OrganizationId $org.id | Select-Object -First 3
            foreach ($role in $roles) {
                (Get-RoleGroup -OrganizationId $org.id -RoleGroupId $role.role_group_id).role_group_id | Should -Be $role.role_group_id
                (Get-RoleGroup -OrganizationId $org.id -Name $role.name).role_group_id | Should -Be $role.role_group_id
            }        
        }
    }
}

Describe "RoleGroup CRUD" {
    BeforeEach {
        Start-Sleep -Milliseconds 3000
    }
    It "New-RoleGroup - Params" {
        $expected = @{
            name           = "$Script:PREFIX Role01";
            description    = "$Script:PREFIX Role01 Description";
            external_names = @("external_name_001", "external_name_002");
        }
        $actual = New-RoleGroup -Name $expected.name -Description $expected.description -ExternalNames $expected.external_names
        $actual.name | Should -BeExactly $expected.name
        $actual.description | Should -BeExactly $expected.description
        $actual.external_names | Sort-Object | Should -BeExactly ($expected.external_names | Sort-Object)
            
        $Script:role01_id = $actual.role_group_id
    }
    It "New-RoleGroup - Object" {
        $expected = @{
            name           = "$Script:PREFIX Role02";
            description    = "$Script:PREFIX Role02 Description";
            external_names = @("external_name_001", "external_name_002");
        }
        $actual = $expected | New-RoleGroup
        $actual.name | Should -BeExactly $expected.name
        $actual.description | Should -BeExactly $expected.description
        $actual.external_names | Sort-Object | Should -BeExactly ($expected.external_names | Sort-Object)
            
        $Script:role02_id = $actual.role_group_id
    }
    It "Update-RoleGroup" {
        $expected = Get-RoleGroup -RoleGroupId $Script:role01_id
        $expected.name += " Edit"
        $expected.description += " Edit"
        $expected.external_names += "external_name_003"

        $actual = $expected | Update-RoleGroup -RoleGroupId $expected.role_group_id
        $actual.name | Should -BeExactly $expected.name
        $actual.description | Should -BeExactly $expected.description
        $actual.external_names | Sort-Object | Should -BeExactly ($expected.external_names | Sort-Object)
    }
    It "Set-RoleGroup" {
        $original = Get-RoleGroup -RoleGroupId $Script:role02_id
        $expected = @{
            name           = $original.name + " Edit";
            description    = $original.description + " Edit";
            external_names = $original.external_names += "external_names_003"
        }

        $actual = Set-RoleGroup -RoleGroupId $original.role_group_id -Name $expected.name
        $actual.name | Should -BeExactly $expected.name
        $actual.description | Should -BeExactly $original.description
            
        $actual = Set-RoleGroup -RoleGroupId $original.role_group_id -Description $expected.description
        $actual.description | Should -BeExactly $expected.description
        $actual.name | Should -BeExactly $expected.name
            
        $actual = Set-RoleGroup -RoleGroupId $original.role_group_id -ExternalNames $expected.external_names
        $actual.external_names | Sort-Object | Should -BeExactly ($expected.external_names | Sort-Object)
        $actual.name | Should -BeExactly $expected.name
        $actual.description | Should -BeExactly $expected.description
    }
    It "Add/Remove-RoleGroupExternalName" {
        $original = Get-RoleGroup -RoleGroupId $Script:role01_id

        $actual = Add-RoleGroupExternalName -RoleGroupId $original.role_group_id -ExternalNames "external_name_004"
        $actual.external_names | Should -Contain "external_name_004"
        $actual.name | Should -BeExactly $original.name
        $actual.description | Should -BeExactly $original.description

        $actual = Add-RoleGroupExternalName -RoleGroupId $original.role_group_id -ExternalNames "external_name_005", "external_name_006"
        $actual.external_names | Should -Contain "external_name_005"
        $actual.external_names | Should -Contain "external_name_006"

        $actual = Remove-RoleGroupExternalName -RoleGroupId $original.role_group_id -ExternalNames "external_name_006"
        $actual.external_names | Should -Not -Contain "external_name_006"
        $actual.name | Should -BeExactly $original.name
        $actual.description | Should -BeExactly $original.description
            
        $actual = Remove-RoleGroupExternalName -RoleGroupId $original.role_group_id -ExternalNames "external_name_004", "external_name_005"
        $actual.external_names | Should -Not -Contain "external_name_004"
        $actual.external_names | Should -Not -Contain "external_name_005"
    }
    It "Remove-RoleGroup" {
        $rg01 = Get-RoleGroup -RoleGroupId $Script:role01_id
        Remove-RoleGroup $rg01.role_group_id
        Get-RoleGroup -Name $rg01.name | Should -BeNullOrEmpty

        $rg02 = Get-RoleGroup -RoleGroupId $Script:role02_id
        Remove-RoleGroup $rg02.role_group_id
        Get-RoleGroup -Name $rg02.name | Should -BeNullOrEmpty
    }
}

Describe "User" {
    BeforeAll {
        if ($Script:Password -eq $null) {
            $Script:Password = Read-Host "Password of user to create" -AsSecureString
        }
    }
    BeforeEach {
        Start-Sleep -Milliseconds 3000
    }
    It "New-User - Params 1" {
        $date = Get-Date -Format 'yyMMdd'
        $time = Get-Date -Format 'HHmmssfff'
        $expected = @{
            username = "apuser-$date$time"
            password = $password
        }

        $actual = New-User `
            -Username $expected.username `
            -Password $expected.password

        $actual.username    | Should -BeExactly $expected.username
        $actual.firstName   | Should -BeExactly "unknown"
        $actual.lastName    | Should -BeExactly "unknown"
        $actual.email       | Should -BeExactly "unknown"
        $actual.phoneNumber | Should -BeExactly "111-111-1111"
    }
    It "New-User - Params 2" {
        $date = Get-Date -Format 'yyMMdd'
        $time = Get-Date -Format 'HHmmssfff'
        $expected = @{
            username    = "apuser-$date$time"
            firstName   = "fn-$time"
            lastName    = "ln-$date"
            phoneNumber = "00-$time"
            email       = "$time@$date.email"
            password    = $password
        }

        $actual = New-User `
            -Username    $expected.username `
            -Password    $expected.password `
            -FirstName   $expected.firstName `
            -LastName    $expected.lastName `
            -Email       $expected.email `
            -PhoneNumber $expected.phoneNumber

        $actual.username    | Should -BeExactly $expected.username
        $actual.firstName   | Should -BeExactly $expected.firstName
        $actual.lastName    | Should -BeExactly $expected.lastName
        $actual.phoneNumber | Should -BeExactly $expected.phoneNumber
        $actual.email       | Should -BeExactly $expected.email
        $actual.phoneNumber | Should -BeExactly $expected.phoneNumber
    }
    It "New-User - Pipeline 1" {
        $date = Get-Date -Format 'yyMMdd'
        $time = Get-Date -Format 'HHmmssfff'
        $expected = @{
            username = "apuser-$date$time"
            password = (ConvertToPlainText $password)
        }

        $actual = $expected | New-User

        $actual.username    | Should -BeExactly $expected.username
        $actual.firstName   | Should -BeExactly "unknown"
        $actual.lastName    | Should -BeExactly "unknown"
        $actual.email       | Should -BeExactly "unknown"
        $actual.phoneNumber | Should -BeExactly "111-111-1111"
    }
    It "New-User - Pipeline 2" {
        $date = Get-Date -Format 'yyMMdd'
        $time = Get-Date -Format 'HHmmssfff'
        $expected = @{
            username    = "apuser-$date$time"
            firstName   = "fn-$time"
            lastName    = "fn-$date"
            phoneNumber = "00-$time"
            email       = "$time@$date.email"
            password    = (ConvertToPlainText $password)
        }

        $actual = $expected | New-User

        $actual.username    | Should -BeExactly $expected.username
        $actual.firstName   | Should -BeExactly $expected.firstName
        $actual.lastName    | Should -BeExactly $expected.lastName
        $actual.phoneNumber | Should -BeExactly $expected.phoneNumber
        $actual.email       | Should -BeExactly $expected.email
    }
    It "Set-User - Params" {
        $user = Get-User | Where-Object { $_.username -like "apuser-*" } | Select-Object -First 1
        $expected = @{
            firstName   = ("UPD_" + $user.firstName)
            lastName    = ("UPD_" + $user.lastName)
            phoneNumber = ("9-" + $user.phoneNumber)
            email       = ("9-" + $user.email)
            enabled     = -not $user.enabled
            properties  = @{ xxx_config = @{ aaa = 100; bbb = "002" } }
        }

        $actual = Set-User `
            -UserId      $user.id `
            -FirstName   $expected.firstName `
            -LastName    $expected.lastName `
            -Email       $expected.email `
            -PhoneNumber $expected.phoneNumber `
            -Enabled     $expected.enabled `
            -Properties  $expected.properties

        $actual.firstName   | Should -BeExactly $expected.firstName
        $actual.lastName    | Should -BeExactly $expected.lastName
        $actual.phoneNumber | Should -BeExactly $expected.phoneNumber
        $actual.email       | Should -BeExactly $expected.email
        $actual.enabled     | Should -BeExactly $expected.enabled
        $actual.properties.xxx_config.aaa | Should -BeExactly $expected.properties.xxx_config.aaa
        $actual.properties.xxx_config.bbb | Should -BeExactly $expected.properties.xxx_config.bbb
    }
    It "Set-User - Pipeline" {
        $user = Get-User | Where-Object { $_.username -like "apuser-*" } | Select-Object -Skip 1 -First 1
        $expected = @{
            firstName   = ("UPD_" + $user.firstName)
            lastName    = ("UPD_" + $user.lastName)
            phoneNumber = ("9-" + $user.phoneNumber)
            email       = ("9-" + $user.email)
            enabled     = -not $user.enabled
            properties  = @{ xxx_config = @{ aaa = 100; bbb = "002" } }
        }

        $actual = $expected | Set-User -UserId $user.id

        $actual.firstName   | Should -BeExactly $expected.firstName
        $actual.lastName    | Should -BeExactly $expected.lastName
        $actual.phoneNumber | Should -BeExactly $expected.phoneNumber
        $actual.email       | Should -BeExactly $expected.email
        $actual.enabled     | Should -BeExactly $expected.enabled
        $actual.properties.xxx_config.aaa | Should -BeExactly $expected.properties.xxx_config.aaa
        $actual.properties.xxx_config.bbb | Should -BeExactly $expected.properties.xxx_config.bbb
    }
    It "Remove-User" {
        $users = Get-User -Limit 500 | Where-Object { $_.username -like "apuser-*" }

        Remove-User -UserId $users[0].id
        { Get-User -UserId $users[0].id } | Should -Throw

        Remove-User -UserId ($users | Select-Object -Skip 1 | ForEach-Object { $_.id })
        $actual = Get-User -Limit 500 | Where-Object { $_.username -like "apuser-*" }
        $actual.Count | Should -Be 0
    }
}