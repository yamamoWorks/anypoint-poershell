# Exchange Experience API
class Exchange {

    static [string] $BasePath = "/exchange/api/v1"

    static [string] Assets() {
        return [Exchange]::BasePath + "/assets"
    }

    static [string] Assets($organizationId) {
        return [Exchange]::BasePath + "/organizations/$organizationId/assets"
    }
}

function New-ExchangeAsset {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $true)][string] $AssetId,
        [Parameter(Mandatory = $true)][string] $Version,
        [Parameter(Mandatory = $true)][string] $Name,
        [Parameter(Mandatory = $true)][ValidateSet("RAML-Fragment", "RAML", "OAS", "WSDL", "HTTP", "Custom")][string] $Classifier,
        [Parameter(Mandatory = $false)][guid] $OrganizationId = $Script:Context.BusinessGroup.id,
        [Parameter(Mandatory = $false)][guid] $GroupId = $Script:Context.BusinessGroup.id
    )

    dynamicparam {
        $dynamicParams = New-DynamicParameterCollection
        $helpMode = -not[bool]$PSBoundParameters.Classifier

        # ApiVersion
        if ($helpMode -or $Classifier -in "RAML", "OAS", "WSDL", "HTTP") {
            $dynamicParams | Add-DynamicParameter -Name "ApiVersion" -Mandatory
        }

        # Main, AssetFilePath
        if ($helpMode -or $Classifier -in "RAML", "OAS", "WSDL", "RAML-Fragment") {
            $dynamicParams | Add-DynamicParameter -Name "Main"
            $dynamicParams | Add-DynamicParameter -Name "AssetFilePath" -Mandatory
        }

        return $dynamicParams
    }

    begin {
        $ApiVersion = $PSBoundParameters.ApiVersion
        $Main = $PSBoundParameters.Main
        $AssetFilePath = $PSBoundParameters.AssetFilePath
    }

    process {
        $multiParts = @{
            organizationId = $OrganizationId
            groupId        = $GroupId
            assetId        = $AssetId
            version        = $Version
            name           = $Name
            classifier     = $Classifier.ToLower()
            apiVersion     = $ApiVersion
            main           = $Main
            asset          = if ([bool]$AssetFilePath) { Get-Item -Path $AssetFilePath }
        }

        $url = [Exchange]::Assets()
        if ($PSCmdlet.ShouldProcess((FormatUrlAndBody $url $multiParts), "Post")) {
            $Script:Client.PostMultipartFormData($url, $multiParts)
        }
    }
}

function Get-ExchangeAsset {
    [CmdletBinding()]
    param (
        [Parameter(ParameterSetName = "Single", Mandatory = $false)][guid] $GroupId = $Script:Context.BusinessGroup.id,
        [Parameter(ParameterSetName = "Single", Mandatory = $true)][string] $AssetId,
        [Parameter(ParameterSetName = "Multiple", Mandatory = $false)][string] $Domain,
        [Parameter(ParameterSetName = "Multiple", Mandatory = $false)][guid[]] $OrganizationIds = @($Script:Context.BusinessGroup.id),
        [Parameter(ParameterSetName = "Multiple", Mandatory = $false)][string] $RuntimeVersion,
        [Parameter(ParameterSetName = "Multiple", Mandatory = $false)][int] $Offset = 0,
        [Parameter(ParameterSetName = "Multiple", Mandatory = $false)][int] $Limit = 10
    )
    
    process {
        $params = @{
            Domain         = $Domain;
            organizationId = $OrganizationIds;
            RuntimeVersion = $RuntimeVersion;
            Offset         = $Offset;
            Limit          = $Limit;
        }

        if ($PSCmdlet.ParameterSetName -eq "Single") {
            $Script:Client.Get([Exchange]::Assets() + "/$GroupId/$AssetId")
        }
        else {
            $Script:Client.Get([Exchange]::Assets(), $params)
        }
    }    
}

function Search-ExchangeAsset {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)][string] $Search,
        [Parameter(Mandatory = $false)][string] $Domain,
        [Parameter(Mandatory = $false)][guid[]] $OrganizationIds = @($Script:Context.BusinessGroup.id),
        [Parameter(Mandatory = $false)][string] $RuntimeVersion,
        [Parameter(Mandatory = $false)][int] $Offset = 0,
        [Parameter(Mandatory = $false)][int] $Limit = 10
    )
    
    process {
        $params = @{
            search         = $Search;
            domain         = $Domain;
            organizationId = $OrganizationIds;
            runtimeVersion = $RuntimeVersion;
            offset         = $Offset;
            limit          = $Limit;
        }

        $Script:Client.Get([Exchange]::Assets(), $params)
    }    
}

function Remove-ExchangeAsset {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $true)][string] $AssetId,
        [Parameter(Mandatory = $false)][switch] $HardDelete,
        [Parameter(Mandatory = $false)][guid] $OrganizationId = $Script:Context.BusinessGroup.id,
        [Parameter(Mandatory = $false)][guid] $GroupId = $Script:Context.BusinessGroup.id
    )
    
    process {
        $headers = @{
            "X-Delete-Type" = if ($HardDelete) { "hard-delete" }else { "soft-delete" }
        }

        $url = [Exchange]::Assets($OrganizationId) + "/$GroupId/$AssetId"
        if ($PSCmdlet.ShouldProcess($url, "Delete")) {
            $Script:Client.Delete($url, $headers)
        }
    }    
}


Export-ModuleMember -Function `
    New-ExchangeAsset, Get-ExchangeAsset, Search-ExchangeAsset, Remove-ExchangeAsset
