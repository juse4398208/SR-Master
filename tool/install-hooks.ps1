# install-hooks.ps1
# PowerShell 脚本用于将 hooks 安装到 .git/hooks/ 目录

# 确保脚本在项目根目录执行
$parentDir = "../"
$gitDir = ".git"
if (-not (Test-Path $parentDir$gitDir)) {
    Write-Host "Error: This script must be run from the root of a Git repository."
    exit 1
}

# 定义 hooks 源目录和目标目录
$sourceDir = "hooks"
$targetDir = "$parentDir.git/hooks"

# 检查 hooks 目录是否存在
if (-not (Test-Path $sourceDir)) {
    Write-Host "Error: Hooks source directory 'hooks' does not exist."
    exit 1
}

# 创建目标目录（如果不存在）
if (-not (Test-Path $targetDir)) {
    New-Item -ItemType Directory -Path $targetDir | Out-Null
}

# 复制 hooks 脚本到 .git/hooks/ 目录
Get-ChildItem -Path $sourceDir -File | ForEach-Object {
    $destination = Join-Path $targetDir $_.Name
    Copy-Item -Path $_.FullName -Destination $destination -Force
    Write-Host "Installed hook: $($_.Name)"
}

# 设置所有 hooks 脚本为可执行
Get-ChildItem -Path $targetDir -File | ForEach-Object {
    $file = $_.FullName
    & icacls $file /grant Everyone:F | Out-Null
    Write-Host "Set executable permission: $($_.Name)"
}


Write-Host "All hooks installed successfully."