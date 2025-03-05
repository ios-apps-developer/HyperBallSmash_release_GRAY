import AudioToolbox
import AVFoundation
import CoreHaptics
import SwiftUI

final class MusicManagerHBS: ObservableObject {
    static let shared = MusicManagerHBS()
    private var playerHBS: AVAudioPlayer?
    private let soundKeyHBS = "SoundOnHBS"
    private let vibroKeyHBS = "VibroOnHBS"

    @Published var isSoundOnHBS: Bool {
        didSet {
            UserDefaults.standard.set(isSoundOnHBS, forKey: soundKeyHBS)
            if isSoundOnHBS {
                playLoopingSoundHBS()
            } else {
                stopSoundHBS()
            }
        }
    }

    @Published var isVibroOnHBS: Bool {
        didSet {
            UserDefaults.standard.set(isVibroOnHBS, forKey: vibroKeyHBS)
        }
    }

    init() {
        self.isSoundOnHBS = UserDefaults.standard.object(forKey: soundKeyHBS) as? Bool ?? true
        self.isVibroOnHBS = UserDefaults.standard.object(forKey: vibroKeyHBS) as? Bool ?? true
        if isSoundOnHBS {
            playLoopingSoundHBS()
        }
    }

    func playLoopingSoundHBS() {
        guard let url = Bundle.main.url(forResource: "musicHBS", withExtension: "mp3") else { return }
        if playerHBS != nil { return }

        do {
            playerHBS = try AVAudioPlayer(contentsOf: url)
            playerHBS?.numberOfLoops = -1
            playerHBS?.volume = 0.04
            playerHBS?.prepareToPlay()
            playerHBS?.play()
        } catch {}
    }

    func stopSoundHBS() {
        playerHBS?.stop()
        playerHBS = nil
    }

    func triggerVibrationHBS() {
        guard isVibroOnHBS else { return }
        DispatchQueue.main.async {
            if CHHapticEngine.capabilitiesForHardware().supportsHaptics {
                let generatorHBS = UINotificationFeedbackGenerator()
                generatorHBS.notificationOccurred(.success)
            } else {
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            }
        }
    }
}
