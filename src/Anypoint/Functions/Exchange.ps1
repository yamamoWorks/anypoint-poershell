# Exchange Experience API
class Exchange {

    static [string] $BasePath = "/exchange/api/v1"

    static [string] Assets() {
        return [Exchange]::BasePath + "/assets"
    }

    static [string] Assets($groupId, $assetId) {
        return [Exchange]::BasePath + "/assets/$groupId/$assetId"
    }

    static [string] OrganizationAssets($organizationId, $groupId, $assetId) {
        return [Exchange]::BasePath + "/organizations/$organizationId/assets/$groupId/$assetId"
    }
}

function New-ExchangeAsset {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][ValidateSet("RAML-Fragment", "RAML", "OAS", "WSDL", "HTTP", "Custom")][string] $Classifier,
        [Parameter(Mandatory = $true)][string] $Name,
        [Parameter(Mandatory = $true)][string] $AssetId,
        [Parameter(Mandatory = $true)][string] $Version,
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

    process {
        $ApiVersion = $PSBoundParameters.ApiVersion
        $AssetFilePath = $PSBoundParameters.AssetFilePath
        $Main = $PSBoundParameters.Main

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
        
        $path = [Exchange]::Assets()
        Invoke-AnypointApi -Method Post -Path $path -Body $multiParts -MultipartForm
    }
}

function Get-ExchangeAsset {
    [CmdletBinding()]
    param (
        [Parameter(ParameterSetName = "Id", Mandatory = $false)][guid] $GroupId = $Script:Context.BusinessGroup.id,
        [Parameter(ParameterSetName = "Id", Mandatory = $true)][string] $AssetId,
        [Parameter(ParameterSetName = "Query", Mandatory = $false)][string] $Domain,
        [Parameter(ParameterSetName = "Query", Mandatory = $false)][guid[]] $OrganizationIds = @($Script:Context.BusinessGroup.id),
        [Parameter(ParameterSetName = "Query", Mandatory = $false)][string] $RuntimeVersion,
        [Parameter(ParameterSetName = "Query", Mandatory = $false)][int] $Offset,
        [Parameter(ParameterSetName = "Query", Mandatory = $false)][int] $Limit
    )
    
    process {
        $params = @{
            Domain         = $Domain;
            organizationId = $OrganizationIds;
            RuntimeVersion = $RuntimeVersion;
            Offset         = $PSBoundParameters["Offset"];
            Limit          = $PSBoundParameters["Limit"];
        }

        if ($PSCmdlet.ParameterSetName -eq "Id") {
            $path = [Exchange]::Assets($GroupId, $AssetId)
            Invoke-AnypointApi -Method Get -Path $path
        }
        else {
            $path = [Exchange]::Assets()
            Invoke-AnypointApi -Method Get -Path $path -QueryParameters $params
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
        [Parameter(Mandatory = $false)][int] $Offset,
        [Parameter(Mandatory = $false)][int] $Limit
    )
    
    process {
        $params = @{
            search         = $Search;
            domain         = $Domain;
            organizationId = $OrganizationIds;
            runtimeVersion = $RuntimeVersion;
            offset         = $PSBoundParameters["Offset"];
            limit          = $PSBoundParameters["Limit"];
        }

        $path = [Exchange]::Assets()
        Invoke-AnypointApi -Method Get -Path $path -QueryParameters $params
    }    
}

function Remove-ExchangeAsset {
    [CmdletBinding()]
    param (
        [Parameter(ParameterSetName = "Id", Mandatory = $false)][guid] $GroupId = $Script:Context.BusinessGroup.id,
        [Parameter(ParameterSetName = "Id", Mandatory = $true)][string] $AssetId,
        [Parameter(ParameterSetName = "Id", Mandatory = $false)][switch] $HardDelete,
        [Parameter(ParameterSetName = "Id", Mandatory = $false)][guid] $OrganizationId = $Script:Context.BusinessGroup.id,
        [Parameter(ParameterSetName = "Pipeline", Mandatory = $true, ValueFromPipeline = $true)][object] $Asset
    )
    
    process {
        $headers = @{
            "X-Delete-Type" = if ($HardDelete) { "hard-delete" }else { "soft-delete" }
        }

        if ([bool]$Asset) {
            $OrganizationId = GetRequiredValue $Asset "organization.id"
            $GroupId        = GetRequiredValue $Asset "groupId"
            $AssetId        = GetRequiredValue $Asset "assetId"
        }

        $path = [Exchange]::OrganizationAssets($OrganizationId, $GroupId, $AssetId)
        Invoke-AnypointApi -Method Delete -Path $path -AdditionalHeaders $headers
    }    
}


Export-ModuleMember -Function `
    New-ExchangeAsset, Get-ExchangeAsset, Search-ExchangeAsset, Remove-ExchangeAsset
