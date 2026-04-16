<#
.SYNOPSIS
    Install GitHub Copilot instructions to a target project or globally.

.DESCRIPTION
    Copies Copilot instructions, prompts, rules, agents, and templates to a project's
    .github directory or to a global user-level location (~/.github-copilot).

.PARAMETER TargetPath
    Path to the target project directory. Not required if using -Global.

.PARAMETER Global
    Install globally to ~/.github-copilot (user-level, applies to all projects).

.PARAMETER Modules
    Comma-separated list of modules to install. Default: all available.
    Options: instructions, prompts, rules, templates, agents

.PARAMETER Force
    Overwrite existing files. Default: skip existing.

.PARAMETER DryRun
    Preview what would be installed without copying.

.EXAMPLE
    .\install.ps1 -Global

.EXAMPLE
    .\install.ps1 -TargetPath "C:\projects\myapp"

.EXAMPLE
    .\install.ps1 -TargetPath "C:\projects\myapp" -Force

.EXAMPLE
    .\install.ps1 -TargetPath "C:\projects\myapp" -Modules "instructions,prompts"

.EXAMPLE
    .\install.ps1 -Global -DryRun
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false, Position = 0)]
    [string]$TargetPath = "",

    [Parameter(Mandatory = $false)]
    [switch]$Global,

    [Parameter(Mandatory = $false)]
    [string]$Modules = "",

    [Parameter(Mandatory = $false)]
    [switch]$Force,

    [Parameter(Mandatory = $false)]
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$AllModules = @("instructions", "prompts", "rules", "templates", "agents")

# Global install location
$GlobalDir = if ($env:GITHUB_COPILOT_HOME) { $env:GITHUB_COPILOT_HOME } else { Join-Path $HOME ".github-copilot" }

# Stats
$Script:Copied = 0
$Script:Skipped = 0
$Script:Overwritten = 0

function Write-Status {
    param([string]$Status, [string]$Message, [string]$Color = "White")
    Write-Host "  [$Status] " -ForegroundColor $Color -NoNewline
    Write-Host $Message
}

function Install-File {
    param([string]$Source, [string]$Destination)

    # Skip hidden files
    $BaseName = Split-Path -Leaf $Source
    if ($BaseName.StartsWith(".")) { return }

    $DestDir = Split-Path -Parent $Destination

    if (Test-Path $Destination) {
        if ($Force) {
            if ($DryRun) {
                Write-Status "overwrite" $Destination "Yellow"
            } else {
                if (-not (Test-Path $DestDir)) {
                    New-Item -ItemType Directory -Path $DestDir -Force | Out-Null
                }
                Copy-Item -Path $Source -Destination $Destination -Force
                Write-Status "overwrite" $Destination "Yellow"
            }
            $Script:Overwritten++
        } else {
            Write-Status "skip" "$Destination (exists)" "Cyan"
            $Script:Skipped++
        }
    } else {
        if ($DryRun) {
            Write-Status "copy" $Destination "Green"
        } else {
            if (-not (Test-Path $DestDir)) {
                New-Item -ItemType Directory -Path $DestDir -Force | Out-Null
            }
            Copy-Item -Path $Source -Destination $Destination
            Write-Status "copy" $Destination "Green"
        }
        $Script:Copied++
    }
}

# Determine target path
if ($Global) {
    $TargetPath = $GlobalDir
    if (-not (Test-Path $TargetPath -PathType Container)) {
        if (-not $DryRun) {
            New-Item -ItemType Directory -Path $TargetPath -Force | Out-Null
        }
    }
    $GlobalInstall = $true
} elseif ([string]::IsNullOrWhiteSpace($TargetPath)) {
    Write-Host "Error: Target project path is required (or use -Global for global install)." -ForegroundColor Red
    exit 1
} elseif (-not (Test-Path $TargetPath -PathType Container)) {
    Write-Host "Error: Target path does not exist: $TargetPath" -ForegroundColor Red
    exit 1
} else {
    $TargetPath = (Resolve-Path $TargetPath).Path
    $GlobalInstall = $false
}

