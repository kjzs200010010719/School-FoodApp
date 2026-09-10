[CmdletBinding()]
param(
    [ValidateSet('Check', 'Install', 'Start', 'Stop', 'Restart', 'Status', 'Uninstall')]
    [string]$Action = 'Check'
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
. (Join-Path $PSScriptRoot '..\windows-service\service_helpers.ps1')

$serviceId = 'SchoolFoodAppApi'
$backendPath = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$servicePath = Join-Path $env:ProgramData $serviceId
$wrapperPath = Join-Path $servicePath "$serviceId.exe"
$configPath = Join-Path $servicePath "$serviceId.xml"
$logPath = Join-Path $servicePath 'logs'
$wrapperUrl = 'https://github.com/winsw/winsw/releases/download/v2.12.0/WinSW.NET461.exe'
$wrapperHash = 'B5066B7BBDFBA1293E5D15CDA3CAAEA88FBEAB35BD5B38C41C913D492AADFC4F'
$installed = Get-CimInstance Win32_Service -Filter "Name='$serviceId'"
if ($installed) {
    Assert-FoodApiServiceOwner -InstalledPath $installed.PathName -ExpectedPath $wrapperPath
    if (-not (Test-Path -LiteralPath $configPath)) { throw 'Installed service configuration is missing.' }
    [xml]$existingConfig = Get-Content -LiteralPath $configPath -Raw
    if ($existingConfig.service.workingdirectory -ine $backendPath) {
        throw 'The installed service belongs to a different backend checkout.'
    }
}

function Show-FoodApiStatus {
    $current = Get-CimInstance Win32_Service -Filter "Name='$serviceId'"
    if (-not $current) { Write-Host 'SchoolFoodAppApi is not installed.'; return }
    $current | Select-Object Name, State, StartMode, StartName, ProcessId
    Get-NetTCPConnection -State Listen -LocalPort 3000 -ErrorAction SilentlyContinue |
        Select-Object LocalAddress, LocalPort, OwningProcess
    Write-Host "Logs: $logPath"
}

function Wait-FoodApiHealthy {
    $deadline = [DateTime]::UtcNow.AddSeconds(40)
    do {
        try {
            $current = Get-CimInstance Win32_Service -Filter "Name='$serviceId'"
            $response = Invoke-RestMethod -Uri 'http://127.0.0.1:3000/api/health' -TimeoutSec 2
            $listeners = @(Get-NetTCPConnection -State Listen -LocalPort 3000 -ErrorAction Stop)
            if ($current -and $current.State -eq 'Running' -and $response.status -eq 'ok') {
                foreach ($listener in $listeners) {
                    $worker = Get-CimInstance Win32_Process -Filter "ProcessId=$($listener.OwningProcess)"
                    if ($listener.LocalAddress -eq '127.0.0.1' -and
                        $worker.ParentProcessId -eq $current.ProcessId) {
                        Write-Host 'API is healthy and its process belongs to SchoolFoodAppApi.'
                        return
                    }
                }
            }
        } catch {
            # Windows may report Running before Node finishes its database check.
        }
        Start-Sleep -Seconds 1
    } while ([DateTime]::UtcNow -lt $deadline)
    throw "Service health check failed. Review logs in $logPath."
}

if ($Action -eq 'Status') {
    Show-FoodApiStatus
    if ($installed -and $installed.State -eq 'Running') { Wait-FoodApiHealthy }
    return
}

if ($Action -in @('Check', 'Install')) {
    $nodePath = (Get-Command node.exe -ErrorAction Stop).Source
    foreach ($relativePath in @('.env', 'node_modules\express', 'node_modules\mysql2', 'src\server.js')) {
        if (-not (Test-Path -LiteralPath (Join-Path $backendPath $relativePath))) {
            throw "Missing backend/$relativePath. Configure .env and run npm.cmd ci first."
        }
    }
    $databaseService = Get-Service -Name 'MySQLFoodApp' -ErrorAction Stop
    if ($databaseService.Status -ne 'Running') { throw 'Start MySQLFoodApp before continuing.' }
    $framework = Get-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full'
    if ($framework.Release -lt 394254) { throw '.NET Framework 4.6.1 or newer is required.' }

    # Match the service's environment without changing .env or persistent settings.
    $previous = @{}
    $settings = @{ HOST = '127.0.0.1'; PORT = '3000'; API_ALLOWED_IPS = '127.0.0.1,::1'; NODE_ENV = 'production' }
    Push-Location $backendPath
    try {
        foreach ($key in $settings.Keys) {
            $previous[$key] = [Environment]::GetEnvironmentVariable($key, 'Process')
            [Environment]::SetEnvironmentVariable($key, $settings[$key], 'Process')
        }
        Invoke-FoodApiNative -Executable $nodePath -Arguments @('scripts/check_database.js')
    } finally {
        foreach ($key in $previous.Keys) {
            [Environment]::SetEnvironmentVariable($key, $previous[$key], 'Process')
        }
        Pop-Location
    }
    $config = New-FoodApiServiceConfiguration -BackendPath $backendPath -NodePath $nodePath -LogPath $logPath
    Write-Host "Backend: $backendPath"
    Write-Host "Node: $nodePath"
    Write-Host 'API binding: 127.0.0.1:3000 (local server access only)'
    $listeners = @(Get-NetTCPConnection -State Listen -LocalPort 3000 -ErrorAction SilentlyContinue)
    if ($Action -eq 'Check') {
        if ($listeners.Count -gt 0 -and -not $installed) {
            Write-Host 'Port 3000 is in use. Stop your manual npm start with Ctrl+C before Install.'
        }
        Show-FoodApiStatus
        Write-Host 'Preflight passed. No service, firewall, file permission, or configuration was changed.'
        return
    }
    if ($installed) { throw 'Service is already installed. Use Status, Restart, or Uninstall.' }
    if ($listeners.Count -gt 0) { throw 'Port 3000 is in use. Stop the manual API with Ctrl+C first.' }
}

$principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw 'Run PowerShell as administrator inside the school server remote desktop.'
}
if ((Get-CimInstance Win32_OperatingSystem).ProductType -eq 1) {
    throw 'This installer is for the school Windows Server, not a personal Windows workstation.'
}

