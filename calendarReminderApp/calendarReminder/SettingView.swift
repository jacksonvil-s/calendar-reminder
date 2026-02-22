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
    
    @State private var soundSetting: Bool = false
    
    var body: some View {
        VStack {
            Form {
                Link("Check out the Github repo!", destination: URL(string: "https://github.com/jacksonvil-s/calendar-reminder/tree/main")!)
                    .font(.headline)
            }
            .formStyle(.grouped)
            
            Form {
                Text("Updates")
                    .font(.headline)
                Button("Check for updates...") {
                    updatorController.checkForUpdates(nil)
                }
            }
            .toggleStyle(.switch)
            .formStyle(.grouped)
            .buttonStyle(.glassProminent)
            
            Form {
                Text("General")
                    .font(.headline)
                LaunchAtLogin.Toggle()
                Toggle("Sounds", isOn: $soundSetting)
            }
            .toggleStyle(.switch)
            .formStyle(.grouped)
        }
        .padding(3)
    }
}

#Preview {
    SettingView()
}
