class Context {
    [psobject] $Account
    [psobject] $BusinessGroup
    [psobject] $Environment

    Context() {
        $this.Clear()
    }
    
    [void] Clear() {
        $this.Account = $null
        $this.BusinessGroup = $null
        $this.Environment = $null
    }
}

function ConvertToPlainText([securestring] $secureString) {
    $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureString)
    $plainString = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
    [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
    return $plainString
}

function FirstOrDefaultIfArray($value, $default) {
    if ($value -is [array]) {
        if ($value.Count -gt 0) {
            $value[0]    
        }
        else {
            $default
        }
    }
    else {
        if ($null -ne $value) {
            $value
        }
        else {
            $default
        }
    }
}

function Expand-Property {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)][psobject] $InputObject,
        [Parameter(Mandatory = $true)][string] $propertyName
    )

    process {
        if ($InputObject | Get-Member -Name $propertyName) {
            $InputObject | Select-Object -ExpandProperty $propertyName
        }
        else {
            $InputObject
        }
    }
}

function New-DynamicParameterCollection {
    [CmdletBinding()]
    param (
    )
    
    process {
        New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
    }
}

function Add-DynamicParameter {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true)][System.Management.Automation.RuntimeDefinedParameterDictionary] $ParameterDictionary,
        [Parameter(Mandatory = $true)][string] $Name,
        [Parameter(Mandatory = $false)][switch] $Mandatory
    )
    
    process {
        $attribute = New-Object System.Management.Automation.ParameterAttribute
        $attribute.Mandatory = $Mandatory
        $collection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $collection.Add($attribute)
        $param = New-Object System.Management.Automation.RuntimeDefinedParameter($name, [string], $collection)
        $ParameterDictionary.Add($Name, $param)        
    }
}

function BindModel {
    param (
        [object] $Model,
        [System.Collections.IDictionary] $BoundParameters,
        [string[]] $Properties,
        [hashtable] $Mappings = @{}
    )
    
    $keyPairs = $Properties + $Mappings.Keys `
    | ForEach-Object { @{ PropertyName = $_; ParameterName = (IfNull $Mappings[$_] $_) } } `
    | Where-Object { $_.ParameterName -iin $BoundParameters.Keys }

    foreach ($keyPair in $keyPairs) {        
        $value = $BoundParameters[$keyPair.ParameterName]
        if ($value -is [SecureString]) {
            $value = (ConvertToPlainText $value)
        }
        elseif ($value -is [switch]) {
            $value = $value.ToBool()
        }
        $Model.($keyPair.PropertyName) = $value
    }
}

function GetRequiredValue ($object, $path) {
    $value = $object
    foreach ($prop in ($path -split '\.')) {
        $value = $value.$prop
    }
    if ($null -eq $value -or $null -eq "") {
        throw ("'{0}' is required." -f $path)
    }
    return $value
}

function IfNull($expression, $defaultValue) {
    if ($null -ne $expression) {
        return $expression
    }
    return $defaultValue
}