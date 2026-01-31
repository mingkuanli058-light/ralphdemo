# ==============================
# loop_plan.ps1
# 自动执行 PLANNING 循环
# 依赖 PROMPT_plan.md 输出 [PLAN_EXIT] 作为终止信号
# ==============================

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$iteration = 0

while ($true) {

    Write-Host ""
    Write-Host "================ PLAN LOOP $iteration ================"
    Write-Host ""

    Get-Content PROMPT_plan.md -Raw |
        claude -p --dangerously-skip-permissions |
        Tee-Object plan.log

    $log = Get-Content plan.log -Raw

    if ($log -match "\[PLAN_EXIT\]") {
        Write-Host ""
        Write-Host "PLAN exit signal received."
        Write-Host "PLANNING loop finished normally."
        break
    }

    $iteration++

    if ($iteration -gt 10) {
        Write-Host "PLAN loop exceeded safety limit (10 iterations)."
        break
    }
}