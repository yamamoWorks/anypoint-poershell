---
external help file: Anypoint-help.xml
Module Name: Anypoint
online version: https://bit.ly/3kbIzKs
schema: 2.0.0
---

# New-ApCloudHubApplication

## SYNOPSIS
{{ Fill in the Synopsis }}

## SYNTAX

### Params
```
New-ApCloudHubApplication -Domain <String> -JarFile <FileInfo> [-AutoStart] [-WorkerSize <Object>]
 [-Workers <Int32>] [-RuntimeVersion <String>] [-Region <Object>] [-AutoRestartWhenNotResponding]
 [-PersistentQueues] [-EncryptPersistentQueues] [-DisableCloudHubLog] [-UseObjectStoreV2]
 [-Properties <Object>] [-LogLevels <Object[]>] [-UseStaticIP] [-EnvironmentId <Guid>] [<CommonParameters>]
```

### Pipeline
```
New-ApCloudHubApplication -AppInfoJson <Object> [-EnvironmentId <Guid>] [<CommonParameters>]
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

### -AppInfoJson
{{ Fill AppInfoJson Description }}

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

### -AutoRestartWhenNotResponding
{{ Fill AutoRestartWhenNotResponding Description }}

```yaml
Type: SwitchParameter
Parameter Sets: Params
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AutoStart
{{ Fill AutoStart Description }}

```yaml
Type: SwitchParameter
Parameter Sets: Params
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DisableCloudHubLog
{{ Fill DisableCloudHubLog Description }}

```yaml
Type: SwitchParameter
Parameter Sets: Params
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Domain
{{ Fill Domain Description }}

```yaml
Type: String
Parameter Sets: Params
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -EncryptPersistentQueues
{{ Fill EncryptPersistentQueues Description }}

```yaml
Type: SwitchParameter
Parameter Sets: Params
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -EnvironmentId
{{ Fill EnvironmentId Description }}

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

### -JarFile
{{ Fill JarFile Description }}

```yaml
Type: FileInfo
Parameter Sets: Params
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LogLevels
{{ Fill LogLevels Description }}

```yaml
Type: Object[]
Parameter Sets: Params
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PersistentQueues
{{ Fill PersistentQueues Description }}

```yaml
Type: SwitchParameter
Parameter Sets: Params
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Properties
{{ Fill Properties Description }}

```yaml
Type: Object
Parameter Sets: Params
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Region
{{ Fill Region Description }}

```yaml
Type: Object
Parameter Sets: Params
Aliases:
Accepted values: us-east-1, us-east-2, us-west-1, us-west-2, ca-central-1, eu-west-1, eu-central-1, eu-west-2, ap-northeast-1, ap-southeast-1, ap-southeast-2, sa-east-1

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RuntimeVersion
{{ Fill RuntimeVersion Description }}

```yaml
Type: String
Parameter Sets: Params
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UseObjectStoreV2
{{ Fill UseObjectStoreV2 Description }}

```yaml
Type: SwitchParameter
Parameter Sets: Params
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UseStaticIP
{{ Fill UseStaticIP Description }}

```yaml
Type: SwitchParameter
Parameter Sets: Params
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WorkerSize
{{ Fill WorkerSize Description }}

```yaml
Type: Object
Parameter Sets: Params
Aliases:
Accepted values: 0.1, 0.2, 1, 2, 4, 8, 16

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Workers
{{ Fill Workers Description }}

```yaml
Type: Int32
Parameter Sets: Params
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
