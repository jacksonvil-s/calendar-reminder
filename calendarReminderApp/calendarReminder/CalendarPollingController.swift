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

class CalendarPollingController {
    
    private struct PendingEvent {
        let key: String
        let title: String
        let time: String
        let location: String?
    }
    
    private var pendingEvents: [PendingEvent] = []
    private var pendingKeys = Set<String>() // to prevent duplicates in the queue-up system
    
    //Variables
    @AppStorage("Frequency") private var frequency:Double = 60
    
    private var notifiedEventKeys = Set<String>()
    
    let eventStore = EKEventStore()
    var timer: Timer?
    var panel: NSPanel?
    
    func formatTimeRange(start: Date, end: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short // This gives you "6:00 PM" format based on user locale
        
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
        panel?.orderOut(nil)
        panel = nil
        print("Panel hidden")
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
                self?.hidePanel()
                self?.presentingNextEvent()
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
                Nspanel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
                Nspanel.ignoresMouseEvents = false
                Nspanel.isMovable = false
                
                
                Nspanel.contentView = hostingView
                Nspanel.makeKeyAndOrderFront(nil)
                Nspanel.orderFrontRegardless()
                NSApp.activate(ignoringOtherApps: true)
                
                self.panel = Nspanel
                print("Panel created")
            } else {
                print("ERROR: Could not get screen size")
            }
        }
    }
    
    private func queueIt(event: EKEvent) {
        guard let key = key(for: event) else {
            print("WARNING: No identifier found. Skipping this event.")
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
        if panel != nil {return}
        
        guard !pendingEvents.isEmpty else { return }
        let next = pendingEvents.removeFirst()
        pendingKeys.remove(next.key)
        
        DispatchQueue.main.async {
            self.showPanel(title: next.title, eventTime: next.time, location: next.location)
        }
        
        notifiedEventKeys.insert(next.key)
    }
    
    func pollNow() {
        let now = Date()
        let start = now - 86400
        let end = now + 86400
        
        print(now, start, end)
        print("Polling...")
        
        if let targetCalendar = findCalendar(named: "Calendar Reminder") {
            let Predicate = eventStore.predicateForEvents(withStart: start, end: end, calendars: [targetCalendar])
            let events = eventStore.events(matching: Predicate)
            
            print("Found calendar named Calendar Reminder")
            
            for event in events {
                if event.startDate <= now && event.endDate > now {
                    queueIt(event: event)
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
        self.pollNow()
        print ("First poll success...")
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
