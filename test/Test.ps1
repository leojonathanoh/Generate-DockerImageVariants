$ErrorActionPreference = 'Stop'
$PROJECT_DIR = Split-Path $PSScriptRoot -Parent
Get-Module Generate-DockerImageVariants | Remove-Module -Force
Import-Module ( Join-Path ( Join-Path ( Join-Path $PROJECT_DIR 'src' ) 'Generate-DockerImageVariants' ) 'Generate-DockerImageVariants.psm1' ) -Force 3>$null

# Generate examples
Generate-DockerImageVariants -Version
Generate-DockerImageVariants -ProjectPath ( Join-Path ( Join-Path $PROJECT_DIR 'examples' ) 'my-small-alpine-images' ) -ErrorAction Stop -Verbose
Generate-DockerImageVariants -ProjectPath ( Join-Path ( Join-Path $PROJECT_DIR 'examples' ) 'my-large-alpine-images' ) -ErrorAction Stop -Verbose
