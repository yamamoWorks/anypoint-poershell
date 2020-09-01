class Context {
    [psobject] $Account
    [psobject] $BusinessGroup
    [psobject] $Environment

    Context() {
        $this.Clear()
    }
    
    [void] Clear() {
        $this.Account = @{ 
            id                         = [Guid]::Empty;
            username                   = $null;
            contributorOfOrganizations = @();
        }
        $this.BusinessGroup = @{ 
            id   = [Guid]::Empty ;
            name = $null;
        }
        $this.Environment = @{ 
            id   = [Guid]::Empty ;
            name = $null;
        }
    }
}

class AnypointClilent {

    [string] $BaseUrl
    [string] $AccessToken

    AnypointClilent([string] $baseUrl) {
        $this.BaseUrl = $baseUrl
    }

    [void] SetAccessToken([string]$token) {
        $this.AccessToken = $token
    }

    [void] ClearAccessToken() {
        $this.AccessToken = $null
    }

    [psobject] CreateHeaders() {
        $header = @{ "Content-Type" = "application/json;charset=utf-8" }

        if ([bool]$this.AccessToken) {
            $header["Authorization"] = ("Bearer " + $this.AccessToken);
        }

        return $header
    }

    [psobject] Get([string]$url) {
        return $this.InvokeMethodInternal("Get", $url, $null, $null)
    }

    [psobject] Get([string]$url, [hashtable]$params) {
        return $this.InvokeMethodInternal("Get", $url, $params, $null)
    }

    [psobject] Delete([string]$url) {
        return $this.InvokeMethodInternal("Delete", $url, $null, $null)
    }
    
    [psobject] Delete([string]$url, [hashtable]$params) {
        return $this.InvokeMethodInternal("Delete", $url, $params, $null)
    }
    
    [psobject] Post([string]$url, [psobject]$body) {
        return $this.InvokeMethodInternal("Post", $url, $null, $body)
    }
        
    [psobject] Post([string]$url, [hashtable]$params, [psobject]$body) {
        return $this.InvokeMethodInternal("Post", $url, $params, $body)
    }

    [psobject] Put([string]$url, [psobject]$body) {
        return $this.InvokeMethodInternal("Put", $url, $null, $body)
    }

    [psobject] Put([string]$url, [hashtable]$params, [psobject]$body) {
        return $this.InvokeMethodInternal("Put", $url, $params, $body)
    }

    [psobject] Patch([string]$url, [psobject]$body) {
        return $this.InvokeMethodInternal("Patch", $url, $null, $body)
    }

    [psobject] Patch([string]$url, [hashtable]$params, [psobject]$body) {
        return $this.InvokeMethodInternal("Patch", $url, $params, $body)
    }

    [psobject] InvokeMethodInternal([Microsoft.PowerShell.Commands.WebRequestMethod]$method, [string]$path, [hashtable]$params, [psobject]$body) {
        $headers = $this.CreateHeaders()
        
        $url = ($this.BaseUrl + $path)
        
        if ([bool]$params) {
            $url += "?" + (($params.Keys | Where-Object { [bool]$params[$_] } | ForEach-Object { $_ + "=" + $params[$_] }) -join "&")
        }
        Write-Verbose $url
        
        if ([bool]$body) {
            $data = [Text.Encoding]::UTF8.GetBytes(($body | ConvertTo-Json))
        }
        else {
            $data = $null
        }
        
        return Invoke-RestMethod -Method $method -Uri $url -Body $data -Headers $headers
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
