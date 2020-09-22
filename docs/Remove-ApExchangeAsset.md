---
external help file: Anypoint-help.xml
Module Name: Anypoint
online version:
schema: 2.0.0
---

# Remove-ApExchangeAsset

## SYNOPSIS
{{ Fill in the Synopsis }}

## SYNTAX

### Id
```
Remove-ApExchangeAsset [[-GroupId] <Guid>] [-AssetId] <String> [-HardDelete] [[-OrganizationId] <Guid>]
 [<CommonParameters>]
```

### Pipeline
```
Remove-ApExchangeAsset -Asset <Object> [<CommonParameters>]
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

### -AssetId
{{ Fill AssetId Description }}

```yaml
Type: String
Parameter Sets: Id
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -GroupId
{{ Fill GroupId Description }}

```yaml
Type: Guid
Parameter Sets: Id
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -HardDelete
{{ Fill HardDelete Description }}

```yaml
Type: SwitchParameter
Parameter Sets: Id
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
Parameter Sets: Id
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Asset
{{ Fill Asset Description }}

```yaml
Type: Object
Parameter Sets: Pipeline
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.Object

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
