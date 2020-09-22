---
external help file: Anypoint-help.xml
Module Name: Anypoint
online version:
schema: 2.0.0
---

# Get-ApEnvironment

## SYNOPSIS
{{ Fill in the Synopsis }}

## SYNTAX

### Query (Default)
```
Get-ApEnvironment [-Type <String>] [-IsProduction <Object>] [-Name <String>] [-OrganizationId <Guid>]
 [-BusinessGroup <PSObject>] [<CommonParameters>]
```

### Id
```
Get-ApEnvironment -EnvironmentId <Guid> [-OrganizationId <Guid>] [-BusinessGroup <PSObject>]
 [<CommonParameters>]
```

## DESCRIPTION
{{ Fill in the Description }}

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -EnvironmentId
{{ Fill EnvironmentId Description }}

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

### -IsProduction
{{ Fill IsProduction Description }}

```yaml
Type: Object
Parameter Sets: Query
Aliases:
Accepted values: True, False, 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
{{ Fill Name Description }}

```yaml
Type: String
Parameter Sets: Query
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OrganizationId
{{ Fill OrganizationId Description }}

```yaml
Type: Guid
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Type
{{ Fill Type Description }}

```yaml
Type: String
Parameter Sets: Query
Aliases:
Accepted values: Production, Sandbox, Design

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -BusinessGroup
{{ Fill BusinessGroup Description }}

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.Management.Automation.PSObject

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
