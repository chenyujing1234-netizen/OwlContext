# 图标更新说明

## 已完成的工作

1. ✅ 已将新图标 `logo_new.png` 复制到 `frontend/build/icon.png`
2. ✅ 已在 `electron-builder.yml` 中配置 Windows 图标路径
3. ✅ 已在 `frontend/src/main/index.ts` 中设置窗口图标（所有平台）
4. ✅ 已在 `install-setup.iss` 中配置安装程序图标路径

## 生成 ICO 文件

Inno Setup 需要 `.ico` 格式的图标文件。有两种方法：

### 方法 1：使用 electron-builder 自动生成（推荐）

electron-builder 在构建 Windows 应用时会自动从 PNG 生成 ICO 文件。

**步骤：**
1. 先运行前端构建：
   ```bash
   cd frontend
   npm run build:win
   ```
2. 构建完成后，electron-builder 会在 `frontend/build/` 目录生成 `icon.ico` 文件
3. 然后运行 Inno Setup 构建：
   ```bash
   build-installer.bat
   ```

### 方法 2：使用在线工具手动转换

如果方法 1 没有生成 ICO 文件，可以使用在线工具：

1. 访问以下任一网站：
   - https://convertio.co/png-ico/
   - https://redketchup.io/icon-converter
   - https://www.icoconverter.com/

2. 上传 `frontend/build/icon.png` 文件
3. 选择生成多尺寸 ICO 文件（建议包含 16x16, 32x32, 48x48, 256x256）
4. 下载生成的 `icon.ico` 文件
5. 将文件保存到 `frontend/build/icon.ico`

## 验证图标

构建完成后，请检查：

1. **应用程序窗口图标**：
   - 启动应用程序
   - 查看窗口左上角图标是否为新图标

2. **安装程序图标**：
   - 查看生成的 `OwlContext-Setup-0.1.2-beta.exe` 文件
   - 在文件浏览器中应该显示新图标

3. **可执行文件图标**：
   - 查看 `build-output/OwlContext-Windows/OwlContext.exe`
   - 应该显示新图标

## 注意事项

- ICO 文件必须是有效的 Windows 图标格式
- 建议图标尺寸至少为 256x256 像素
- 如果图标显示不正确，请清理构建缓存后重新构建：
  ```bash
  cd frontend
  npm run clean:dist
  npm run build:win
  ```

