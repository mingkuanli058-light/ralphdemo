# ==============================
# loop_build.ps1
# 自动执行 BUILD 循环
# 依赖 PROMPT_build.md 输出 [BUILD_EXIT] 作为终止信号
# ==============================
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$iteration = 0

while ($true) {

    Write-Host ""
    Write-Host "================ BUILD LOOP $iteration ================"
    Write-Host ""

    # 执行一次 BUILD，并保存输出
    Get-Content PROMPT_build.md -Raw |
        claude -p --dangerously-skip-permissions |
        Tee-Object build.log

    # 读取 Claude 本轮输出
    $log = Get-Content build.log -Raw

    # === 终止条件：Claude 明确声明 BUILD 结束 ===
    if ($log -match "\[BUILD_EXIT\]") {
        Write-Host ""
        Write-Host "BUILD exit signal received."
        Write-Host "BUILD loop finished normally."
        break
    }

    # === 防御性终止：避免 Claude 异常失控 ===
    if ($iteration -ge 100) {
        Write-Host ""
        Write-Host "Max iteration limit reached. Forcing stop."
        break
    }

    $iteration++
}

Write-Host ""
Write-Host "=== LOOP_build.PS1 DONE ==="