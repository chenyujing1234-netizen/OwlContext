# MineContext 安装程序构建说明

## 概述

本项目使用 Inno Setup 创建 Windows 安装程序，支持开机自动启动功能。

## 前置要求

1. **Inno Setup 6** - 安装路径: `E:\Program Files (x86)\Inno Setup 6`
2. **已构建的前端应用** - 需要先运行前端构建流程

## 构建流程

### 步骤 1: 构建前端应用

在构建安装程序之前，需要先构建前端应用程序：

```bash
cd frontend
npm install
npm run build:win
```

这将生成 `build-output\MineContext-Windows\` 目录，包含所有应用程序文件。

### 步骤 2: 构建安装程序

使用批处理脚本构建安装程序：

```bash
build-installer.bat
```

或者手动使用 Inno Setup 编译器：

```
"E:\Program Files (x86)\Inno Setup 6\Compil32.exe" /cc install-setup.iss
```

### 步骤 3: 安装程序输出

构建完成后，安装程序将输出到：

```
build-output\MineContext-Setup-0.1.2-beta.exe
```

## 安装程序功能

### 主要特性

1. **开机自动启动** - 用户可选择是否启用
2. **桌面快捷方式** - 可选创建
3. **开始菜单快捷方式** - 自动创建
4. **程序卸载** - 完全卸载（包括开机启动项）

### 安装选项

在安装过程中，用户可以选择：

- ✓ 创建桌面快捷方式
- ✓ 开机自动启动
- ✓ 安装后立即运行

### 安装路径

默认安装到：
```
C:\Program Files\MineContext
```

## 开机启动机制

### 实现原理

安装程序会将注册表项添加到：
```
HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run
```

注册表键名: `MineContext`
注册表值: 程序的完整路径

### 控制选项

- **启用开机启动**: 在安装时勾选"开机自动启动"选项
- **禁用开机启动**: 不勾选该选项，或者稍后在任务管理器中禁用
- **卸载时**: 自动删除开机启动项

## 自定义配置

### 修改应用程序信息

编辑 `install-setup.iss` 文件中的以下内容：

```pascal
#define MyAppName "MineContext"          // 应用程序名称
#define MyAppVersion "0.1.2-beta"        // 版本号
#define MyAppPublisher "MineContext"      // 发布者
#define MyAppURL "https://example.com/"   // 官方网址
```

### 修改安装路径

修改 `DefaultDirName` 参数：

```pascal
DefaultDirName={autopf}\{#MyAppName}    // 系统默认程序目录
DefaultDirName=C:\MyApp                 // 自定义路径
```

### 修改图标

需要提供图标文件路径：

```pascal
SetupIconFile=frontend\build\icon.icns
```

### 修改权限要求

```pascal
PrivilegesRequired=admin          // 需要管理员权限
PrivilegesRequired=lowest         // 普通用户权限
```

## 故障排除

### 问题 1: 找不到 Inno Setup

**错误信息**: "找不到 Inno Setup 6"

**解决方法**:
1. 确认 Inno Setup 6 已正确安装
2. 检查安装路径是否为: `E:\Program Files (x86)\Inno Setup 6`
3. 如果路径不同，编辑 `build-installer.bat` 中的 `INNO_SETUP` 变量

### 问题 2: 未找到已构建的应用

**错误信息**: "未找到已构建的应用程序"

**解决方法**:
```bash
cd frontend
npm run build:win
```

### 问题 3: 编译失败

**错误信息**: "安装程序编译失败"

**解决方法**:
1. 检查 `install-setup.iss` 语法是否正确
2. 确认 `build-output\MineContext-Windows\` 目录存在
3. 查看 Inno Setup 的编译日志

### 问题 4: 开机启动不生效

**可能原因**:
1. 安装时未勾选"开机自动启动"选项
2. 杀毒软件或组策略限制了开机启动项
3. Windows 启动项被禁用

**解决方法**:
1. 重新安装并勾选该选项
2. 在任务管理器中手动添加
3. 检查 Windows 启动项设置

## 测试建议

### 测试安装程序

1. 在干净的虚拟机或测试环境中运行安装程序
2. 测试各种安装选项组合
3. 验证所有文件是否正确安装
4. 检查开机启动是否正常工作

### 测试卸载

1. 测试完全卸载
2. 验证开机启动项是否被删除
3. 检查是否有残留文件和注册表项

### 测试开机启动

1. 安装时勾选"开机自动启动"
2. 重启计算机
3. 验证应用程序是否自动启动

## 文件结构

```
项目根目录/
├── install-setup.iss          # Inno Setup 安装脚本
├── build-installer.bat        # 构建批处理脚本
├── build-output/              # 构建输出目录
│   ├── MineContext-Windows/   # 前端构建输出
│   └── MineContext-Setup-*.exe  # 最终安装程序
└── frontend/                  # 前端源码目录
```

## 版本历史

- **0.1.2-beta**: 初始版本，添加开机启动功能

