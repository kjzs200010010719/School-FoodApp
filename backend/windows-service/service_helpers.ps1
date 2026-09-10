Set-StrictMode -Version Latest

function New-FoodApiServiceConfiguration {
    param(
        [Parameter(Mandatory = $true)][string]$BackendPath,
        [Parameter(Mandatory = $true)][string]$NodePath,
        [Parameter(Mandatory = $true)][string]$LogPath
    )
    foreach ($path in @($BackendPath, $NodePath, $LogPath)) {
        if ($path -notmatch '^[A-Za-z]:[\\/]' -or
            $path.Contains('"') -or $path.Contains('%') -or $path.Contains("`n") -or $path.Contains("`r")) {
            throw 'Service paths must be absolute and must not contain quotes, percent signs, or newlines.'
        }
    }
    # XML properties escape path characters; never interpolate paths into raw XML.
    [xml]$config = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'SchoolFoodAppApi.template.xml') -Raw
    $config.service.executable = $NodePath
    $config.service.arguments = '"' + (Join-Path $BackendPath 'src\server.js') + '"'
    $config.service.workingdirectory = $BackendPath
    $config.service.logpath = $LogPath
    return $config
}

function Assert-FoodApiServiceOwner {
    param([string]$InstalledPath, [string]$ExpectedPath)
    # WinSW is installed without command arguments. Refuse a namesake service.
    if ($InstalledPath.Trim().Trim('"') -ine $ExpectedPath) {
        throw 'SchoolFoodAppApi belongs to a different installation. No service was changed.'
    }
}

function Invoke-FoodApiNative {
    param([string]$Executable, [string[]]$Arguments)
    & $Executable @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "Command failed with exit code $LASTEXITCODE."
    }
}
