//
//  DinnerReminderView.swift
//  calendarReminder
//
//  Created by Jacksonvil on 19/2/2026.
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

struct DinnerOverlayView: View {
    
    //Events
    let onDismiss: () -> Void
    
    //Calendar variables
    let title: String
    let timeRangeText: String
    let place: String
    
    var body: some View {
        ZStack {
            Color.green
            VStack {
                Text ("TIME FOR YOUR CALENDAR EVENT!")
                    .font(.system(size: 70, weight: .heavy))
                    .minimumScaleFactor(0.3)
                    .lineLimit(2)
                    .foregroundColor(.yellow)
                    .padding(10)
                    .accessibilityAddTraits(.isHeader)
                Text("Your event '\(title)' between \(timeRangeText) at \(place) will be starting soon.")
                    .font(.system(size: 20, weight: .semibold))
                    .minimumScaleFactor(0.2)
                    .lineLimit(2)
                    .foregroundStyle(.white)
                    .padding(5)
                Button ("Dismiss") {
                    print("Dismiss button tapped")
                    onDismiss()
                }
                .font(.title)
                .padding(10)
                .buttonStyle(.glassProminent)
                .tint(.white)
                .foregroundStyle(.green)
            }
            .padding(24)
            .frame(alignment: .center)
            .multilineTextAlignment(.center)
        }
        .ignoresSafeArea()
        .onAppear() {
            print ("View appeared!")
            print (title, timeRangeText, place)
        }
    }
}



#Preview {
    DinnerOverlayView(onDismiss: {}, title: "Dinner with Tim Cook", timeRangeText: "6:00-7:30 PM", place: "Kitchen")
}
