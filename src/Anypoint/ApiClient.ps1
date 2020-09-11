$Script:AccessToken = $null
$Script:BaseUrl = 'https://anypoint.mulesoft.com'

function Invoke-AnypointApi {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $true )][Microsoft.PowerShell.Commands.WebRequestMethod] $Method,
        [Parameter(Mandatory = $true )][String] $Path,
        [Parameter(Mandatory = $false)][System.Collections.IDictionary] $QueryParameters,
        [Parameter(Mandatory = $false)][Object] $Body,
        [Parameter(Mandatory = $false)][System.Collections.IDictionary] $AdditionalHeaders,
        [Parameter(Mandatory = $false)][Guid] $BusinessGroupId,
        [Parameter(Mandatory = $false)][Guid] $EnvironmentId,
        [Parameter(Mandatory = $false)][Switch] $MultipartForm
    )
    
    process {
        $params = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)
        foreach ($key in $QueryParameters.Keys) {
            $value = $QueryParameters[$key]
            if ($null -ne $value) {
                $value | ForEach-Object { $params.Add($key, $_) }
            }
        }

        $url = $Script:BaseUrl + $Path
        if ($params.Count -gt 0) {
            $url += ("?" + $params.ToString())
        }

        $headers = @{}
        if ([bool]$Script:AccessToken) {
            $headers["Authorization"] = ("Bearer " + $Script:AccessToken);
        }
        if ([bool]$EnvironmentId) {
            $headers["X-ANYPNT-ENV-ID"] = $EnvironmentId
        }
        if ([bool]$BusinessGroupId) {
            $headers["X-ANYPNT-ORG-ID"] = $BusinessGroupId
        }
        if ([bool]$AdditionalHeaders) {
            $headers += $AdditionalHeaders
        }

        if ($MultipartForm) {
            $boundary = "-----Boundary-" + [guid]::NewGuid().ToString("N")
            $headers["Content-Type"] = "multipart/form-data; boundary=$boundary"
            Write-Verbose ("Headers:`n" + ($headers | ConvertTo-Json))

            $data = New-Object System.Net.Http.MultipartFormDataContent($boundary)
            foreach ($key in $Body.Keys) {
                $value = $Body[$key]
                if ($value -is [System.IO.FileInfo]) {
                    [System.IO.FileInfo]$file = $value
                    $fileContent = New-Object System.Net.Http.StreamContent($file.OpenRead())
                    $fileContent.Headers.Add('Content-Disposition', 'form-data; name="' + $key + '"; filename="' + $file.Name + '"');
                    $data.Add($fileContent)
                    Write-Verbose ("MultipartFormData: $key=" + $file.FullName)
                }
                else {
                    $content = New-Object System.Net.Http.StringContent("{0}" -f $value)
                    $content.Headers.Add('Content-Disposition', 'form-data; name="' + $key + '"');
                    $content.Headers.Remove('Content-Type') | Out-Null;
                    $data.Add($content)
                    Write-Verbose ("MultipartFormData: $key=$value")
                }
            }

            try {
                $dataFile = [System.IO.Path]::GetTempFileName()
                [System.IO.File]::WriteAllBytes($dataFile, $data.ReadAsByteArrayAsync().Result)
    
                if ($PSCmdlet.ShouldProcess($url, $Method)) {
                    $result = Invoke-RestMethod -Method $Method -Uri $url -Headers $headers -InFile $dataFile
                    Write-Verbose ("Response:`n" + ($result | ConvertTo-Json))
                    $result
                }
            }
            finally {
                $data.Dispose()
                Remove-Item -Path $dataFile -Force -ErrorAction Ignore | Out-Null
            }
        }
        else {
            $data = $null
            if ([bool]$Body) {
                $headers["Content-Type"] = "application/json"
                Write-Verbose ("Headers:`n" + ($headers | ConvertTo-Json))

                $json = ($Body | ConvertTo-Json)
                Write-Verbose ("Body:`n" + $json)
                $data = [Text.Encoding]::UTF8.GetBytes($json)
            }

            if ($PSCmdlet.ShouldProcess($url, $Method)) {
                $result = Invoke-RestMethod -Method $Method -Uri $url -Headers $headers -Body $data
                Write-Verbose ("Response:`n" + ($result | ConvertTo-Json))
                $result
            }
        }
    }
}
