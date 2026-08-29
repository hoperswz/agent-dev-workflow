param(
    [ValidateSet("zh", "en")]
    [string]$Lang = "zh"
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

$version = "v1.0.1"
$baseUrl = "https://raw.githubusercontent.com/hoperswz/agent-dev-workflow/$version"

Write-Host "Agent Dev Workflow $version"
Write-Host ""

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw "Git is required but was not found."
}

$gitRoot = $null
$gitExitCode = 1

try {
    $gitOutput = & git rev-parse --show-toplevel 2>$null
    $gitExitCode = $LASTEXITCODE
    $gitRoot = $gitOutput | Select-Object -First 1
} catch {
    $gitExitCode = 1
}

if ($gitExitCode -ne 0 -or [string]::IsNullOrWhiteSpace($gitRoot)) {
    throw "Current directory is not inside a Git repository."
}

$trimCharacters = [char[]]@([IO.Path]::DirectorySeparatorChar, [IO.Path]::AltDirectorySeparatorChar)
$currentDirectory = [IO.Path]::GetFullPath((Get-Location).ProviderPath).TrimEnd($trimCharacters)
$repositoryRoot = [IO.Path]::GetFullPath($gitRoot.Trim()).TrimEnd($trimCharacters)

if (-not [StringComparer]::OrdinalIgnoreCase.Equals($currentDirectory, $repositoryRoot)) {
    throw "Run this command from the root of your Git repository."
}

$target = Join-Path $currentDirectory "AGENTS.md"

if (Test-Path -LiteralPath $target) {
    throw "AGENTS.md already exists. Existing file was not modified."
}

$source = if ($Lang -eq "en") {
    "AGENTS.en.md"
} else {
    "AGENTS.md"
}

$url = "$baseUrl/$source"
$temporaryFile = Join-Path $currentDirectory ".AGENTS.md.$([guid]::NewGuid().ToString('N')).tmp"

Write-Host "Installing $source as AGENTS.md..."

try {
    Invoke-WebRequest -UseBasicParsing -Uri $url -OutFile $temporaryFile

    if (-not (Test-Path -LiteralPath $temporaryFile) -or (Get-Item -LiteralPath $temporaryFile).Length -eq 0) {
        throw "Downloaded file is empty."
    }

    [IO.File]::Move($temporaryFile, $target)
    $temporaryFile = $null
} catch {
    throw "Installation failed. No target file was created. $($_.Exception.Message)"
} finally {
    if ($null -ne $temporaryFile -and (Test-Path -LiteralPath $temporaryFile)) {
        Remove-Item -LiteralPath $temporaryFile -Force
    }
}

Write-Host ""
Write-Host "✓ AGENTS.md installed successfully."
Write-Host "  Version: $version"
Write-Host "  Language: $Lang"
Write-Host "  Path: $target"
