//
//  OnboardView.swift
//  calendarReminder
//
//  Created by James on 25/2/2026.
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
import LaunchAtLogin
import AppKit
import EventKit

struct OnboardView: View {

    @AppStorage("OnboardingComplete") var onboardingComplete: Bool = false
    
    @Environment(\.dismissWindow) private var dismissWindow

    // Enum to define the different stages of onboarding
    enum OnboardingStage: CaseIterable {
        case welcome
        case permissions
        case tutorial
        case final

        var buttonText: String {
            switch self {
            case .welcome: return "Next"
            case .permissions: return "Permissions ready!"
            case .tutorial: return "I'm all set up!"
            case .final: return "Get started"
            }
        }

        var nextStage: OnboardingStage? {
            switch self {
            case .welcome: return .permissions
            case .permissions: return .tutorial
            case .tutorial: return .final
            case .final: return nil
            }
        }
    }

    @State private var currentStage: OnboardingStage = .welcome
    @State private var isCalendarAccessGranted: Bool = false

    var body: some View {
        VStack {
            Spacer()

            // Display content based on the current stage
            switch currentStage {
            case .welcome:
                WelcomeContentView()
            case .permissions:
                PermissionsContentView(isCalendarAccessGranted: $isCalendarAccessGranted)
            case .tutorial:
                TutorialContentView()
            case .final:
                FinalContentView()
            }

            Spacer()

            Button(currentStage.buttonText) {
                handleNextButton()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.extraLarge)
            .tint(.blue)
            .padding(.horizontal)
            .padding(.bottom)
            .disabled(currentStage == .permissions && !isCalendarAccessGranted)
        }
        .padding()
        .background(WindowAccessor { window in
            window.standardWindowButton(.closeButton)?.isHidden = true
            window.standardWindowButton(.miniaturizeButton)?.isHidden = true
            window.standardWindowButton(.zoomButton)?.isHidden = true
        })
    }

    private func handleNextButton() {
        if let nextStage = currentStage.nextStage {
            // Move to the next stage if available
            currentStage = nextStage
            print("Transitioning to stage: \(currentStage)")
        } else {
            // If there's no next stage, onboarding is complete
            onboardingComplete = true
            print("Onboarding complete set to true.")
            dismissWindow(id: "onboarding")
        }
    }
}

struct WindowAccessor: NSViewRepresentable {
    var onWindowReceived: (NSWindow) -> Void

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            if let window = view.window {
                onWindowReceived(window)
            }
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        if let window = nsView.window {
            onWindowReceived(window)
        }
    }
}


struct WelcomeContentView: View {
    
    var body: some View {
        VStack {
            Image(systemName: "calendar.badge.plus")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .foregroundColor(.accentColor)
                .padding(.bottom, 10)

            Text("Welcome to Calendar Reminder")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.bottom, 15)

            Text("Never miss an important event again! Calendar Reminder helps you organize your schedule and stay on top of your tasks with smart notifications.")
                .font(.title3)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 30)
                .padding(.bottom, 30)
        }
        .onAppear {
            Bundle.main.playAudio(soundName: "notify")
        }
    }
}

struct PermissionsContentView: View {
    
    @Binding var isCalendarAccessGranted: Bool
    
    @State var calendarAccessAttempts: Int = 0
    
    let eventStore = EKEventStore()
    
    var body: some View {
        VStack {
            Image(systemName: "hand.raised.app.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .foregroundColor(.accentColor)
                .padding(.bottom, 10)

            Text("Give calendar permissions")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.bottom, 15)

            Text("Calendar Reminder requires calendar permissions to work. We read your calendar events and send you reminders. Your calendar events never leave you machine. See the repo for more details.")
                .font(.title3)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 30)
                .padding(.bottom, 30)

            Button("Grant Calendar Access") {
                eventStore.requestFullAccessToEvents { (granted, error) in
                    if let error = error {
                        print("Something went wrong: \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            self.isCalendarAccessGranted = false
                        }
                        return
                    }
                    
                    DispatchQueue.main.async {
                        if granted {
                            print("Access granted.")
                            self.isCalendarAccessGranted = true
                        }
                        else {
                            print("Access denied.")
                            
                            if calendarAccessAttempts < 2 {
                                self.isCalendarAccessGranted = false
                                calendarAccessAttempts += 1
                            } else {
                                self.isCalendarAccessGranted = true
                            }
                            
                        }
                    }
                }
            }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .tint(.green)
                .padding(.top, 10)
            
            if isCalendarAccessGranted {
                Text("Calendar access granted!")
                    .font(.caption)
                    .foregroundColor(.green)
                    .padding(.top, 5)
            } else {
                Text("Please grant calendar access to continue. If you are having trouble try clicking the access button again, and you can troubleshoot later.")
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.top, 5)
            }
        }
    }
}


struct TutorialContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "book.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.accentColor)
                .padding(.bottom, 5)

            Text("Tutorial")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.bottom, 10)

            Text("Let's get you setup and ready to go!")
                .font(.title3)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 10)
                .padding(.bottom, 10)
            
            Image("TuStep1")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 700)
                .clipped()
            
            Text("Step 1: Open the calendar app \nStep 2: go to menu bar > file > New Calendar \nStep 3: Name your new Calendar EXACTLY 'Calendar Reminder', with the capital letters and the space exact. \nStep 4: Create events using this calendar, and you'll get reminded!")
                .font(.footnote)
                .multilineTextAlignment(.center)
                .foregroundStyle(.foreground)
                .padding(10)
            
        }
    }
}

struct FinalContentView: View {
    
    @AppStorage("SUEnableAutomaticChecks") private var autoCheck:Bool = true
    
    var body: some View {
        
        VStack {
            Image(systemName: "person.fill.questionmark")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .foregroundColor(.accentColor)
                .padding(.bottom, 10)

            Text("Customise your settings")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.bottom, 15)

            Text("You can also change these later in settings.")
                .font(.title3)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 30)
                .padding(.bottom, 30)

            Form {
                
                LaunchAtLogin.Toggle(label: {
                    Label("Launch app at login", systemImage: "power.circle")
                })
                
                Toggle(isOn: $autoCheck) {
                    Label("Automatically check for updates", systemImage: "square.and.arrow.down.badge.clock.fill")
                }
            }
            .minimumScaleFactor(1.1)
            .frame(height: 250)
            
        }
        .toggleStyle(.switch)
        .formStyle(.grouped)
    }
}


#Preview {
    // Note: If you have a custom initializer, you might need to adjust the preview.
    // For this example, OnboardView still has its default initializer and the new state
    // variable is private, so it won't affect the preview initializer directly.
    OnboardView()
}

