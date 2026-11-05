#requires -Version 5.1
[CmdletBinding()]
param(
    [ValidateSet('install', 'preview')]
    [string]$Mode = 'install'
)

$ErrorActionPreference = 'Stop'

try {
    $ProjectRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
    if (-not (Test-Path -LiteralPath (Join-Path $ProjectRoot 'project.godot') -PathType Leaf)) {
        throw "FALSE WORLD project.godot not found at $ProjectRoot"
    }

    $Downloads = Join-Path $env:USERPROFILE 'Downloads'
    $KnownGodot = @(
        (Join-Path $Downloads 'Godot_v4.7.2-stable_mono_win64\Godot_v4.7.2-stable_mono_win64\Godot_v4.7.2-stable_mono_win64.exe'),
        (Join-Path $Downloads 'Godot_v4.7.2-stable_mono_win64\Godot_v4.7.2-stable_mono_win64.exe'),
        (Join-Path $Downloads 'Godot_v4.7.2-stable_win64\Godot_v4.7.2-stable_win64.exe')
    )
    $Godot = $null
    foreach ($Path in $KnownGodot) {
        if (Test-Path -LiteralPath $Path -PathType Leaf) {
            $Godot = $Path
            break
        }
    }
    if (-not $Godot -and (Test-Path -LiteralPath $Downloads)) {
        $Candidates = @(Get-ChildItem -LiteralPath $Downloads -Filter '*4.7.2*.exe' -File -Recurse -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -match '^Godot' -and $_.Name -notmatch 'console' })
        if ($Candidates.Count -gt 0) {
            $Godot = $Candidates[0].FullName
        }
    }
    if (-not $Godot) {
        throw "Godot 4.7.2 .exe not found in Downloads. Please place your installed Godot 4.7.2 exe there, or run the existing installer with -Godot YOUR_PATH."
    }

    $Version = ((& $Godot --headless --version) | Out-String).Trim()
    if ($LASTEXITCODE -ne 0 -or $Version -notmatch '^4\.7\.2(\.|$)') {
        throw "Godot is not 4.7.2. Detected: $Version at $Godot"
    }
    Write-Host "Godot: $Godot" -ForegroundColor Cyan
    Write-Host "Project: $ProjectRoot" -ForegroundColor Cyan

    if ($Mode -eq 'preview') {
        Write-Host 'Opening the THREE locally authored preview-only clips (not F5 gameplay)...'
        & $Godot --path $ProjectRoot 'res://scenes/preview/directional_walks.tscn'
        if ($LASTEXITCODE -ne 0) { throw "Preview failed with code $LASTEXITCODE" }
        exit 0
    }

    $SearchRoots = @(
        (Join-Path $env:USERPROFILE 'Downloads'),
        (Join-Path $env:USERPROFILE 'Desktop')
    )
    function Find-SuppliedZip([string]$NamePattern) {
        $Found = @()
        foreach ($Directory in $SearchRoots) {
            if (-not (Test-Path -LiteralPath $Directory -PathType Container)) { continue }
            $Found += @(Get-ChildItem -LiteralPath $Directory -Filter '*.zip' -File -Recurse -ErrorAction SilentlyContinue |
                Where-Object { $_.Name -match $NamePattern })
        }
        if ($Found.Count -eq 0) { return $null }
        $Exact = @($Found | Where-Object { $_.Name -match $NamePattern } | Sort-Object FullName)
        return $Exact[0].FullName
    }

    Write-Host 'Looking for the two previously downloaded animation ZIP archives...'
    $ControllerZip = Find-SuppliedZip '(?i)^real-controller.*\.zip$'
    $MotionsZip = Find-SuppliedZip '(?i)^Human[ _-]*Basic[ _-]*Motions.*FREE.*\.zip$'
    if (-not $ControllerZip -or -not $MotionsZip) {
        Write-Host 'Animation installation has NOT started.' -ForegroundColor Yellow
        if (-not $ControllerZip) {
            Write-Host 'Missing: real-controller-1.3.0.zip'
        }
        if (-not $MotionsZip) {
            Write-Host 'Missing: Human Basic Motions FREE.zip (original Godot/Unreal ZIP)'
        }
        Write-Host 'Save BOTH original ZIP files in your Windows Downloads folder, without extracting or renaming them, then run this command again.'
        Write-Host 'To see the 3 older GitHub preview clips without ZIPs: tools\windows\launch_animation_review.cmd preview'
        exit 2
    }

    Write-Host "Controller ZIP: $ControllerZip"
    Write-Host "Motions ZIP: $MotionsZip"
    Write-Host 'Installing locally licensed animations. The original FALSE-WORLD checkout will not be changed.'
    & (Join-Path $PSScriptRoot 'install_licensed_locomotion.ps1') -Godot $Godot -ControllerZip $ControllerZip -MotionsZip $MotionsZip -ProjectRoot $ProjectRoot
    if ($LASTEXITCODE -ne 0) {
        throw "Licensed animation installer failed. Review its error above."
    }
    Write-Host 'Installation complete. Press F5 in the newly opened FALSE-WORLD-animation-review Godot editor.' -ForegroundColor Green
}
catch {
    Write-Host ("STOPPED: " + $_.Exception.Message) -ForegroundColor Red
    exit 1
}
