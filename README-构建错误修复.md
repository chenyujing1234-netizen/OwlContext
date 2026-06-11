# Electron-Builder 构建错误修复指南

## ❌ 错误信息

```
UNKNOWN: unknown error, open 'E:\Source\MineContext-0.1.2\frontend\dist\win-unpacked\OwlContext.exe'
```

## 🔍 错误原因

此错误通常由以下原因引起：

1. **文件被占用**：之前的 OwlContext.exe 进程仍在运行
2. **文件被锁定**：文件被其他程序（如杀毒软件、文件管理器）锁定
3. **权限问题**：没有写入权限
4. **目录锁定**：构建目录被占用

## ✅ 解决方案

### 方法 1：清理构建目录（推荐）

运行清理脚本：
```bash
scripts\clean-build.bat
```

或者手动清理：
```bash
# 关闭所有 OwlContext 进程
taskkill /F /IM OwlContext.exe

# 删除构建目录
cd frontend
rmdir /s /q dist
rmdir /s /q out

# 重新构建
npm run build:win
```

### 方法 2：关闭相关程序

1. **关闭运行中的应用程序**
   - 打开任务管理器（Ctrl+Shift+Esc）
   - 结束所有 `OwlContext.exe` 进程

2. **关闭可能锁定文件的程序**
   - 文件资源管理器（如果打开了 `dist` 目录）
   - 杀毒软件（临时禁用实时保护）
   - VS Code 或其他编辑器（如果打开了相关文件）

3. **以管理员身份运行**
   ```bash
   # 右键点击命令提示符或 PowerShell，选择"以管理员身份运行"
   cd frontend
   npm run build:win
   ```

### 方法 3：修改配置

已在 `electron-builder.yml` 中添加了以下配置以避免文件锁定问题：

```yaml
win:
  verifyUpdateCodeSignature: false
```

## 🔧 已完成的修复

- ✅ 在 `electron-builder.yml` 中禁用更新签名验证
- ✅ 创建了清理脚本 `scripts/clean-build.bat`
- ✅ 优化了构建配置

## 📋 构建步骤

1. **清理旧构建**
   ```bash
   scripts\clean-build.bat
   ```

2. **重新构建**
   ```bash
   cd frontend
   npm run build:win
   ```

3. **验证构建**
   - 检查 `frontend\dist\win-unpacked\OwlContext.exe` 是否存在
   - 尝试运行应用程序

## ⚠️ 预防措施

1. **构建前关闭应用**：确保没有 OwlContext 进程在运行
2. **清理目录**：每次构建前清理 `dist` 目录
3. **使用清理脚本**：使用提供的 `clean-build.bat` 脚本

## 🔍 故障排除

如果问题仍然存在：

1. **检查文件权限**
   ```bash
   icacls "frontend\dist" /grant %USERNAME%:(F)
   ```

2. **检查磁盘空间**
   ```bash
   dir E:\
   ```

3. **检查杀毒软件**
   - 将项目目录添加到杀毒软件白名单
   - 临时禁用实时保护

4. **使用 PowerShell（管理员模式）**
   ```powershell
   Remove-Item -Path "frontend\dist" -Recurse -Force -ErrorAction SilentlyContinue
   cd frontend
   npm run build:win
   ```

