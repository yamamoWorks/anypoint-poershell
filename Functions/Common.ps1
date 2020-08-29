# Common Library

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

function Search-Object {
    [CmdletBinding(PositionalBinding = $true)]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)][psobject] $InputObject,
        [Parameter(Mandatory = $true, Position = 0)][scriptblock] $ScriptBlock,
        [Parameter(Mandatory = $false)][string] $throwIfNotExist
    )
    
    begin {
        $count = 0
    }
    
    process {
        if ($ScriptBlock.Invoke($InputObject)) {
            $count++ | Out-Null
            $InputObject
        }
    }
    
    end {
        if ([bool]$throwIfNotExist -and $count -eq 0) {
            throw $throwIfNotExist
        }
    }
}

function Step-Property {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)][psobject] $InputObject,
        [Parameter(Mandatory = $true)][string] $propertyName
    )

    process {
        if ($InputObject | Get-Member -Name $propertyName) {
            $InputObject.$propertyName
        }
        else {
            $InputObject
        }
    }
}

class RestApi {

    static [psobject] CreateHeaders() {
        if (-not[bool]$Script:Context.AccessToken) {
            throw "Don't have AccessToken."
        }

        return @{
            "Content-Type"  = "application/json;charset=utf-8";
            "Authorization" = "bearer " + $Script:Context.AccessToken;
        }
    }    

    static [psobject] Get([string]$url) {
        $headers = [RestApi]::CreateHeaders()
        return Invoke-RestMethod -Method Get -Uri $url -Headers $headers | Step-Property -propertyName "data"
    }

    static [psobject] Delete([string]$url) {
        $headers = [RestApi]::CreateHeaders()
        return Invoke-RestMethod -Method Delete -Uri $url -Headers $headers | Step-Property -propertyName "data"
    }
    
    static [psobject] Post([string]$url, [psobject]$body) {
        $headers = [RestApi]::CreateHeaders()
        $data = [Text.Encoding]::UTF8.GetBytes(($body | ConvertTo-Json))
        return Invoke-RestMethod -Method Post -Uri $url -Body $data -Headers $headers | Step-Property -propertyName "data"
    }
    
    static [psobject] Put([string]$url, [psobject]$body) {
        $headers = [RestApi]::CreateHeaders()
        $data = [Text.Encoding]::UTF8.GetBytes(($body | ConvertTo-Json))
        return Invoke-RestMethod -Method Put -Uri $url -Body $data -Headers $headers | Step-Property -propertyName "data"
    }
}