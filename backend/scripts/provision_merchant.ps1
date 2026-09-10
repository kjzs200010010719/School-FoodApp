$ErrorActionPreference = 'Stop'
$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($identity)
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw 'Run as administrator on the school server. This creates an active merchant and store.'
}
$data = @{
    businessName = (Read-Host 'Approved business name')
    email = (Read-Host 'Merchant email')
    storeName = (Read-Host 'Store name')
    address = (Read-Host 'Store address')
    businessHours = (Read-Host 'Business hours (display text)')
    contactPhone = (Read-Host 'Contact phone')
    businessWeekdays = @((Read-Host 'Weekdays, comma separated (Mon=1, Sun=7)').Split(',') | ForEach-Object { [int]$_.Trim() })
}
if ((Read-Host 'Create this APPROVED merchant and store? Type CREATE') -cne 'CREATE') { return }
$secret = Read-Host 'Merchant password (12-128 characters)' -AsSecureString
$confirm = Read-Host 'Confirm merchant password' -AsSecureString
$first = [IntPtr]::Zero
$second = [IntPtr]::Zero
$previousEncoding = $OutputEncoding
Push-Location (Split-Path $PSScriptRoot -Parent)
try {
    $first = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secret)
    $second = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($confirm)
    $data.password = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($first)
    if ($data.password -cne [Runtime.InteropServices.Marshal]::PtrToStringBSTR($second)) { throw 'Passwords do not match.' }
    $OutputEncoding = New-Object System.Text.UTF8Encoding($false)
    $data | ConvertTo-Json -Depth 4 -Compress | & node (Join-Path $PSScriptRoot 'provision_merchant.js')
    if ($LASTEXITCODE -ne 0) { throw 'Provisioning failed; no success confirmed. Review the error before retrying.' }
} finally {
    $data.Remove('password')
    if ($first -ne [IntPtr]::Zero) { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($first) }
    if ($second -ne [IntPtr]::Zero) { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($second) }
    $secret.Dispose()
    $confirm.Dispose()
    $OutputEncoding = $previousEncoding
    Pop-Location
}
