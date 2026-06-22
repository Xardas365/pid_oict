$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$envFile = Join-Path $root ".env.local"

if (-not (Test-Path $envFile)) {
  Write-Error "Missing .env.local. Copy .env.example to .env.local and set GOLEMIO_API_TOKEN."
}

$line = Get-Content $envFile | Where-Object { $_ -match '^GOLEMIO_API_TOKEN=' } | Select-Object -First 1

if (-not $line) {
  Write-Error "GOLEMIO_API_TOKEN is missing in .env.local."
}

$token = $line -replace '^GOLEMIO_API_TOKEN=', ''

if ([string]::IsNullOrWhiteSpace($token) -or $token -eq "your_token_here") {
  Write-Error "GOLEMIO_API_TOKEN in .env.local is not set."
}

flutter run --dart-define="GOLEMIO_API_TOKEN=$token"
