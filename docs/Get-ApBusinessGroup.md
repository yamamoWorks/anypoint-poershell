---
external help file: Anypoint-help.xml
Module Name: Anypoint
online version:
schema: 2.0.0
---

# Get-ApBusinessGroup

## SYNOPSIS
Retrieves a list of organizations.

## SYNTAX

### ByName (Default)
```
Get-ApBusinessGroup [-Name <String>] [<CommonParameters>]
```

### Id
```
Get-ApBusinessGroup -OrganizationId <Guid> [<CommonParameters>]
```

## DESCRIPTION
In the case of specified the OrganizationId, returns the referenced organization.  
Otherwise, retrieves organizations that you are members.

## EXAMPLES

### EXAMPLE 1
```powershell
PS C:\> Get-ApBusinessGroup -OrganizationId 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'
```

## PARAMETERS

### -OrganizationId

```yaml
Type: Guid
Parameter Sets: Id
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name

```yaml
Type: String
Parameter Sets: ByName
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

[/accounts/api/organizations/{orgId} - ](https://bit.ly/3kbIzKs)

[/accounts/api/me - ](https://bit.ly/2RjzoLr)
