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

    [psobject] Get([string]$url) {
        return $this.InvokeMethodWithJsonInternal("Get", $url, $null, $null)
    }

    [psobject] Get([string]$url, [hashtable]$params) {
        return $this.InvokeMethodWithJsonInternal("Get", $url, $params, $null)
    }

    [psobject] Delete([string]$url) {
        return $this.InvokeMethodWithJsonInternal("Delete", $url, $null, $null)
    }
    
    [psobject] Post([string]$url, [psobject]$body) {
        return $this.InvokeMethodWithJsonInternal("Post", $url, $null, $body)
    }
    
    [psobject] PostMultipartFormData([string]$url, [hashtable]$body) {
        return $this.InvokeMethodWithMultipartFormDataInternal("Post", $url, $body)
    }
       
    [psobject] Put([string]$url, [psobject]$body) {
        return $this.InvokeMethodWithJsonInternal("Put", $url, $null, $body)
    }
        
    [psobject] Patch([string]$url, [psobject]$body) {
        return $this.InvokeMethodWithJsonInternal("Patch", $url, $null, $body)
    }

    [psobject] InvokeMethodWithJsonInternal([Microsoft.PowerShell.Commands.WebRequestMethod]$method, [string]$path, [hashtable]$params, [psobject]$body) {

        $data = $null
        if ([bool]$body) {
            $json = ($body | ConvertTo-Json)
            Write-Verbose $json
            $data = [Text.Encoding]::UTF8.GetBytes($json)
        }

        $headers = @{ "Content-Type" = "application/json" }
        if ([bool]$this.AccessToken) {
            $headers["Authorization"] = ("Bearer " + $this.AccessToken);
        }

        $url = ($this.BaseUrl + $path)
        
        if ([bool]$params) {
            $queryParameter = (($params.Keys | Where-Object { [bool]$params[$_] } | ForEach-Object { $_ + "=" + $params[$_] }) -join "&")
            if ([bool]$queryParameter) {
                $url += ("?" + $queryParameter)
            }
        }

        return Invoke-RestMethod -Method $method -Uri $url -Headers $headers -Body $data
    }

    [psobject] InvokeMethodWithMultipartFormDataInternal([Microsoft.PowerShell.Commands.WebRequestMethod]$method, [string]$path, [hashtable]$body) {

        $boundary = "-----FormBoundary=" + [guid]::NewGuid().ToString("N")
        $data = New-Object System.Net.Http.MultipartFormDataContent($boundary)

        foreach ($key in $body.Keys) {
            $value = $body[$key]
            if ([bool]$value) {
                if ($value -is [System.IO.FileInfo]) {
                    [System.IO.FileInfo]$file = $value
                    $fileStream = $file.OpenRead()
                    $fileContent = New-Object System.Net.Http.StreamContent($fileStream)
                    $fileName = $file.Name
                    $fileContent.Headers.Add('Content-Disposition', "form-data; name=`"$key`"; filename=`"$fileName`"");
                    $data.Add($fileContent)
                }
                else {
                    Write-Verbose "$key=$value"
                    $content = New-Object System.Net.Http.StringContent("$value")
                    $content.Headers.Add('Content-Disposition', "form-data; name=`"$key`"");
                    $content.Headers.Remove('Content-Type') | Out-Null;
                    $data.Add($content)
                }
            }
        }
        $postDataFile = [System.IO.Path]::GetTempFileName()
        [System.IO.File]::WriteAllBytes($postDataFile, $data.ReadAsByteArrayAsync().Result)

        $headers = @{ "Content-Type" = "multipart/form-data; boundary=$boundary" }
        if ([bool]$this.AccessToken) {
            $headers["Authorization"] = ("Bearer " + $this.AccessToken);
        }

        $url = ($this.BaseUrl + $path)

        try {
            return Invoke-RestMethod -Method $method -Uri $url -Headers $headers -InFile $postDataFile
        }
        finally {
            Remove-Item -Path $postDataFile -Force | Out-Null
        }
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
        $attribute.Mandatory = $true
        $collection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $collection.Add($attribute)
        $param = New-Object System.Management.Automation.RuntimeDefinedParameter($name, [string], $collection)
        $ParameterDictionary.Add($Name, $param)        
    }
}

function FormatUrlAndBody ($url, $body) {
    return $url + "`n" + ($body | ConvertTo-Json) + "`n"
}