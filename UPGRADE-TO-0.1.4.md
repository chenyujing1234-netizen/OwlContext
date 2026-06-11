# OwlContext 升级到 0.1.4 版本说明

## 📅 升级日期
2025-11-12

## 🎯 升级概览
本次升级从 MineContext 0.1.2 同步了上游 MineContext 0.1.4 的新功能和改进，同时保留了 OwlContext 的品牌定制和功能扩展。

## ✅ 已完成的同步

### 1. **前端依赖更新** (`frontend/package.json`)
- ✅ 升级版本号：`0.1.2` → `0.1.4`
- ✅ 新增依赖：
  - `mitt@^3.0.1` - 事件总线库
  - `pidusage@^4.0.1` - 进程资源监控
- ✅ 新增开发依赖：
  - `@types/pidusage@^2.0.5`
- ✅ 更新构建脚本：
  - 改进 `build:externals` 逻辑
  - 新增 `build:dev` 脚本
  - 优化 `build:win/mac` 以支持 `copy-backend`

### 2. **Python 后端依赖更新** (`pyproject.toml`)
- ✅ 升级版本号：`0.1.0` → `0.1.4`
- ✅ 提升 Python 最低版本要求：`>=3.9` → `>=3.10`
- ✅ 新增依赖：
  - `pypdfium2>=4.30.0` - PDF 文档处理
  - `python-docx>=1.0.0` - Word 文档处理
  - `python-multipart` - 多部分表单数据解析
- ✅ 新增可选开发依赖组：
  ```toml
  [project.optional-dependencies]
  dev = [
      "black>=24.8.0",
      "isort>=5.13.0",
      "pre-commit>=3.6.0",
      "pytest>=8.0.0"
  ]
  ```

### 3. **前端新增目录和文件**
- ✅ 新增任务系统：
  - `frontend/src/main/background/task/cache-value.ts` - 自动刷新缓存工具类
  - `frontend/src/main/background/task/screen-monitor-task.ts` - 屏幕监控任务调度器
- ✅ 增强的 Python 构建脚本：
  - `frontend/build-python.js` - 跨平台 Python 可执行文件构建，支持 Windows 自动跳过 macOS 特定工具

### 4. **配置文件更新** (`config/config.yaml`)
- ✅ 新增 `document_processing` 配置段：
  ```yaml
  document_processing:
    enabled: true
    batch_size: 3        # VLM 批处理大小
    max_image_size: 1024 # 最大图片尺寸
    dpi: 200             # PDF 转图片 DPI
    text_threshold_per_page: 50 # 扫描文档检测阈值
  ```
- ✅ 调整处理器配置：
  - `document_processor.batch_size`: `10` → `5`
  - `document_processor.batch_timeout`: `5` → `30`
  - `screenshot_processor.similarity_hash_threshold`: `5` → `7`

### 5. **示例文件**
- ✅ 新增 `examples/` 目录，包含：
  - `example_document_processor.py` - 文档处理器示例
  - `example_screenshot_processor.py` - 截图处理器示例
  - `example_screenshot_to_insights.py` - 截图智能分析示例
  - `example_todo_deduplication.py` - 待办事项去重示例
  - `regenerate_debug_file.py` - 调试文件再生成工具

### 6. **后端代码更新**
- ✅ 新增 `opencontext/context_processing/processor/document_converter.py` - 文档格式转换器

## 🔄 保留的 OwlContext 定制功能

以下功能是 OwlContext 独有的，已在升级中完全保留：

### 1. **品牌定制**
- ✅ 产品名称：`OwlContext`（替代 MineContext）
- ✅ 自定义图标：`logo_new.png`
- ✅ 托盘图标显示："OwlContext"
- ✅ 启动注册表项名称："OwlContext"

### 2. **系统托盘增强**
- ✅ 左键/右键单击托盘图标显示菜单
- ✅ 双击托盘图标直接显示窗口
- ✅ 托盘菜单项：
  - 显示窗口
  - **应用管理** - 打开 `http://127.0.0.1:8000/contexts`（新增）
  - 退出
