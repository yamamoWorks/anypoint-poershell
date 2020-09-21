Install-Module -Name platyPS -Scope CurrentUser
Import-Module platyPS
Import-Module -Force .\src\Anypoint\Anypoint.psm1
Update-MarkdownHelp .\docs
New-ExternalHelp -Path .\docs\ -OutputPath .\src\Anypoint\Anypoint-help.xml -Force
