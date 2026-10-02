$ErrorActionPreference = 'Stop'

Push-Location -LiteralPath $PSScriptRoot
try {
    uv run --no-project --python 3.13 build.py
    exit $LASTEXITCODE
} finally {
    Pop-Location
}
