const test = require('node:test');
const assert = require('node:assert/strict');
const path = require('node:path');
const { spawnSync } = require('node:child_process');

test('Windows service configuration, ownership guards and PowerShell syntax', {
  skip: process.platform !== 'win32',
}, () => {
  const result = spawnSync('powershell.exe', [
    '-NoProfile', '-NonInteractive', '-ExecutionPolicy', 'Bypass',
    '-File', path.join(__dirname, 'windows_service_checks.ps1'),
  ], { encoding: 'utf8', timeout: 30000, windowsHide: true });
  assert.ifError(result.error);
  assert.equal(result.status, 0, result.stdout + result.stderr);
  assert.match(result.stdout, /safety checks passed/);
});
