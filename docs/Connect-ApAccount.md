---
external help file: Anypoint-help.xml
Module Name: Anypoint
online version:
schema: 2.0.0
---

# Connect-ApAccount

## SYNOPSIS
Connect to Anypoint Platform with an authenticated account for use with cmdlets from the Anypoint PowerShell modules.

## SYNTAX

```
Connect-ApAccount [[-Credential] <PSCredential>] [[-AccessToken] <String>] [<CommonParameters>]
```

## DESCRIPTION
The Connect-ApAccount cmdlet connects to Anypoint Platform with an authenticated account for use with cmdlets from the Anypoint PowerShell modules.  
After executing this cmdlet, you can disconnect from an Anypoint Platform account using Disconnect-ApAccount.

## EXAMPLES

### Example 1: Connect to Anypoint with interactive
```powershell
PS C:\> Connect-ApAccount
Username: maxthemule2020
Password: ********
```

### Example 2: Connect to Anypoint using credential
```powershell
PS C:\> $cred = Get-Credential

PowerShell credential request
Enter your credentials.
User: mulethemax2020
Password for user mulethemax2020: ********

PS C:\> Connect-ApAccount -Credential $cred
```

### Example 3: Connect to Anypoint using access token
```powershell
PS C:\> Connect-ApAccount -AccessToken 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'
```

### Example 4: Using 'Login-ApAccount' alias
```powershell
PS C:\> Login-ApAccount
Username: maxthemule2020
Password: ********
```

## PARAMETERS

### -AccessToken

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Credential

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

## NOTES

## RELATED LINKS
