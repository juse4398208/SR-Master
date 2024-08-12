# install-hooks.ps1

# 檢查是否在 Git 倉庫根目錄下
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

# 嘗試獲取 Git 根目錄
$gitRoot = Get-GitRoot

# 如果在 Git 倉庫內運行，$gitRoot 會被設置
if ($gitRoot -ne $null) {
    Set-Location -Path $gitRoot
    $targetDir = "$gitRoot/.git/hooks"
	$sourceDir = "$gitRoot/tool/hooks"

} else {
    # 如果不在 Git 倉庫中運行，則提示用戶輸入 Git 倉庫目錄
	
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

    # 清理目標目錄
    Remove-Item -Path "$targetDir\*" -Recurse -Force -ErrorAction SilentlyContinue

    # 複製 hooks 文件，使用 -Force 參數覆蓋現有文件
    Copy-Item -Path "$sourceDir\*" -Destination $targetDir -Recurse -Force

    # 確保 hooks 可執行
    Get-ChildItem -Path $targetDir -File | ForEach-Object {
        & icacls $_.FullName /grant Everyone:F | Out-Null
        Write-Output "Set executable permission: $($_.Name)"
    }
} else {
    Write-Output "No hooks to install from $sourceDir"
}

Write-Output "Hooks installed successfully."