if ($Action -eq 'Install') {
    New-Item -ItemType Directory -Path $servicePath -Force | Out-Null
    # Only administrators and SYSTEM can modify the service executable/configuration.
    $acl = New-Object System.Security.AccessControl.DirectorySecurity
    $acl.SetAccessRuleProtection($true, $false)
    foreach ($sid in @('S-1-5-18', 'S-1-5-32-544')) {
        $identity = New-Object System.Security.Principal.SecurityIdentifier($sid)
        $acl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule(
            $identity, 'FullControl', 'ContainerInherit,ObjectInherit', 'None', 'Allow')))
    }
    $localService = New-Object System.Security.Principal.SecurityIdentifier('S-1-5-19')
    $acl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule(
        $localService, 'ReadAndExecute', 'ContainerInherit,ObjectInherit', 'None', 'Allow')))
    Set-Acl -LiteralPath $servicePath -AclObject $acl
    New-Item -ItemType Directory -Path $logPath -Force | Out-Null

    if (-not (Test-Path -LiteralPath $wrapperPath)) {
        $downloadPath = Join-Path $servicePath 'WinSW.download'
        $oldProtocol = [Net.ServicePointManager]::SecurityProtocol
        try {
            [Net.ServicePointManager]::SecurityProtocol = $oldProtocol -bor [Net.SecurityProtocolType]::Tls12
            Invoke-WebRequest -UseBasicParsing -Uri $wrapperUrl -OutFile $downloadPath
            if ((Get-FileHash -LiteralPath $downloadPath -Algorithm SHA256).Hash -ne $wrapperHash) {
                throw 'WinSW download checksum mismatch. The downloaded file will not be executed.'
            }
            Move-Item -LiteralPath $downloadPath -Destination $wrapperPath
        } finally { [Net.ServicePointManager]::SecurityProtocol = $oldProtocol }
    }
    if ((Get-FileHash -LiteralPath $wrapperPath -Algorithm SHA256).Hash -ne $wrapperHash) {
        throw 'Existing WinSW checksum mismatch. No service was installed.'
    }
    $config.Save($configPath)
    Invoke-FoodApiNative -Executable 'icacls.exe' -Arguments @($backendPath, '/grant', '*S-1-5-19:(OI)(CI)RX')
    Invoke-FoodApiNative -Executable 'icacls.exe' -Arguments @($logPath, '/grant', '*S-1-5-19:(OI)(CI)M')
    Invoke-FoodApiNative -Executable $wrapperPath -Arguments @('install')
    try {
        Start-Service -Name $serviceId
        Wait-FoodApiHealthy
    } catch {
        Stop-Service -Name $serviceId -ErrorAction SilentlyContinue
        throw
    }
    Show-FoodApiStatus
    return
}

if (-not $installed) { throw 'SchoolFoodAppApi is not installed.' }
switch ($Action) {
    'Start' { Start-Service -Name $serviceId; Wait-FoodApiHealthy }
    'Stop' { Stop-Service -Name $serviceId }
    'Restart' { Restart-Service -Name $serviceId; Wait-FoodApiHealthy }
    'Uninstall' {
        if ($installed.State -ne 'Stopped') { Stop-Service -Name $serviceId }
        if ((Get-FileHash -LiteralPath $wrapperPath -Algorithm SHA256).Hash -ne $wrapperHash) {
            throw 'WinSW checksum mismatch. Uninstall was not executed.'
        }
        Invoke-FoodApiNative -Executable $wrapperPath -Arguments @('uninstall')
        Write-Host 'Service removed. Logs, .env, backend files and MySQL were retained.'
    }
}
Show-FoodApiStatus
