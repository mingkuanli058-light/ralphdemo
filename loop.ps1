# ==========================================
# Ralph Playbook 循环执行器（Windows 版）
#
# 设计原则：
# - 每一轮都是“冷启动”
# - LLM 不保留任何跨轮上下文
# - 所有执行状态仅存在于磁盘文件中
# - Loop 本身不做决策，只负责反复调用
# ==========================================

param (
    # 执行模式：
    # plan  - 使用 PROMPT_plan.md（规划模式）
    # build - 使用 PROMPT_build.md（构建模式，默认）
    [ValidateSet("plan", "build")]
    [string]$Mode = "build"
)

Write-Host "==========================================" 
Write-Host "Ralph 循环启动，当前模式：[$Mode]"
Write-Host "状态来源：IMPLEMENTATION_PLAN.md（磁盘）"
Write-Host "=========================================="

while ($true) {

    Write-Host ""
    Write-Host "------------------------------------------"
    Write-Host "开始新一轮执行：$(Get-Date)"
    Write-Host "------------------------------------------"

    if ($Mode -eq "plan") {
        Write-Host "进入【规划模式 PLAN】"
        Write-Host "职责：生成 / 重建 IMPLEMENTATION_PLAN.md"
        Get-Content PROMPT_plan.md | claude
    }
    else {
        Write-Host "进入【构建模式 BUILD】"
        Write-Host "职责：执行一个任务 → 测试 → 提交"
        Get-Content PROMPT_build.md | claude
    }

    Write-Host ""
    Write-Host "本轮执行结束。"
    Write-Host "如需停止，请按 Ctrl + C"
    Write-Host "准备进入下一轮冷启动执行..."

    # 可选：短暂休眠，防止过快循环
    Start-Sleep -Seconds 2
}
