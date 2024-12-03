# 定义用于存储原始npm仓库地址的变量  
$originalRegistry = ""  
  
# 获取当前的npm仓库地址  
$originalRegistry = npm get registry  
  
# 输出原始仓库地址（可选，用于调试）  
Write-Host "Original npm registry: $originalRegistry"  
  
# 切换到npm官方仓库  
npm config set registry https://registry.npmjs.org/  
  
# 验证是否成功切换到官方仓库（可选）  
$currentRegistry = npm get registry  
Write-Host "Current npm registry (after change): $currentRegistry"  
  
# 尝试发布npm包  
# 注意：这里假设你已经在当前目录下准备好了npm包（包含package.json等）  
npm publish  
  
# 检查上一个命令是否成功执行  
if ($LASTEXITCODE -ne 0) {  
    # 如果npm publish失败，则回滚到原始仓库地址  
    npm config set registry $originalRegistry  
    Write-Host "npm publish failed. Registry reverted to $originalRegistry"  
    exit $LASTEXITCODE  
}  
  
# 发布成功后，回滚到原始仓库地址  
npm config set registry $originalRegistry  
Write-Host "npm publish succeeded. Registry reverted to $originalRegistry"