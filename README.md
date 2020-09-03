# ![icon] Anypoint PowerShell
Powershell cmdlet for MuleSoft Anypoint Platform.


## Modules
Below is a table containing our Anypoint PowerShell rollup module.

Description                 | Module Name  | PowerShell Gallery Link
--------------------------- | ------------ | -----------------------
MuleSoft Anypoint Platform  | `Anypoint`   | [![Ap]][ApGallery]


## Installation

### PowerShell Gallery
Run the following command in an elevated PowerShell session to install the rollup module for Anypoint PowerShell cmdlets:

```powershell
Install-Module -Name Anypoint
```

This module runs on Windows PowerShell 5.x or PowerShell Core 6.x, PowerShell 7.x.

If you have an earlier version of the Anypoint PowerShell modules installed from the PowerShell Gallery and would like to update to the latest version, run the following commands in an elevated PowerShell session:

```powershell
Update-Module -Name Anypoint
```

## Usage

### Login to Anypoint Platform

To connect to Anypoint Platform, use the `Connect-ApAccount` cmdlet:

```powershell
# Interactively login - Input username and password.
Login-ApAccount

# Credential login - Use a previously created credential.
$credential = Get-Credential -UserName "max"
Login-ApAccount -Credential $credential
```




<!-- References -->
[icon]: docs/icon_48.png
[Ap]: https://img.shields.io/powershellgallery/v/Anypoint.svg?style=flat&label=Anypoint&color=blue
[ApGallery]: https://www.powershellgallery.com/packages/Anypoint/