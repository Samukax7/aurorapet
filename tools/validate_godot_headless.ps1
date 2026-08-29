param(
    [string]$GodotPath = "godot",
    [int]$TimeoutSeconds = 30
)

$ErrorActionPreference = "Stop"
$projectRoot = Split-Path -Parent $PSScriptRoot

if ($GodotPath -eq "godot") {
    $command = Get-Command godot -ErrorAction SilentlyContinue
    if ($null -eq $command) {
        Write-Error "Godot não foi encontrado no PATH. Execute novamente com -GodotPath 'C:\\caminho\\Godot.exe'."
    }
    $GodotPath = $command.Source
}

if (-not (Test-Path -LiteralPath $GodotPath -PathType Leaf) -and $GodotPath -ne "godot") {
    Write-Error "Executável da Godot não encontrado: $GodotPath"
}

$outputFile = Join-Path ([System.IO.Path]::GetTempPath()) ("aurorapet-godot-headless-{0}.log" -f (Get-Date -Format "yyyyMMddHHmmss"))
$arguments = @(
    "--headless",
    "--path", $projectRoot,
    "--editor",
    "--quit",
    "--quit-after", $TimeoutSeconds
)

Write-Host "Projeto: $projectRoot"
Write-Host "Godot:   $GodotPath"
Write-Host "Teste:   --headless --editor --quit"

& $GodotPath @arguments 2>&1 | Tee-Object -FilePath $outputFile
$exitCode = $LASTEXITCODE
$log = Get-Content -Raw -LiteralPath $outputFile

$errorPatterns = @(
    "SCRIPT ERROR",
    "Parse Error",
    "Failed to load",
    "Cannot load",
    "ERROR:"
)
$detected = foreach ($pattern in $errorPatterns) {
    if ($log -match [regex]::Escape($pattern)) { $pattern }
}

Remove-Item -LiteralPath $outputFile -Force -ErrorAction SilentlyContinue

if ($exitCode -ne 0) {
    Write-Error "Godot terminou com código $exitCode."
}
if ($detected.Count -gt 0) {
    Write-Error ("Padrões de erro detectados: " + (($detected | Select-Object -Unique) -join ", "))
}

Write-Host "HEADLESS_OK: projeto carregado sem erros críticos detectados."
