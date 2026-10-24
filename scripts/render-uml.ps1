# Renders every docs/uml/*.puml file to PNG in docs/uml/img, using the PlantUML Docker image.
# Usage (from any folder): .\scripts\render-uml.ps1
# Needs Docker Desktop running. The first run downloads the plantuml/plantuml image.

$ErrorActionPreference = 'Stop'

docker info *> $null
if ($LASTEXITCODE -ne 0) {
    Write-Error 'Docker is not running. Start Docker Desktop, then run this script again.'
    exit 1
}

# Run from the repository root so that the paths below are always the same.
Push-Location (Join-Path $PSScriptRoot '..')
try {
    docker run --rm -v "${PWD}:/data" plantuml/plantuml -tpng -charset UTF-8 -o img "docs/uml/*.puml"
    if ($LASTEXITCODE -ne 0) {
        Write-Error 'PlantUML reported an error (see the messages above).'
        exit 1
    }
    Get-ChildItem docs/uml/img/*.png | ForEach-Object { Write-Host "Rendered $($_.Name)" }
}
finally {
    Pop-Location
}
