//
//  BlankView.swift
//  calendarReminder
//
//  Created by Jacksonvil on 11/3/2026.
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

struct BlankView: View {

    var body: some View {
        ZStack {
            Color(.yellow)
            VStack {
                Image(systemName: "macwindow.on.rectangle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .padding(.bottom, 10)
                
                Label("This window will be closed shortly...", systemImage: "clock")
                    .font(.title3)
                
                Text("\n If this doesn't close automatically, please use the close window button manually.\n Please submit a bug report on the Github Repo if you encounter issues with this window not closing.")
                    .font(.caption)
            }
            .multilineTextAlignment(.center)
            .padding()
            .task {
                try? await Task.sleep(for: .seconds(0.1))
                await closeHostingWindow()
            }
            .foregroundStyle(.black)
        }
        .frame(maxWidth: 600, maxHeight: 200)
    }

    @MainActor
    private func closeHostingWindow() async {
        if let window = NSApp.windows.first(where: { $0.contentViewController?.view.enclosingMenuItem == nil && $0.isVisible }) {
            window.performClose(nil)
        }
    }
}

#Preview {
    BlankView()
}
