# Exchange Experience API
class Exchange {

    static [string] $BasePath = "/exchange/api/v1"

    static [string] Assets() {
        return [Exchange]::BasePath + "/assets"
    }
}

function New-ApExchangeAsset {
    [CmdletBinding()]
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

        $Script:Client.PostMultipartFormData([Exchange]::Assets(), $multiParts)
    }
}


Export-ModuleMember -Function `
    New-ApExchangeAsset
