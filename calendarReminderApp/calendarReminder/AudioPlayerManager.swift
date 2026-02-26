import Foundation
import AVFoundation

@MainActor
final class AudioPlayerManager: NSObject, AVAudioPlayerDelegate {
    static let shared = AudioPlayerManager()

    private var player: AVAudioPlayer?

    private override init() {
        super.init()
    }

    func playWAV(named name: String, in bundle: Bundle = .main) {
        guard let url = bundle.url(forResource: name, withExtension: "wav") else {
            print("AudioPlayerManager: Missing resource: \(name).wav")
            return
        }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.delegate = self
            player.prepareToPlay()
            self.player = player // retain so playback isn't cut off
            player.play()
        } catch {
            print("AudioPlayerManager: Failed to start playback: \(error)")
        }
    }

    // AVAudioPlayerDelegate
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if let current = player as AVAudioPlayer?, self.player === current {
            self.player = nil
        }
    }
}
