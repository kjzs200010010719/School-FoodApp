$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
. (Join-Path $PSScriptRoot '..\windows-service\service_helpers.ps1')

function Assert-True($condition, $message) {
    if (-not $condition) { throw $message }
}
function Assert-Throws([scriptblock]$operation) {
    $failed = $false
    try { & $operation } catch { $failed = $true }
    Assert-True $failed 'Expected operation to fail.'
}

$backend = 'C:\School & Demo\backend'
$config = New-FoodApiServiceConfiguration $backend 'C:\Program Files\nodejs\node.exe' 'C:\ProgramData\SchoolFoodAppApi\logs'
[xml]$roundtrip = $config.OuterXml
Assert-True ($roundtrip.service.workingdirectory -eq $backend) 'XML path did not round-trip.'
Assert-True ($roundtrip.service.arguments -eq '"C:\School & Demo\backend\src\server.js"') 'Node entrypoint must be quoted.'
Assert-True ($roundtrip.service.serviceaccount.user -eq 'LocalService') 'Service must not use administrator identity.'
Assert-True ($roundtrip.service.depend -eq 'MySQLFoodApp') 'Wrong database dependency.'
Assert-True ($roundtrip.service.startmode -eq 'Automatic') 'Automatic startup missing.'
Assert-True ($roundtrip.service.onfailure.action -eq 'restart') 'Crash recovery missing.'
Assert-True ($roundtrip.service.log.keepFiles -eq '5') 'Log rotation missing.'
$hostSetting = $roundtrip.service.env | Where-Object name -eq 'HOST'
Assert-True ($hostSetting.value -eq '127.0.0.1') 'API must remain loopback-only.'
Assert-True ($roundtrip.OuterXml -notmatch 'DB_PASSWORD') 'Do not copy database secrets into XML.'
foreach ($invalid in @('relative', 'C:relative', '\relative', 'C:\bad"path', 'C:\%TEMP%\backend', "C:\bad`npath")) {
    Assert-Throws { New-FoodApiServiceConfiguration $invalid 'C:\node.exe' 'C:\logs' }
}
Assert-FoodApiServiceOwner '"C:\ProgramData\SchoolFoodAppApi.exe"' 'c:\programdata\SchoolFoodAppApi.exe'
Assert-Throws { Assert-FoodApiServiceOwner 'C:\other.exe' 'C:\expected.exe' }
Assert-Throws { Assert-FoodApiServiceOwner '"C:\expected.exe" extra' 'C:\expected.exe' }
Assert-Throws { Invoke-FoodApiNative 'cmd.exe' @('/c', 'exit', '7') }

$tokens = $null
$parseErrors = $null
$scriptPath = Join-Path $PSScriptRoot '..\scripts\api_service.ps1'
$null = [System.Management.Automation.Language.Parser]::ParseFile($scriptPath, [ref]$tokens, [ref]$parseErrors)
Assert-True ($parseErrors.Count -eq 0) ($parseErrors | Out-String)
Write-Host 'Windows service configuration and safety checks passed; no service was installed.'
