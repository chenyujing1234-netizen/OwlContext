// Copyright (c) 2025 Beijing Volcano Engine Technology Co., Ltd.
// SPDX-License-Identifier: Apache-2.0

// don't reorder this file, it's used to initialize the app data dir and
// other which should be run before the main process is ready
// eslint-disable-next-line
import './bootstrap'

import '@main/config'

import { app, shell, BrowserWindow, protocol, Tray, Menu, nativeImage } from 'electron'
import path, { join } from 'path'
import fs from 'fs'
import { electronApp, optimizer, is } from '@electron-toolkit/utils'

import { registerIpc } from './ipc'
import openInspector from './utils/inspector'
import db from './services/DatabaseService'
import screenshotService from './services/ScreenshotService'
import { isDev } from './constant'
import icon from '../../resources/icon.png?asset'
import { ensureBackendRunning, startBackendInBackground, stopBackendServerSync } from './backend'
import { powerWatcher } from './background/os/Power'
import { initLog } from '@shared/logger/init'
import { getLogger } from '@shared/logger/main'
initLog()
const logger = getLogger('MainEntry')

const isPackaged = app.isPackaged
const actuallyDev = isDev && !isPackaged // true

// Save the original console.log
const originalConsoleLog = console.log

// Screenshot cleanup timer
let cleanupIntervalId: NodeJS.Timeout | null = null

// Keep references to main window and system tray
let tray: Tray | null = null
let mainWindowRef: BrowserWindow | null = null
// Flag for distinguishing user-initiated quit from window close/hide
;(app as any).isQuiting = false

/**
 * Start screenshot cleanup scheduled task
 * Runs once per day, cleaning up screenshots older than 15 days
 */
function startScreenshotCleanup() {
  // Clear existing timer if already running
  if (cleanupIntervalId) {
    clearInterval(cleanupIntervalId)
  }

  // Execute cleanup immediately
  performCleanup()

  // Execute cleanup every 24 hours
  const oneDayInMs = 24 * 60 * 60 * 1000
  cleanupIntervalId = setInterval(() => {
    performCleanup()
  }, oneDayInMs)

  logger.info('Screenshot cleanup task started, will run daily')
}

/**
 * Perform cleanup operation
 */
async function performCleanup() {
  try {
    logger.info('Starting screenshot cleanup...')
    const result = await screenshotService.cleanupOldScreenshots(15) // Keep 15 days
    if (result.success) {
      logger.info(`Screenshot cleanup completed. Deleted ${result.deletedCount} directories, freed ${((result.deletedSize || 0) / 1024 / 1024).toFixed(2)} MB`)
    } else {
      logger.error(`Screenshot cleanup failed: ${result.error}`)
    }
  } catch (error) {
    logger.error('Screenshot cleanup error:', error)
  }
}

/**
 * Stop screenshot cleanup scheduled task
 */
function stopScreenshotCleanup() {
  if (cleanupIntervalId) {
    clearInterval(cleanupIntervalId)
    cleanupIntervalId = null
    logger.info('Screenshot cleanup task stopped')
  }
}

function createWindow() {
  // Create the browser window.
  const mainWindow = new BrowserWindow({
    width: 1180,
    height: 660,
    show: false,
    autoHideMenuBar: true,
    icon: icon, // Set icon for all platforms
    webPreferences: {
      preload: join(__dirname, '../preload/index.js'),
      sandbox: false,
      webSecurity: false
    }
  })

  console.log = (...args) => {
    try {
      if (mainWindow && !mainWindow.isDestroyed()) {
        mainWindow.webContents.send('main-log', ...args)
      } else {
        originalConsoleLog(...args)
      }
    } catch (error) {
      originalConsoleLog(...args)
    }
  }

  mainWindow.on('ready-to-show', () => {
    // Check if launched with --hidden or --startup flag (from auto-start)
    const isAutoStart = process.argv.includes('--hidden') || 
                        process.argv.includes('--startup') ||
                        app.getLoginItemSettings().wasOpenedAtLogin
    
    if (!isAutoStart) {
      // Only show window if not launched from auto-start
      mainWindow.show()
    } else {
      logger.info('Application launched from auto-start, starting in background mode')
    }

    if (!actuallyDev) {
      ensureBackendRunning(mainWindow).catch((error) => {
        logger.error('Failed to ensure backend is running:', error)
      })
    }
  })

  // Intercept close to hide to tray instead of quitting
  mainWindow.on('close', (event) => {
    // If quitting explicitly (from tray menu), allow close
    if ((app as any).isQuiting) return
    event.preventDefault()
    mainWindow.hide()
  })

  mainWindow.webContents.setWindowOpenHandler((details) => {
    shell.openExternal(details.url)
    return { action: 'deny' }
  })

  // HMR for renderer base on electron-vite cli.
  // Load the remote URL for development or the local html file for production.
  if (is.dev && process.env['ELECTRON_RENDERER_URL']) {
    mainWindow.loadURL(process.env['ELECTRON_RENDERER_URL'])
  } else {
    mainWindow.loadFile(join(__dirname, '../renderer/index.html'))
  }
  return mainWindow
}

