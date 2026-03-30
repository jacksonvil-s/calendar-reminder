//
//  AppDelegate.swift
//  calendarReminder
//
//  Created by Jacksonvil on 19/2/2026.
//
// Copyright 2026 Jacksonvil
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


import SwiftUI
import AppKit
import EventKit
import DynamicNotchKit

class CalendarPollingController {
    
    private struct PendingEvent {
        let key: String
        let title: String
        let time: String
        let location: String?
    }
    
    private struct SnoozedEvent {
        let key: String
        let title: String
        let time: String
        let location: String?
        let wakeTime: Date
    }
    
    private var snoozedEvents: [SnoozedEvent] = []
    private var pendingEvents: [PendingEvent] = []
    
    private var lastPresented: PendingEvent?
    
    //Variables
    @AppStorage("SnoozeDuration") private var snoozeMinutes: Int = 10
    @AppStorage("Frequency") private var frequency:Double = 60
    @AppStorage("EnableSound") private var enableSound:Bool = true
    
    
    private var notifiedEventKeys = Set<String>()
    private var pendingKeys = Set<String>()
    
    let eventStore = EKEventStore()
    var timer: Timer?
    var panel: NSPanel?
    
    func formatTimeRange(start: Date, end: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        
        let startString = formatter.string(from: start)
        let endString = formatter.string(from: end)
        
        return "\(startString) - \(endString)"
    }
    
    
    func findCalendar(named name: String) -> EKCalendar? {
        // 1. Get every calendar that stores events
        let allCalendars = eventStore.calendars(for: .event)
        
        // 2. Look for the first one where the title matches
        return allCalendars.first(where: { $0.title.lowercased() == name.lowercased() })
    }
    
