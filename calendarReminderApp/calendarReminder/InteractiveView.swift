//
//  Interactive.swift
//  calendarReminder
//
//  Created by Jacksonvil on 5/3/2026.
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
import Combine

struct InteractiveView: View {
    @AppStorage("GameComplete") private var gameComplete:Bool = false
    
    @State private var targetPosition: CGPoint = .zero
    @State private var containerSize: CGSize = .zero
    @State private var hits = 0
    @State private var timeLeft: Int = 15
    @State private var isRunning = false
    @State private var gameOver = false

    private let requiredHits = 5
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Catch the target")
                    .font(.headline)
                Spacer()
                Text("Time: \(timeLeft)s")
                    .font(.subheadline)
                    .foregroundStyle(timeLeft <= 5 ? .red : .secondary)
            }
            
            if !isRunning && !gameOver {
                Button("Start") {
                    resetGame()
                    startGame()
                }
                .buttonStyle(.borderedProminent)
            }
            
            ZStack(alignment: .topLeading) {
                GeometryReader { geo in
                    Color.clear
                        .contentShape(Rectangle())
                        .onAppear {
                            containerSize = geo.size
                            resetGame()
                        }

                    // Moving target
                    Button {
                        guard isRunning, !gameOver else { return }
                        hits += 1
                        randomizePosition(in: geo.size)

                        if hits >= requiredHits {
                            isRunning = false
                            gameOver = true
                        }
                    } label: {
                        Image(systemName: "target")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundStyle(.tint)
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.plain)
                    .focusable(false)
                    .position(targetPosition)
                    .animation(.easeInOut(duration: 0.25), value: targetPosition)
                }
            }
            .frame(height: 120)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(.thinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(Color.primary.opacity(0.06))
            )

            Text(progressText)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 10) {
                if isRunning && !gameOver {
                    Button("Pause") { isRunning = false }
                        .buttonStyle(.borderedProminent)
                } else if !isRunning && !gameOver && hits > 0 {
                    Button("Resume") { isRunning = true }
                        .buttonStyle(.borderedProminent)
                }

                if gameOver {
                    Button("Restart") {
                        resetGame()
                        startGame()
                    }
                    .buttonStyle(.borderedProminent)
                }

                if gameOver && hits >= requiredHits {
                    Label("Success! You can now dismiss.", systemImage: "checkmark.seal.fill")
                        .foregroundStyle(.green)
                } else if gameOver {
                    Label("Try again", systemImage: "xmark.circle.fill")
                        .foregroundStyle(.red)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .onReceive(timer) { _ in
            guard isRunning, !gameOver else { return }
            timeLeft -= 1
            if timeLeft <= 0 {
                isRunning = false
                gameOver = true
                if hits >= requiredHits {
                    gameComplete = true
                }
            } else {
                if containerSize != .zero {
                    randomizePosition(in: containerSize)
                }
            }
        }
    }

    private var progressText: String {
        if gameOver && hits >= requiredHits {
            return "Nice reflexes! You caught it \(hits)/\(requiredHits) times."
        } else if gameOver {
            return "You got \(hits)/\(requiredHits). Tap Play again."
        } else {
            return "Hits: \(hits)/\(requiredHits)"
        }
    }

    private func resetGame() {
        hits = 0
        timeLeft = 15
        gameOver = false
        isRunning = false
        if containerSize != .zero {
            randomizePosition(in: containerSize)
        }
    }

    private func startGame() {
        isRunning = true
    }

    private func randomizePosition(in size: CGSize) {
        let padding: CGFloat = 24
        let x = CGFloat.random(in: padding...(size.width - padding))
        let y = CGFloat.random(in: padding...(size.height - padding))
        targetPosition = CGPoint(x: x, y: y)
    }
}



#Preview {
    InteractiveView()
}
