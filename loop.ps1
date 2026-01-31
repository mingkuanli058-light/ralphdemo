# ==============================
# loop.ps1 (Ralph - hardened)
# ==============================

$iteration = 0
$maxIterations = 100

New-Item -ItemType Directory -Force -Path logs | Out-Null

while ($true) {

    Write-Host ""
    Write-Host "================ BUILD LOOP $iteration ================"
    Write-Host ""

    $logFile = "logs/build_round_$iteration.log"

    # 使用工程模式调用（而不是 stdin pipe）
    $output = claude run `
        --prompt-file PROMPT_build.md `
        --output-format text

    $output | Tee-Object $logFile

    # 严格终止条件：单行、完全一致
    if ($output -match "(?m)^\[BUILD_EXIT\]$") {
        Write-Host ""
        Write-Host "BUILD exit signal received."
        Write-Host "BUILD loop finished normally."
        break
    }

    if ($iteration -ge $maxIterations) {
        Write-Host ""
        Write-Host "Max iteration limit reached. Forcing stop."
        break
    }

    $iteration++
}

Write-Host ""
Write-Host "=== LOOP.PS1 DONE ==="