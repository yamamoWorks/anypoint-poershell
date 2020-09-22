Install-Module -Name platyPS -Scope CurrentUser
Import-Module platyPS
Remove-Module Anypoint
Import-Module -Force .\src\Anypoint\Anypoint.psm1 -Prefix Ap
Update-MarkdownHelp .\docs
New-MarkdownHelp -Module Anypoint -OutputFolder .\docs
