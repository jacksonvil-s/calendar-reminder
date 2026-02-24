//
//  StatusItemController.swift
//  calendarReminder
//
//  Created by James on 22/2/2026.
//
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import SwiftUI
import AppKit

final class StatusItemController: NSObject, NSApplicationDelegate {
    
    @AppStorage("MenuBarIcon") private var menuBarIcon:String = "calendar.badge"
    
    private var statusItem: NSStatusItem?
    private var timerCoordinator = CalendarPollingController()
    private var settingsWC: NSWindowController?
    
    func applicationDidFinishLaunching(_ notification:Notification) {
        //Originally init; creating status items in menu bar
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        item.button?.image = NSImage(systemSymbolName: menuBarIcon, accessibilityDescription: "Calendar Reminder menu bar icon")
        item.menu = buildMenu()
        self.statusItem = item
        
        //Starting polling helper
        timerCoordinator.start()
    }
    
    func applicationWillTerminate(_ notification:Notification) {
        timerCoordinator.stop()
    }
    
    private func buildMenu() -> NSMenu {
        let menu = NSMenu()
        
        //menu.addItem(NSMenuItem(title: "Open", action: #selector(openAction), keyEquivalent: ""))
        
        let settingsItem = NSMenuItem(title: "Settings", action: #selector(settings(_:)), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let quitItem = NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        
        return menu
    }
    
    //@objc private func openAction() {
        //Add some actions here
    //}
    
    @objc private func settings(_ sender: Any?) {
        if let wc = settingsWC, wc.window?.isVisible == true {
            wc.showWindow(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        
        let hosting = NSHostingController(rootView: SettingView())
        let window = NSWindow(contentViewController: hosting)
        window.title = "Settings"
        window.styleMask = [.titled, .closable, .miniaturizable]
        window.setContentSize(NSSize(width: 800, height: 500))
        window.center()
        
        let wc = NSWindowController(window: window)
        wc.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
        self.settingsWC = wc
    }
    
    @objc private func quit() {
        let alert = NSAlert()
        alert.messageText = "Are you sure you want to quit?"
        alert.informativeText = "Any ongoing actions will be stopped. You will not be reminded while the app is quit."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Quit")
        alert.addButton(withTitle: "Cancel")

        // Prefer presenting from the settings window if visible, else as app-modal
        if let window = settingsWC?.window, window.isVisible {
            alert.beginSheetModal(for: window) { response in
                if response == .alertFirstButtonReturn { // Quit
                    NSApp.terminate(nil)
                }
            }
        } else if let mainWindow = NSApp.keyWindow ?? NSApp.mainWindow {
            alert.beginSheetModal(for: mainWindow) { response in
                if response == .alertFirstButtonReturn {
                    NSApp.terminate(nil)
                }
            }
        } else {
            // Fall back to a synchronous modal if no window is available
            let response = alert.runModal()
            if response == .alertFirstButtonReturn {
                NSApp.terminate(nil)
            }
        }
    }
    
}
