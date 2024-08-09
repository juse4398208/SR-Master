# install-hooks.ps1

# 检查是否在 Git 仓库根目录下
function Get-GitRoot {
    $currentDir = Get-Location
    while ($currentDir -ne $null) {
        if (Test-Path "$currentDir\.git") {
            return $currentDir
        }
        $currentDir = $currentDir.Parent
    }
    return $null
}

# 尝试获取 Git 根目录
$gitRoot = Get-GitRoot

# 如果在 Git 仓库内运行，$gitRoot 会被设置
if ($gitRoot -ne $null) {
    Set-Location -Path $gitRoot
    $targetDir = "$gitRoot/.git/hooks"
	$sourceDir = "$gitRoot/tool/hooks"

} else {
    # 如果不在 Git 仓库中运行，则提示用户输入 Git 仓库目录
	
    $targetDir = "../.git/hooks"
	$sourceDir = "../tool/hooks"

    if (-not (Test-Path "$targetDir")) {
        throw "The specified path does not contain a Git repository."
    }

}

# 安装 hooks 脚本的逻辑
Write-Output "Installing hooks in: $targetDir"

if (Test-Path $sourceDir) {
    Write-Output "Installing hooks from: $sourceDir"

    # 复制 hooks 文件，使用 -Force 参数覆盖现有文件
    Copy-Item -Path "$sourceDir\*" -Destination $targetDir -Recurse -Force

    # 确保 hooks 可执行
    Get-ChildItem -Path $targetDir -File | ForEach-Object {
        & icacls $_.FullName /grant Everyone:F | Out-Null
        Write-Output "Set executable permission: $($_.Name)"
    }
} else {
    Write-Output "No hooks to install from $sourceDir"
}

Write-Output "Hooks installed successfully."