    func hidePanel() {
        panel?.ignoresMouseEvents = true
        if let panel = panel {
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.5
                panel.animator().alphaValue = 0.0
            }, completionHandler: { [weak self] in
                panel.orderOut(nil)
                self?.panel = nil
                print("Panel hidden")
            })
        } else {
            print("Panel hidden")
        }
    }
    
    private func key(for event: EKEvent) -> String? {
        guard let id = event.eventIdentifier else { return nil }
        
        if let occurrence = event.occurrenceDate ?? event.startDate {
            return "\(id)#\(occurrence.timeIntervalSince1970)"
        } else {
            return id
        }
    }
    
    func showPanel(title: String?, eventTime: String?, location:String?) {
        if let existedPanel = self.panel {
            existedPanel.makeKeyAndOrderFront(nil)
            existedPanel.orderFrontRegardless()
            NSApp.activate(ignoringOtherApps: true)
            return
        } else {
            let overlayView = DinnerOverlayView(onDismiss: { [weak self] in
                Bundle.main.playAudio(soundName: "dismiss")
                self?.hidePanel()
                Task {
                    try await Task.sleep(for: .seconds(2))
                    self?.presentingNextEvent()
                }
            },
                onSnooze: { [weak self] in
                    guard let self = self else { return }
                    print("Snoozed")

                    if let last = self.lastPresented {
                        let wake = Date().addingTimeInterval(TimeInterval(self.snoozeMinutes * 60))
                        let snoozed = SnoozedEvent(key: last.key, title: last.title, time: last.time, location: last.location, wakeTime: wake)
                        self.snoozedEvents.append(snoozed)

                        self.notifiedEventKeys.remove(last.key)
                    }

                    self.hidePanel()
                    Task {
                        try await Task.sleep(for: .seconds(2))
                        self.presentingNextEvent()
                    }
            },
                                                title: title ?? "No title specified",
                                                timeRangeText: eventTime ?? "No time specified",
                                                place: location ?? "No location specified")
            
            let hostingView = NSHostingView<DinnerOverlayView>(rootView: overlayView)
            
            //let panelWidth: CGFloat = 300
            //let panelHeight: CGFloat = 300
            
            if let screenSize = NSScreen.main?.frame {
                // let x = screenSize.origin.x + (screenSize.width - panelWidth) / 2
                //let y = screenSize.origin.y + (screenSize.height - panelWidth) / 2
                
                let contentRect = screenSize
                
                let Nspanel = NSPanel(contentRect: contentRect,
                                      styleMask: .borderless,
                                      backing: .buffered,
                                      defer: false)
                
                Nspanel.isOpaque = false
                Nspanel.hasShadow = false
                Nspanel.backgroundColor = .clear
                Nspanel.level = .screenSaver
                Nspanel.collectionBehavior = [
                    .canJoinAllSpaces,
                    .fullScreenAuxiliary,
                    .stationary
                ]
                Nspanel.hidesOnDeactivate = false
                Nspanel.ignoresMouseEvents = false
                Nspanel.isMovable = false
                
                
                Nspanel.contentView = hostingView
                Nspanel.setFrame(contentRect, display: true)
                Nspanel.alphaValue = 0.0
                Nspanel.makeKeyAndOrderFront(nil)
                Nspanel.orderFrontRegardless()
                NSAnimationContext.runAnimationGroup { context in
                    context.duration = 1.5
                    Nspanel.animator().alphaValue = 1.0
                }
                NSApp.activate(ignoringOtherApps: true)
                
                self.panel = Nspanel
                print("Panel created")
                
                Bundle.main.playAudio(soundName: "notify")
            } else {
                print("ERROR: Could not get screen size")
            }
        }
    }
    
    private func wakeSnoozedIfNeeded(now: Date = Date()) {
        guard !snoozedEvents.isEmpty else { return }
        var ready: [SnoozedEvent] = []
        var notReady: [SnoozedEvent] = []
        for item in snoozedEvents {
            if item.wakeTime <= now {
                ready.append(item)
            } else {
                notReady.append(item)
            }
        }
        snoozedEvents = notReady
        for item in ready {
            if !pendingKeys.contains(item.key) {
                let pending = PendingEvent(key: item.key, title: item.title, time: item.time, location: item.location)
                notifiedEventKeys.remove(item.key)
                pendingEvents.append(pending)
                pendingKeys.insert(item.key)
            }
        }
    }
    
    private func queueIt(event: EKEvent) {
        guard let key = key(for: event) else {
            print("WARNING: No identifier found. Skipping this event.")
            return
        }
        
        if snoozedEvents.contains(where: { $0.key == key }) {
            print("Currently snoozing.")
            return
        }
        
        if notifiedEventKeys.contains(key) {
            print("Already notified, skipping")
            return
        }
        
        if pendingKeys.contains(key) {
            print("Already queued, skipping")
            return
        }
        
        let eventTime = formatTimeRange(start: event.startDate, end: event.endDate)
        let pending = PendingEvent(
            key: key,
            title: event.title ?? "No title",
            time: eventTime,
            location: event.location ?? "No location"
        )
        
        pendingEvents.append(pending)
        pendingKeys.insert(key)
        print("Now queued event: \(pending.title)")
    }
    
    private func presentingNextEvent() {
        
        if panel != nil {
            print("ERROR: Panel exists! Exiting to prevent reappearing. This is an issue that requires attention. \nATTENTION NEEDED!")
            return
        }
        
        guard !pendingEvents.isEmpty else {
            print("No more events. Exiting.")
            return
        }
        
        let next = pendingEvents.removeFirst()
        pendingKeys.remove(next.key)
        lastPresented = next
        
        DispatchQueue.main.async {
            self.showPanel(title: next.title, eventTime: next.time, location: next.location)
        }
        
        notifiedEventKeys.insert(next.key)
    }
    
    func pollNow() {
        let now = Date()
        wakeSnoozedIfNeeded(now: now)
        let start = now - 86400
        let end = now + 86400
        
        print(now, start, end)
        print("Polling...")
        
        if let targetCalendar = findCalendar(named: "Calendar Reminder") {
            let Predicate = eventStore.predicateForEvents(withStart: start, end: end, calendars: [targetCalendar])
            let events = eventStore.events(matching: Predicate)
            
            print("Found calendar named Calendar Reminder")
            
            for event in events {
                
                let oneMinNotch = DynamicNotchInfo(
                    icon: .init(systemName: "1.brakesignal"),
                    title: "Your event '\(event.title ?? "No title")' will start in less than 1 minute.",
                    description: "Location: \(event.location ?? "No location")",
                    style: .notch
                )
                
                let fiveMinNotch = DynamicNotchInfo(
                    icon: .init(systemName: "5.calendar"),
                    title: "Your event '\(event.title ?? "No title")' will start in less than 5 minutes.",
                    description: "Location: \(event.location ?? "No location")",
                    style: .notch
                )
                
                
                let timeUntilStart = event.startDate.timeIntervalSince(now)
                if (event.startDate <= now && event.endDate > now) || (timeUntilStart > 0 && timeUntilStart <= 30) {
                    print("Event is ongoing: \(event.title ?? "No title")")
                    queueIt(event: event)
                } else if timeUntilStart > 30 && timeUntilStart <= 60 {
                    print("Event starting within 1 minute: \(event.title ?? "No title")")
                    Task {
                        await oneMinNotch.expand(on: NSScreen.main!)
                        Task.detached {
                            try? await Task.sleep(for: .seconds(5))
                            await oneMinNotch.compact(on: NSScreen.main!)
                            await oneMinNotch.hide()
                        }
                    }
                } else if timeUntilStart > 60 && timeUntilStart <= 300 {
                    print("Event starting within 5 minutes: \(event.title ?? "No title")")
                    Task {
                        await fiveMinNotch.expand(on: NSScreen.main!)
                        Task.detached {
                            try? await Task.sleep(for: .seconds(5))
                            await fiveMinNotch.compact(on: NSScreen.main!)
                            await fiveMinNotch.hide()
                        }
                    }
                } else {
                    print("Event not matching... \(event.title ?? "No title")")
                }
            }
            
            presentingNextEvent()
            
            //Cleaning up lists
            var stillRelevant = Set<String>()
            for event in events {
                if event.endDate > now, let key = key(for: event) {
                    stillRelevant.insert(key)
                }
            }
            // Keep only what’s still relevant
            notifiedEventKeys = notifiedEventKeys.intersection(stillRelevant)
            
            
        }
    }
    
    func startPolling() {
        print ("Starting 60s polling...")
        timer = Timer.scheduledTimer(withTimeInterval: frequency, repeats: true) {[weak self] _ in
            print("Polling...")
            self?.pollNow()
            print ("Timer fired")
        }
    }
    
    func requestCalendarAccess(completion: @escaping (Bool) -> Void) {
        eventStore.requestFullAccessToEvents { (granted, error) in
            if let error = error {
                print("Something went wrong: \(error.localizedDescription)")
                return
            }
            
            if granted {
                print("Access granted.")
            }
            else {
                print("Access denied.")
            }
            
            completion(granted)
        }
    }
    
    
    func start() {
        print ("Starting... please wait")
        
        requestCalendarAccess { [weak self] granted in
            guard let self = self else {return}
            
            if granted {
                print ("Successfully granted permission. Now loading up timer..")
                DispatchQueue.main.async {
                    self.startPolling()
                }
            } else {
                print ("Permission failed. Please try again.")
            }
        }
    }
    
    func stop() {
        print ("Stopping... please wait")
        timer?.invalidate()
        timer = nil
    }
    
}