- ✅ 关闭窗口最小化到托盘（不退出应用）

### 3. **开机自启动**
- ✅ 安装时自动配置开机启动
- ✅ 启动参数：`--hidden` 后台启动
- ✅ 启动时隐藏窗口，仅显示托盘图标
- ✅ 检测登录启动状态：`app.getLoginItemSettings().wasOpenedAtLogin`

### 4. **自动录制**
- ✅ 启动时自动检测 token 配置
- ✅ 满足条件时自动开始录制：
  - 已配置 API Key
  - 有权限且在正确日期
  - 已配置录制源
  - 在录制时间范围内

### 5. **辅助脚本**
- ✅ `scripts/check-startup.bat` - 检查开机启动配置
- ✅ `scripts/clean-build.bat` - 清理构建目录和锁定文件
- ✅ `scripts/fix-rcedit-error.bat` - 修复 electron-builder 文件锁定问题

## ⚠️ 已知差异和注意事项

### 1. **ScreenshotService 方法签名变化**
- **0.1.2（当前）**：`takeScreenshot(groupIntervalTime: string, sourceId: string)`
- **0.1.4（上游）**：`takeScreenshot(sourceId: string, batchTime: Dayjs)`
- **状态**：暂未同步此变化，需要评估对现有功能的影响
- **建议**：在下一个迭代中统一方法签名

### 2. **Python 最低版本要求提升**
- **旧版本**：Python >= 3.9
- **新版本**：Python >= 3.10
- **影响**：用户需要升级到 Python 3.10 或更高版本
- **建议**：在文档中明确说明版本要求

### 3. **文档处理新功能**
- 新增了 PDF/Word 文档处理能力
- 新增依赖：`pypdfium2`, `python-docx`
- 需要重新安装 Python 依赖

## 🚀 下一步操作

### 对于开发者：
1. **更新依赖**：
   ```bash
   # 前端依赖
   cd frontend
   npm install

   # Python 依赖
   cd ..
   uv sync  # 或 pip install -e .
   ```

2. **测试新功能**：
   - 测试自动启动 + 后台运行
   - 测试托盘图标交互（单击、双击）
   - 测试"应用管理"菜单项
   - 测试自动录制功能

3. **重新构建**：
   ```bash
   cd frontend
   npm run build:win
   ```

### 对于最终用户：
1. **卸载旧版本**（可选）
2. **安装新版本** `OwlContext-Setup-0.1.4-beta.exe`
3. **验证开机启动**：运行 `scripts\check-startup.bat`
4. **配置 API Key**（如果是新安装）
5. **启动录制**（会自动开始）

## 📝 版本兼容性

| 组件 | 0.1.2 | 0.1.4 |
|------|-------|-------|
| Node.js | >= 18 | >= 18 |
| Python | >= 3.9 | >= 3.10 ⚠️ |
| Electron | 37.2.3 | 37.2.3 |
| React | 19.1.0 | 19.1.0 |
| FastAPI | latest | latest |

## 🐛 已知问题

1. **Windows 构建锁定问题**：
   - 症状：`electron-builder` 报告文件锁定错误
   - 解决方案：运行 `scripts\clean-build.bat` 或 `scripts\fix-rcedit-error.bat`

2. **ICO 图标生成**：
   - 状态：需要手动生成或构建时生成
   - 路径：`frontend/build/icon.ico`
   - 建议：使用在线工具从 PNG 转换

## 📚 参考文档

- [MineContext 0.1.4 Release](https://github.com/volcengine/MineContext/releases/tag/0.1.4)
- [MineContext GitHub](https://github.com/volcengine/MineContext)
- [Electron 文档](https://www.electronjs.org/docs)
- [FastAPI 文档](https://fastapi.tiangolo.com/)

## 🙏 致谢

感谢 MineContext 团队（volcengine）提供优秀的开源项目！

---

**更新人**：AI Assistant  
**日期**：2025-11-12  
**版本**：OwlContext 0.1.4

