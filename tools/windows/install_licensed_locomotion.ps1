#requires -Version 5.1
# Local Windows wrapper for the existing Godot installer. Does not run Git.
[CmdletBinding()]
param(
    [string]$Godot,
    [string]$ControllerZip,
    [string]$MotionsZip,
    [string]$ProjectRoot,
    [switch]$NoEditor
)

$ErrorActionPreference = 'Stop'

function Select-LocalFile([string]$Title, [string]$Filter) {
    Add-Type -AssemblyName System.Windows.Forms
    $Dialog = New-Object System.Windows.Forms.OpenFileDialog
    $Dialog.Title = $Title
    $Dialog.Filter = $Filter
    $Dialog.CheckFileExists = $true
    $Dialog.Multiselect = $false
    try {
        if ($Dialog.ShowDialog() -ne [System.Windows.Forms.DialogResult]::OK) {
            throw 'File selection cancelled. Installation stopped.'
        }
        return $Dialog.FileName
    }
    finally { $Dialog.Dispose() }
}

function Get-NativeArguments([string[]]$Items) {
    # All arguments here are switches or file paths, without embedded quotes or
    # trailing backslashes. Quote each for Windows PowerShell 5.1 Start-Process.
    return (($Items | ForEach-Object {
        if ($_.Contains('"') -or $_.EndsWith('\')) { throw 'Unsupported argument path.' }
        '"' + $_ + '"'
    }) -join ' ')
}

function Invoke-Godot([string[]]$Items) {
    $Process = Start-Process -FilePath $Godot -WorkingDirectory $ProjectRoot `
        -ArgumentList (Get-NativeArguments $Items) -Wait -PassThru -NoNewWindow
    if ($Process.ExitCode -ne 0) { throw "Godot failed, exit $($Process.ExitCode)." }
}

try {
    if (-not $ProjectRoot) {
        $CandidateRoot = Join-Path $PSScriptRoot '..\..'
        if (Test-Path -LiteralPath (Join-Path $CandidateRoot 'tools\visual\install_licensed_walks.gd')) {
            $ProjectRoot = $CandidateRoot
        }
        else { $ProjectRoot = (Get-Location).Path }
    }
    $ProjectRoot = (Resolve-Path -LiteralPath $ProjectRoot).Path
    foreach ($Required in @('project.godot', 'tools\visual\install_licensed_walks.gd')) {
        if (-not (Test-Path -LiteralPath (Join-Path $ProjectRoot $Required) -PathType Leaf)) {
            throw "This folder does not contain the locomotion integration: $ProjectRoot"
        }
    }
    if (-not $Godot) { $Godot = Select-LocalFile 'Choose your Godot 4.7.2 executable' 'Godot executable (*.exe)|*.exe' }
    if (-not $ControllerZip) { $ControllerZip = Select-LocalFile 'Choose real-controller-1.3.0.zip' 'ZIP archive (*.zip)|*.zip' }
    if (-not $MotionsZip) { $MotionsZip = Select-LocalFile 'Choose Human Basic Motions FREE.zip (not Unity)' 'ZIP archive (*.zip)|*.zip' }
    foreach ($Path in @($Godot, $ControllerZip, $MotionsZip)) {
        if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { throw "File not found: $Path" }
    }

    $VersionInfo = New-Object System.Diagnostics.ProcessStartInfo
    $VersionInfo.FileName = $Godot
    $VersionInfo.Arguments = '--headless --version'
    $VersionInfo.UseShellExecute = $false
    $VersionInfo.RedirectStandardOutput = $true
    $VersionProcess = [System.Diagnostics.Process]::Start($VersionInfo)
    try {
        $Version = $VersionProcess.StandardOutput.ReadToEnd().Trim()
        $VersionProcess.WaitForExit()
        if ($VersionProcess.ExitCode -ne 0 -or $Version -notmatch '(?m)^4\.7\.2(?:\.|\s|$)') {
            throw "This project requires Godot 4.7.2; selected executable reports: $Version"
        }
    }
    finally { $VersionProcess.Dispose() }

    Write-Host 'Importing this review checkout with Godot 4.7.2...'
    Invoke-Godot @('--headless', '--path', $ProjectRoot, '--editor', '--import')
    Write-Host 'Generating the licensed worker animations from your two local ZIPs...'
    Invoke-Godot @('--headless', '--path', $ProjectRoot, '--script', 'res://tools/visual/install_licensed_walks.gd', '--', "--controller-zip=$ControllerZip", "--motions-zip=$MotionsZip")

    $OutputDirectory = Join-Path $ProjectRoot 'assets\visual\licensed_locomotion'
    if (-not (Test-Path -LiteralPath (Join-Path $OutputDirectory 'manifest.json'))) {
        throw 'Installation did not produce its manifest. Stop and inspect the Godot output.'
    }
    foreach ($Prefix in @('walk_', 'run_')) {
        foreach ($Direction in @('forward', 'backward', 'left', 'right', 'forward_left', 'forward_right', 'backward_left', 'backward_right')) {
            if (-not (Test-Path -LiteralPath (Join-Path $OutputDirectory ($Prefix + $Direction + '.tres')))) {
                throw "Installation is incomplete: $Prefix$Direction"
            }
        }
    }
    Write-Host "Installed 16 animations in: $ProjectRoot"
    Write-Host 'Press F5 in the editor opened for THIS folder. Test W/S/A/D and diagonals.'
    if (-not $NoEditor) {
        Start-Process -FilePath $Godot -WorkingDirectory $ProjectRoot `
            -ArgumentList (Get-NativeArguments @('--editor', '--path', $ProjectRoot)) | Out-Null
    }
}
catch {
    Write-Host ("Installation stopped: " + $_.Exception.Message) -ForegroundColor Red
    exit 1
}
