import Foundation
import AVFoundation

public class TextToSpeechService: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    /// Language of output
    var language: String
    /// Read message
    var content: String
    var utterance: AVSpeechUtterance
    @Published var synthesizer: AVSpeechSynthesizer
    /// True if language is set, false if voice is set
    var languageSet: Bool
    /// Voice of output
    var voice: String
    /// Voice volume
    var volume: Float
    /// Voice speed
    var rate: Float
    
    @Published var isSpeaking: Bool = false

    init(language: String = "en-US", content: String = "", volume: Float = 1.0, rate: Float = AVSpeechUtteranceDefaultSpeechRate) {
        self.content = content
        self.language = language
        self.voice = ""
        self.utterance = AVSpeechUtterance(string: content)
        self.utterance.volume = volume
        self.utterance.rate = rate
        self.utterance.voice = AVSpeechSynthesisVoice(language: language)
        self.synthesizer = AVSpeechSynthesizer()
        self.languageSet = true
        self.volume = volume
        self.rate = rate
        super.init()
        self.synthesizer.delegate = self
    }

    init(voice: String, content: String = "", volume: Float = 1.0, rate: Float = AVSpeechUtteranceDefaultSpeechRate) {
        self.content = content
        self.language = ""
        self.voice = voice
        self.utterance = AVSpeechUtterance(string: content)
        self.utterance.volume = volume
        self.utterance.rate = rate
        self.utterance.voice = AVSpeechSynthesisVoice(identifier: voice)
        self.synthesizer = AVSpeechSynthesizer()
        self.languageSet = false
        self.volume = volume
        self.rate = rate
        super.init()
        self.synthesizer.delegate = self
    }

    func speak() {
        setUtterance() // No sequential speaking with same utterance
        self.synthesizer.speak(utterance)
    }
    
    func stopSpeaking() {
        if synthesizer.isSpeaking {
            self.synthesizer.stopSpeaking(at: .immediate)
        }
    }

    func setLanguage(language: String) {
        self.language = language
        self.utterance.voice = AVSpeechSynthesisVoice(language: language)
        self.voice = ""
        self.languageSet = true
    }

    func setVolume(volume: Float) {
        self.volume = volume
        self.utterance.volume = volume
    }

    func setVoice(voice: String) {
        self.voice = voice
        self.utterance.voice = AVSpeechSynthesisVoice(identifier: voice)
        self.language = ""
        self.languageSet = false
    }

    func setRate(rate: Float) {
        self.rate = rate
        self.utterance.rate = rate
    }
    
    private func setUtterance() {
        self.utterance = AVSpeechUtterance(string: content)
        if languageSet {
            self.utterance.voice = AVSpeechSynthesisVoice(language: language)
        } else {
            self.utterance.voice = AVSpeechSynthesisVoice(identifier: voice)
        }
        self.utterance.rate = rate
        self.utterance.volume = volume
    }
    
    func setContent(content: String) {
        self.content = content
        setUtterance()
    }

    // MARK: - AVSpeechSynthesizerDelegate methods

    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = true
        }
    }

    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = false
        }
    }

    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = false
        }
    }

    // Implement other delegate methods if needed
}
