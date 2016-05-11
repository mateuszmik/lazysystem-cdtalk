Import-Module $PSScriptRoot\tools\psake\psake.psm1
$env:DEPLOYMENT_TARGET="DEV"
Invoke-psake .\deploypsake.ps1 uninstallservicetask
