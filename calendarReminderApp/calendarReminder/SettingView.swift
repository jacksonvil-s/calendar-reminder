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
import Sparkle

enum SettingsTab: String, CaseIterable, Identifiable {
    case general = "General"
    case updates = "Updates"
    case customisation = "Customisation"
    case about = "About"
    
    var id: String { rawValue }
    
    var systemImage: String {
        switch self {
        case .general: return "gear"
        case .updates: return "arrow.trianglehead.2.clockwise.rotate.90"
        case .customisation: return "paintpalette"
        case .about: return "info.circle"
        }
    }
}

struct SettingView: View {
    
    let updaterController: SPUStandardUpdaterController = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil)
    
    @AppStorage("EnableSound") private var soundSetting: Bool = true
    @AppStorage("EnableAnimation") private var animationSetting: Bool = true
    @AppStorage("BackgroundColour") private var backgroundColour:String = "white"
    @AppStorage("Frequency") private var frequency:Double = 60.0
    @AppStorage("MenuBarIcon") private var menuBarIcon:String = "calendar.badge"
    @AppStorage("SnoozeDuration") private var snoozeDuration:Int = 10
    
    @AppStorage("OnboardingComplete") private var onboardingComplete:Bool = false
    
    @AppStorage("SUAutomaticallyUpdate") private var autoUpdate:Bool = false
    @AppStorage("SUEnableAutomaticChecks") private var autoCheck:Bool = true
    
    @Environment(\.openWindow) var openWindow
    
    @State private var showQuitConfirmation:Bool = false
    @State private var selectedTab: SettingsTab = .general
    
    
    var body: some View {
        
        
        NavigationSplitView {
            List(SettingsTab.allCases, selection: $selectedTab) { tab in
                Label(tab.rawValue, systemImage: tab.systemImage)
                    .tag(tab)
            }
            .navigationTitle("Settings")
        } detail: {
            Group {
                switch selectedTab {
                case .general:
                    Form {
                        Section (header: Text("General"), footer: Text("Animations forced to on. This restriction will be lifted in a future version.")) {
                            LaunchAtLogin.Toggle()
                            Toggle(isOn: $soundSetting) {
                                Label("Sounds", systemImage:"speaker.wave.2.fill")
                            }
                            Toggle(isOn: $animationSetting) {
                                Label("Animations and Effects", systemImage: "sensor.radiowaves.left.and.right.fill")
                            }
                            .disabled(true)
                        }
                        
                        Section (header: Text("App control")) {
                            Button("Quit app", systemImage: "rectangle.portrait.and.arrow.forward.fill") {
                                showQuitConfirmation = true
                            }
                            .confirmationDialog("Are you sure you want to quit?", isPresented: $showQuitConfirmation, titleVisibility: .visible) {
                                Button("Quit", role: .destructive) {
                                    print ("Closing app from settings...")
                                    NSApp.terminate(nil)
                                }
                                Button("Cancel", role: .cancel) {}
                            } message: {
                                Text("Any ongoing actions will be stopped. You will not be reminded while the app is quit. If you wanted to close settings instead, use the window controls.")
                            }
                        }
                    }
                case .updates:
                    Form {
                        Section (header: Text("Update the app"), footer: Text("Updates are powered by Sparkle.")) {
                            Button("Check for updates...") {
                                updaterController.checkForUpdates(nil)
                            }
                        }
                        
                        Section (header: Text("Update preferences"), footer: Text("When auto install is enabled, auto check will be enabled alongside.")) {
                            Toggle(isOn: $autoCheck) {
                                Label("Automatically check for updates", systemImage: "square.and.arrow.down.badge.clock.fill")
                            }
                            .disabled(autoUpdate)
                            
                            Toggle(isOn: $autoUpdate) {
                                Label("Automatically install updates", systemImage: "square.and.arrow.down.badge.checkmark.fill")
                            }
                        }
                        .onChange(of: autoUpdate) { _, newValue in
                            if newValue == true {
                                autoCheck = true
                            }
                        }
                    }
                case .customisation:
                    Form {
                        Section(header: Text("Popup window")) {
                            Picker("Background colour", selection: $backgroundColour) {
                                Text("White").tag("white")
                                Text("Grey").tag("grey")
                                Text("Black").tag("black")
                                Text("Red").tag("red")
                                Text("Orange").tag("orange")
                                Text("Yellow").tag("yellow")
                                Text("Green").tag("green")
                                Text("Blue").tag("blue")
                                Text("Purple").tag("purple")
                            }
                            
                            Picker("Snooze duration", selection: $snoozeDuration) {
                                Label("1 min", systemImage: "1.circle").tag(1)
                                Label("2 min", systemImage: "2.circle").tag(2)
                                Label("3 min", systemImage: "3.circle").tag(3)
                                Label("4 min", systemImage: "4.circle").tag(4)
                                Label("5 min", systemImage: "5.arrow.trianglehead.clockwise").tag(5)
                                Label("7 min", systemImage: "7.circle").tag(7)
                                Label("9 min", systemImage: "9.circle").tag(9)
                                Label("10 min", systemImage: "10.arrow.trianglehead.clockwise").tag(10)
                                Label("15 min", systemImage: "15.arrow.trianglehead.clockwise").tag(15)
                                Label("20 min", systemImage: "20.circle").tag(20)
                            }
                        }
                        
                        Section(header:Text("Timer")) {
                            Picker("Calendar checking frequency", selection: $frequency) {
                                Text("Having a lower amount means less CPU usage, while having a higher amount means more CPU usage.")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .disabled(true)
                                Divider()
                                Text("Short (30 sec) - More CPU usage").tag(30.0)
                                Text("Medium (60 sec) - Balanced CPU usage").tag(60.0)
                                Text("Long (90 sec) - Less CPU usage").tag(90.0)
                                Text("Ultra-long (120 sec) - Minimal CPU usage").tag(120.0)
                            }
                        }
                        
                        Section(header:Text("Menu bar"), footer:Text("(macOS 26+) To hide the menu bar item, you can use the built in macOS setting. Go into system settings, menu bar, then uncheck the app. Please note the app settings will be unaccessible. This will be addressed in a future version.")) {
                            Picker("Menu bar icon", selection: $menuBarIcon) {
                                Text("Changes here require an app restart.")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .disabled(true)
                                Divider()
                                Label("Calendar with badge (default)", systemImage: "calendar.badge").tag("calendar.badge")
                                Label("Calendar in circle", systemImage: "calendar.circle").tag("calendar.circle")
                                Label("Calendar with exclamation mark", systemImage: "calendar.badge.exclamationmark").tag("calendar.badge.exclamationmark")
                                Label("Calendar with clock", systemImage: "calendar.badge.clock").tag("calendar.badge.clock")
                                Label("Timeline", systemImage: "calendar.day.timeline.right").tag("calendar.day.timeline.right")
                            }
                        }
                    }
                case .about:
                    Form {
                        Section(header: Text("Onboarding")) {
                            LabeledContent("Onboarding", value: "You can use this to redo the tutorial, permissions and initial setup.")
                            Button("Show onboarding again", systemImage: "restart.circle") {
                                onboardingComplete = false
                                openWindow(id: "onboarding")
                            }
                        }
                        
                        Section (header: Text("About"), footer: Text("Copyright info: \n \nCopyright 2026 Jacksonvil \n \nLicensed under the Apache License, Version 2.0 (the 'License'); you may not use this file except in compliance with the License. You may obtain a copy of the License at \n \nhttp://www.apache.org/licenses/LICENSE-2.0 \n \nUnless required by applicable law or agreed to in writing, software distributed under the License is distributed on an 'AS IS' BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.")) {
                            
                            LabeledContent("App version", value: "v\(Bundle.main.appVersion)")
                            LabeledContent("Build number", value: "Build \(Bundle.main.buildNumber) (universal x64/arm64)")
                            LabeledContent("Settings version", value: "v1.3")
                            
                            LabeledContent("Check out the Github repo!") {
                                Link(destination: URL(string: "https://github.com/jacksonvil-s/calendar-reminder/tree/main")!) {
                                    Label("Access via web", systemImage: "network")
                                }
                            }
                            
                            LabeledContent("Message from the creator", value: "If you like this project, consider giving the repo a star! I thank you in advance.")
                            
                            LabeledContent("Quit without dialog warning") {
                                Button("Quit", systemImage: "xmark.bin") {
                                    NSApp.terminate(nil)
                                }
                            }
                        }
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            .toggleStyle(.switch)
            .formStyle(.grouped)
            .padding(.horizontal, 5)
            .padding(.vertical, 20)
        }
        .navigationSplitViewColumnWidth(min: 300, ideal: 320, max: 325)
        .frame(minWidth: 650, minHeight: 500)
        
    }
    

}


#Preview {
    SettingView()
}

