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
    
    //Settings
    @AppStorage("BackgroundColour") private var backgroundColour:String = "white"
    @AppStorage("EnableSound") private var soundOn:Bool = true
    @AppStorage("EnableAnimation") private var animationOn:Bool = true
    @AppStorage("SnoozeDuration") private var snoozeDuration:Int = 10

    @State private var showCard: Bool = false
    @State private var dimOpacity: Double = 0.0
    
    //Events
    let onDismiss: () -> Void
    let onSnooze: () -> Void
    
    //Calendar variables
    let title: String
    let timeRangeText: String
    let place: String
    
        private var backgroundColor: Color {
            let colorMap: [String: Color] = [
                "red": .red, "orange": .orange, "yellow": .yellow,
                "green": .green, "blue": .blue, "indigo": .indigo,
                "purple": .purple, "black": .black, "white": .white, "gray": .gray
            ]
            return colorMap[backgroundColour.lowercased()] ?? .white
        }

        private var foregroundStyleColor: Color {
            let nsColor = NSColor(backgroundColor)
            
            var luminance:Double = 0.0
            
            if let rgbColor = nsColor.usingColorSpace(.sRGB) {
                    luminance = (0.299 * rgbColor.redComponent) +
                                    (0.587 * rgbColor.greenComponent) +
                                    (0.114 * rgbColor.blueComponent)
                }
            
            return luminance > 0.5 ? .black : .white
        }
    
    var body: some View {
        ZStack {
            backgroundColor
                .opacity(dimOpacity)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 1), value: dimOpacity)

            VStack(spacing: 24) {
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 56, weight: .bold))
                    .foregroundStyle(foregroundStyleColor)
                    .symbolEffect(.bounce, options: .repeat(.periodic()), isActive: animationOn)
                    .accessibilityHidden(true)

                VStack(spacing: 8) {
                    Text("Your Upcoming Event")
                        .font(.title2.weight(.semibold))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(foregroundStyleColor)
                        .accessibilityAddTraits(.isHeader)

                    Text(title)
                        .font(.system(size: 34, weight: .bold))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(foregroundStyleColor)

                    Text("Today, \(timeRangeText) • \(place)")
                        .font(.callout)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(foregroundStyleColor.opacity(0.9))
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                }
                
                VStack(spacing: 12) {
                    // Got it (Green)
                    Button(action: {
                        animatedDismiss(onDismiss)
                    }) {
                        Label("Got it", systemImage: "checkmark.circle")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .symbolEffect(.bounce.up.byLayer, options: .repeat(.continuous), isActive: animationOn)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(Color.green)
                            )
                    }
                    .buttonStyle(.plain)

                    // Snooze (Yellow)
                    Button(action: {
                        animatedDismiss(onSnooze)
                    }) {
                        Label("Snooze for \(snoozeDuration) minutes (coming soon...)", systemImage: "alarm.waves.left.and.right")
                            .font(.headline)
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .symbolEffect(.bounce.up.byLayer, options: .repeat(.continuous), isActive: animationOn)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(Color.yellow)
                            )
                    }
                    .buttonStyle(.plain)
                    .disabled(true)
                    
                }
                
            }
            .padding(24)
            .frame(maxWidth: 520)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: .black.opacity(0.25), radius: 24, x: 0, y: 12)
            .padding(24)
            .scaleEffect(showCard ? 1.0 : 0.96)
            .opacity(showCard ? 1.0 : 0.0)
            .animation(.spring(response: 0.45, dampingFraction: 0.85), value: showCard)
        }
        .onAppear() {
            print("View appeared!")
            print(title, timeRangeText, place)
            // Drive entrance animations
            self.dimOpacity = 0.95
            self.showCard = true
        }
    }
    
    private func animatedDismiss(_ action: @escaping () -> Void) {
        withAnimation(.easeInOut(duration: 0.2)) {
            dimOpacity = 0.0
        }
        withAnimation(.spring(response: 0.3, dampingFraction: 1.0)) {
            showCard = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
            action()
        }
    }
}



#Preview {
    DinnerOverlayView(onDismiss: {}, onSnooze: {}, title: "Dinner", timeRangeText: "6:00-6:30 PM", place: "Kitchen")
}


