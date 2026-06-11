// Copyright (c) 2025 Beijing Volcano Engine Technology Co., Ltd.
// SPDX-License-Identifier: Apache-2.0

import { IpcServerPushChannel } from '@shared/ipc-server-push-channel'
import { app, BrowserWindow, powerMonitor, powerSaveBlocker } from 'electron'

class Power {
  private blockerId?: number
  private suspendCallbacks: ((...params: any[]) => void)[] = []
  private resumeCallbacks: ((...params: any[]) => void)[] = []
  private lockScreenCallbacks: ((...params: any[]) => void)[] = []
  private unlockScreenCallbacks: ((...params: any[]) => void)[] = []
  
  public registerSuspendCallback(callback: (...params: any[]) => void) {
    this.suspendCallbacks.push(callback)
  }
  public registerResumeCallback(callback: (...params: any[]) => void) {
    this.resumeCallbacks.push(callback)
  }
  public registerLockScreenCallback(callback: (...params: any[]) => void) {
    this.lockScreenCallbacks.push(callback)
  }
  public registerUnlockScreenCallback(callback: (...params: any[]) => void) {
    this.unlockScreenCallbacks.push(callback)
  }
  
  run(mainWindow: BrowserWindow) {
    this.blockerId = powerSaveBlocker.start('prevent-app-suspension')
    app.on('window-all-closed', () => {
      if (this.blockerId && powerSaveBlocker.isStarted(this.blockerId)) {
        powerSaveBlocker.stop(this.blockerId)
        console.log('🛑 powerSaveBlocker stopped')
      }
    })
    // Listen for macOS power events
    powerMonitor.on('suspend', () => {
      console.log('💤 System is about to sleep')
      this.suspendCallbacks.forEach((callback) => callback())
      mainWindow.webContents.send(IpcServerPushChannel.PushPowerMonitor, { key: 'suspend' })
    })

    powerMonitor.on('resume', () => {
      console.log('🌞 System has woken up')
      this.resumeCallbacks.forEach((callback) => callback())
      mainWindow.webContents.send(IpcServerPushChannel.PushPowerMonitor, { key: 'resume' })
    })

    powerMonitor.on('lock-screen', () => {
      console.log('🔒 Screen is locked')
      this.lockScreenCallbacks.forEach((callback) => callback())
      mainWindow.webContents.send(IpcServerPushChannel.PushPowerMonitor, { key: 'lock-screen' })
    })

    powerMonitor.on('unlock-screen', () => {
      console.log('🔓 Screen is unlocked')
      this.unlockScreenCallbacks.forEach((callback) => callback())
      mainWindow.webContents.send(IpcServerPushChannel.PushPowerMonitor, { key: 'unlock-screen' })
    })
  }
}
export { Power }
const powerWatcher = new Power()
export { powerWatcher }
