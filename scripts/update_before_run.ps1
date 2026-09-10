$ErrorActionPreference = "Stop"

$projectRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
Set-Location $projectRoot

Write-Host "Checking Git status before launching Flutter..."

$dirtyChanges = git status --porcelain --untracked-files=all |
  Where-Object { $_ -notmatch "\.vscode/settings\.json$" }

if ($dirtyChanges) {
  Write-Host ""
  Write-Host "There are uncommitted project changes. Commit or stash them before auto-updating:"
  $dirtyChanges | ForEach-Object { Write-Host "  $_" }
  Write-Host ""
  Write-Host "Auto-update stopped to avoid overwriting your work."
  exit 1
}

Write-Host "Fetching latest main from GitHub..."
git fetch origin main

$localCommit = git rev-parse HEAD
$remoteCommit = git rev-parse origin/main
$mergeBase = git merge-base HEAD origin/main

if ($localCommit -eq $remoteCommit) {
  Write-Host "Project is already up to date."
} elseif ($localCommit -eq $mergeBase) {
  Write-Host "Updating project to latest origin/main..."
  git pull --ff-only origin main
} elseif ($remoteCommit -eq $mergeBase) {
  Write-Host "Local branch is ahead of origin/main. Skipping pull."
} else {
  Write-Host ""
  Write-Host "Local and remote branches have diverged. Please resolve Git manually."
  exit 1
}

Write-Host "Updating Flutter packages..."
flutter pub get

Write-Host "Ready to launch Flutter app."