# Parse modules
$SelectedModules = @()
if ([string]::IsNullOrWhiteSpace($Modules)) {
    foreach ($mod in $AllModules) {
        $modPath = Join-Path $ScriptDir $mod
        if (Test-Path $modPath -PathType Container) {
            $SelectedModules += $mod
        }
    }
} else {
    $SelectedModules = $Modules -split "," | ForEach-Object { $_.Trim() }
}

# Validate modules
foreach ($mod in $SelectedModules) {
    $modPath = Join-Path $ScriptDir $mod
    if (-not (Test-Path $modPath -PathType Container)) {
        Write-Host "Warning: Module '$mod' not found. Skipping." -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "GitHub Copilot Helper Installer" -ForegroundColor White
if ($GlobalInstall) {
    Write-Host "Mode: " -NoNewline
    Write-Host "Global" -ForegroundColor Green -NoNewline
    Write-Host " (user-level)"
} else {
    Write-Host "Mode: " -NoNewline
    Write-Host "Project" -ForegroundColor Cyan
}
Write-Host "Target: " -NoNewline
Write-Host $TargetPath -ForegroundColor Cyan
if ($DryRun) {
    Write-Host "(dry run - no files will be modified)" -ForegroundColor Yellow
}
Write-Host ""

foreach ($mod in $SelectedModules) {
    $modPath = Join-Path $ScriptDir $mod
    if (-not (Test-Path $modPath -PathType Container)) { continue }

    Write-Host "[$mod]" -ForegroundColor White

    # Determine destination prefix based on install mode
    if ($GlobalInstall) {
        $DestPrefix = $TargetPath
    } else {
        $DestPrefix = Join-Path $TargetPath ".github\copilot"
    }

    switch ($mod) {
        "instructions" {
            if ($GlobalInstall) {
                # Global: copy all instructions to instructions/
                Get-ChildItem -Path $modPath -Filter "*.md" -File | ForEach-Object {
                    $dest = Join-Path $DestPrefix "instructions\$($_.Name)"
                    Install-File -Source $_.FullName -Destination $dest
                }
            } else {
                # Project: Install base instructions to .github/copilot-instructions.md
                $basePath = Join-Path $modPath "base.md"
                if (Test-Path $basePath) {
                    $dest = Join-Path $TargetPath ".github\copilot-instructions.md"
                    Install-File -Source $basePath -Destination $dest
                }
                # Copy other instruction templates
                Get-ChildItem -Path $modPath -Filter "*.md" -File | Where-Object { $_.Name -ne "base.md" } | ForEach-Object {
                    $relName = $_.BaseName
                    $dest = Join-Path $DestPrefix "instructions-$relName.md"
                    Install-File -Source $_.FullName -Destination $dest
                }
            }
        }
        "prompts" {
            Get-ChildItem -Path $modPath -Filter "*.md" -File | ForEach-Object {
                $dest = Join-Path $DestPrefix "prompts\$($_.Name)"
                Install-File -Source $_.FullName -Destination $dest
            }
        }
        "rules" {
            Get-ChildItem -Path $modPath -Filter "*.md" -File | ForEach-Object {
                $dest = Join-Path $DestPrefix "rules\$($_.Name)"
                Install-File -Source $_.FullName -Destination $dest
            }
        }
        "templates" {
            Get-ChildItem -Path $modPath -Filter "*.md" -File | ForEach-Object {
                $dest = Join-Path $DestPrefix "templates\$($_.Name)"
                Install-File -Source $_.FullName -Destination $dest
            }
        }
        "agents" {
            Get-ChildItem -Path $modPath -Filter "*.md" -File | ForEach-Object {
                $dest = Join-Path $DestPrefix "agents\$($_.Name)"
                Install-File -Source $_.FullName -Destination $dest
            }
        }
    }

    Write-Host ""
}

Write-Host "Done. " -NoNewline
Write-Host "$Script:Copied copied" -ForegroundColor Green -NoNewline
Write-Host ", " -NoNewline
Write-Host "$Script:Skipped skipped" -ForegroundColor Cyan -NoNewline
Write-Host ", " -NoNewline
Write-Host "$Script:Overwritten overwritten" -ForegroundColor Yellow
