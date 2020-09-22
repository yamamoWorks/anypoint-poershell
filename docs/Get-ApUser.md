---
external help file: Anypoint-help.xml
Module Name: Anypoint
online version:
schema: 2.0.0
---

# Get-ApUser

## SYNOPSIS
{{ Fill in the Synopsis }}

## SYNTAX

### Query (Default)
```
Get-ApUser [-Type <String>] [-Offset <Int32>] [-Limit <Int32>] [-OrganizationId <Guid>] [<CommonParameters>]
```

### Id
```
Get-ApUser -UserId <Guid> [-OrganizationId <Guid>] [<CommonParameters>]
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

### -Limit
{{ Fill Limit Description }}

```yaml
Type: Int32
Parameter Sets: Query
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Offset
{{ Fill Offset Description }}

```yaml
Type: Int32
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
Accepted values: Host, Proxy, All

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UserId
{{ Fill UserId Description }}

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