// This method will be called when Electron has finished
// initialization and is ready to create browser windows.
// Some APIs can only be used after this event occurs.
let server: any
app.whenReady().then(() => {
  logger.info('app_started', { argv: process.argv, version: app.getVersion() })

  protocol.registerBufferProtocol('vikingdb', (request, callback) => {
    try {
      let filePath = request.url.replace('vikingdb://', '')
      filePath = decodeURIComponent(filePath)

      const fullPath = path.resolve(filePath)

      console.log('Reading file:', fullPath)

      if (fs.existsSync(fullPath)) {
        const data = fs.readFileSync(fullPath)
        const extension = path.extname(fullPath).toLowerCase()

        // Set MIME type based on file extension
        let mimeType = 'application/octet-stream'
        if (extension === '.png') mimeType = 'image/png'
        else if (extension === '.jpg' || extension === '.jpeg') mimeType = 'image/jpeg'
        else if (extension === '.gif') mimeType = 'image/gif'
        else if (extension === '.svg') mimeType = 'image/svg+xml'

        callback({
          mimeType: mimeType,
          data: data
        })
      } else {
        callback({ error: -6 })
      }
    } catch (error) {
      console.error('Error reading file:', error)
      callback({ error: -2 })
    }
  })

  // Set app user model id for windows
  electronApp.setAppUserModelId('com.vikingdb.desktop')

  // Default open or close DevTools by F12 in development
  // and ignore CommandOrControl + R in production.
  // see https://github.com/alex8088/electron-toolkit/tree/master/packages/utils
  app.on('browser-window-created', (_, window) => {
    optimizer.watchWindowShortcuts(window)

    // Automatically open DevTools in development environment

    if (isDev) {
      window.webContents.openDevTools()
      console.log('DevTools opened automatically in development mode')
    }
  })

  const mainWindow = createWindow()
  mainWindowRef = mainWindow
  openInspector(mainWindow)
  powerWatcher.run(mainWindow)
  startBackendInBackground(mainWindow)

  // Start screenshot cleanup scheduled task
  startScreenshotCleanup()

  app.on('activate', function () {
    // On macOS it's common to re-create a window in the app when the
    // dock icon is clicked and there are no other windows open.
    if (BrowserWindow.getAllWindows().length === 0) createWindow()
  })

  registerIpc(mainWindow, app)

  // Initialize system tray for background running
  try {
    // Prefer using packaged asset path for tray icon
    let trayImage = nativeImage.createFromPath(icon as unknown as string)
    if (trayImage.isEmpty()) {
      // Fallback to an absolute path under resources if needed
      const fallback = path.join(app.getAppPath(), 'resources', 'icon.png')
      trayImage = nativeImage.createFromPath(fallback)
    }
    tray = new Tray(trayImage)
    tray.setToolTip('OwlContext')
    const contextMenu = Menu.buildFromTemplate([
      {
        label: '显示窗口',
        click: () => {
          if (mainWindowRef) {
            mainWindowRef.show()
            if (mainWindowRef.isMinimized()) mainWindowRef.restore()
            mainWindowRef.focus()
          }
        }
      },
      {
        label: '应用管理',
        click: () => {
          shell.openExternal('http://127.0.0.1:8000/contexts').catch((error) => {
            logger.error('Failed to open management page:', error)
          })
        }
      },
      { type: 'separator' },
      {
        label: '退出',
        click: () => {
          ;(app as any).isQuiting = true
          app.quit()
        }
      }
    ])
    tray.setContextMenu(contextMenu)
    
    // Left-click to show context menu
    tray.on('click', () => {
      if (tray && mainWindowRef) {
        tray.popUpContextMenu(contextMenu)
      }
    })
    
    // Double-click to show the window directly
    tray.on('double-click', () => {
      if (mainWindowRef) {
        mainWindowRef.show()
        if (mainWindowRef.isMinimized()) mainWindowRef.restore()
        mainWindowRef.focus()
      }
    })
  } catch (e) {
    logger.error('Failed to initialize system tray:', e as Error)
  }
})

// Quit when all windows are closed, except on macOS. There, it's common
// for applications and their menu bar to stay active until the user quits
// explicitly with Cmd + Q.
app.on('window-all-closed', () => {
  // 不在 Windows/Linux 上自动退出，保持后台运行（通过托盘）
  if (process.platform === 'darwin') {
    // macOS 上保持与平台一致的行为：除非 Cmd+Q，否则保持活跃
    // 这里什么都不做即可
  }
})

// In this file you can include the rest of your app's specific main process
// code. You can also put them in separate files and require them here.

// in production mode, handle uncaught exception and unhandled rejection globally
if (!isDev) {
  // handle uncaught exception
  process.on('uncaughtException', (error) => {
    logger.error('Uncaught Exception:', error)
  })

  // handle unhandled rejection
  process.on('unhandledRejection', (reason, promise) => {
    logger.error(`Unhandled Rejection at: ${promise} reason: ${reason}`)
  })
}

app.on('before-quit', () => {
  ;(app as any).isQuiting = true
  // Restore the original console.log to avoid "Object has been destroyed" errors during exit
  console.log = originalConsoleLog

  // Stop screenshot cleanup scheduled task
  stopScreenshotCleanup()

  if (server) {
    server.close()
  }
  stopBackendServerSync()
  db.close()
  // Destroy tray on quit
  if (tray) {
    try {
      tray.destroy()
    } catch {}
    tray = null
  }
})
