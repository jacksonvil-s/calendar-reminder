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
    
    @AppStorage("EnableSound") private var soundSetting: Bool = false
    @AppStorage("BackgroundColour") private var backgroundColour:String = "white"
    @AppStorage("Frequency") private var frequency:Double = 60.0
    
    var body: some View {
        
        TabView {
            //General
            Tab("General", systemImage: "gearshape" ) {
                Form {
                    Section (header: Text("General")) {
                        LaunchAtLogin.Toggle()
                        Toggle(isOn: $soundSetting) {
                            Label("Sounds", systemImage:"speaker.wave.2.fill")
                        }
                    }
                    
                    Section (header: Text("Updates")) {
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
                    
                }
            }
            
            Tab("About", systemImage: "info.circle") {
                Form {
                    Section (header: Text("About"), footer: Text("Copyright info: \n \n Copyright 2026 Jacksonvil \n \n Licensed under the Apache License, Version 2.0 (the 'License'); you may not use this file except in compliance with the License. You may obtain a copy of the License at \n \n http://www.apache.org/licenses/LICENSE-2.0 \n \n Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an 'AS IS' BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.")) {
                        
                        LabeledContent("App version", value: "v0.2.1")
                        LabeledContent("Settings version", value: "v1.0")
                        
                        Link(destination: URL(string: "https://github.com/jacksonvil-s/calendar-reminder/tree/main")!) {
                            Label("Check out the Github repo!", systemImage: "network")
                        }
                        
                        Text("If you like this project, consider giving the repo a star! I thank you in advance.")
                    }
                }
            }
            
        }
        .frame(minWidth: 450, minHeight: 300)
        .buttonStyle(.glassProminent)
        .toggleStyle(.switch)
        .formStyle(.grouped)
        .padding(20)
        .tabViewStyle(.sidebarAdaptable)
    }
}


#Preview {
    SettingView()
}
