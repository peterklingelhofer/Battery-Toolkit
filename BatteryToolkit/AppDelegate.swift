/*
  Copyright (C) 2022 Marvin Häuser. All rights reserved.
  SPDX-License-Identifier: BSD-3-Clause
*/

import Cocoa
import os.log

@main
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var menuBarExtraItem: NSStatusItem!
    @IBOutlet weak var menuBarExtraMenu: NSMenu!

    @IBOutlet weak var settingsItem: NSMenuItem!
    @IBOutlet weak var disableBackgroundItem: NSMenuItem!

    @IBAction private func unregisterDaemonHandler(sender: NSMenuItem) {
        BTAppPrompts.promptUnregisterDaemon()
    }

    private func startDaemon() {
        BatteryToolkit.startDaemon() { (status) -> Void in
            switch status {
                case .enabled:
                    os_log("Daemon is enabled")

                    DispatchQueue.main.async {
                        self.disableBackgroundItem.isEnabled = true
                        self.settingsItem.isEnabled          = true

                        self.menuBarExtraItem = NSStatusBar.system.statusItem(
                            withLength: NSStatusItem.squareLength
                            )
                        self.menuBarExtraItem.button?.image = NSImage(named: NSImage.Name("StatusItemIcon"))
                        self.menuBarExtraItem.menu = self.menuBarExtraMenu
                    }
                    
                case .requiresApproval:
                    os_log("Daemon requires approval")
                    
                    DispatchQueue.main.async {
                        BTAppPrompts.promptApproveDaemon()
                    }

                case .notRegistered:
                    os_log("Daemon not registered")
                    
                    DispatchQueue.main.async {
                        if BTAppPrompts.promptRegisterDaemonError() {
                            self.startDaemon()
                        }
                    }
            }
        }
    }

    //
    // NSApplicationDelegate is implicitly @MainActor and thus the warnings are
    // misleading.
    //

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        startDaemon()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        BatteryToolkit.stop()
    }

    func applicationWillBecomeActive(_ notification: Notification) {
        _ = NSApplication.shared.setActivationPolicy(.regular)
    }

    func applicationWillResignActive(_ notification: Notification) {
        guard NSApplication.shared.keyWindow == nil else {
            return
        }

        _ = NSApplication.shared.setActivationPolicy(.accessory)
    }
}
