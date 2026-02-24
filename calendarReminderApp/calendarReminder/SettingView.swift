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

struct SettingView: View {
    
    let updatorController: SPUStandardUpdaterController = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil)
    
    @AppStorage("EnableSound") private var soundSetting: Bool = true
    @AppStorage("EnableAnimation") private var animationSetting: Bool = true
    @AppStorage("BackgroundColour") private var backgroundColour:String = "white"
    @AppStorage("Frequency") private var frequency:Double = 60.0
    @AppStorage("MenuBarIcon") private var menuBarIcon:String = "calendar.badge"
    
    @State private var showQuitConfirmation = false
    
    var body: some View {
        
        TabView {
            Tab("General", systemImage: "gear" ) {
                Form {
                    Section (header: Text("General")) {
                        LaunchAtLogin.Toggle()
                        Toggle(isOn: $soundSetting) {
                            Label("Sounds", systemImage:"speaker.wave.2.fill")
                        }
                        Toggle(isOn: $animationSetting) {
                            Label("Animations and Effects", systemImage: "sensor.radiowaves.left.and.right.fill")
                        }
                    }
                    
                    Section (header: Text("App control")) {
                        Button("Quit app", systemImage: "rectangle.portrait.and.arrow.forward.fill") {
                            showQuitConfirmation = true
                        }
                        .confirmationDialog("Are you sure you want to quit?", isPresented: $showQuitConfirmation, titleVisibility: .visible) {
                            
                            Button("Continue (quit)", role: .destructive) {
                                print ("Closing app from settings...")
                                NSApp.terminate(nil)
                            }
                            Button("Cancel", role: .cancel) {}
                        } message: {
                            Text("Any ongoing actions will be stopped. You will not be reminded while the app is quit. If you wanted to close settings instead, use the window controls.")
                        }
                        
                    }
                }
            }
            
            Tab ("Updates", systemImage: "arrow.trianglehead.2.clockwise.rotate.90") {
                Form {
                    Section (header: Text("Keep the app on the latest version"), footer: Text("Updates are powered by Sparkle")) {
                        Button("Check for updates...") {
                            updatorController.checkForUpdates(nil)
                        }
                    }
                }
            }
            
            Tab("Customisation", systemImage: "paintpalette") {
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
                    }
                    
                    Section(header:Text("Timer")) {
                        Picker("Calendar checking frequency", selection: $frequency) {
                            Text("I recommend 60 seconds. \nAnything over 90 seconds may mean you miss a meeting.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .disabled(true)
                            Divider()
                            Text("Short (30 sec)").tag(30.0)
                            Text("Medium (60 sec)").tag(60.0)
                            Text("Long (90 sec)").tag(90.0)
                            Text("Ultra-long (120 sec)").tag(120.0)
                        }
                    }
                    
                    Section(header:Text("Menu bar")) {
                        Picker("Menu bar icon", selection: $menuBarIcon) {
                            Text("Changes here require an app restart.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .disabled(true)
                            Divider()
                            Label("Calendar with badge (default)", systemImage: "calendar.badge").tag("calendar.badge")
                            Label("Calendar in circle", systemImage: "calendar.circle").tag("calendar.circle")
                            Label("Calendar with exclaimation mark", systemImage: "calendar.badge.exclamationmark").tag("calendar.badge.exclamationmark")
                            Label("Calendar with clock", systemImage: "calendar.badge.clock").tag("calendar.badge.clock")
                            Label("Timeline", systemImage: "calendar.day.timeline.right").tag("calendar.day.timeline.right")
                        }
                    }
                    
                }
            }
            
            Tab("About", systemImage: "info.circle") {
                Form {
                    Section (header: Text("About"), footer: Text("Copyright info: \n \nCopyright 2026 Jacksonvil \n \nLicensed under the Apache License, Version 2.0 (the 'License'); you may not use this file except in compliance with the License. You may obtain a copy of the License at \n \nhttp://www.apache.org/licenses/LICENSE-2.0 \n \nUnless required by applicable law or agreed to in writing, software distributed under the License is distributed on an 'AS IS' BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.")) {
                        
                        LabeledContent("App version", value: "v\(Bundle.main.appVersion)")
                        LabeledContent("Build number", value: "Build \(Bundle.main.buildNumber) (universal x64/arm64)")
                        LabeledContent("Settings version", value: "v1.2")
                        
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
        .frame(minWidth: 650, minHeight: 500)
        .buttonStyle(.borderedProminent)
        .toggleStyle(.switch)
        .formStyle(.grouped)
        .padding(.horizontal, 5)
        .padding(.vertical, 20)
        .tabViewStyle(.sidebarAdaptable)
    }
}


#Preview {
    SettingView()
}
