---
external help file: Anypoint-help.xml
Module Name: Anypoint
online version: https://bit.ly/3kbIzKs
schema: 2.0.0
---

# Get-ApCloudHubApplication

## SYNOPSIS
{{ Fill in the Synopsis }}

## SYNTAX

### Id
```
Get-ApCloudHubApplication -Domain <String> [<CommonParameters>]
```

### Query
```
Get-ApCloudHubApplication [-RetrieveStatistics] [-Period <Int32>] [-EnvironmentId <Guid>] [<CommonParameters>]
```

### Pipeline
```
Get-ApCloudHubApplication -Environment <Object> [<CommonParameters>]
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

### -Domain
{{ Fill Domain Description }}

```yaml
Type: String
Parameter Sets: Id
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Environment
{{ Fill Environment Description }}

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

### -EnvironmentId
{{ Fill EnvironmentId Description }}

```yaml
Type: Guid
Parameter Sets: Query
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Period
{{ Fill Period Description }}

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

### -RetrieveStatistics
{{ Fill RetrieveStatistics Description }}

```yaml
Type: SwitchParameter
Parameter Sets: Query
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

### System.Object

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
