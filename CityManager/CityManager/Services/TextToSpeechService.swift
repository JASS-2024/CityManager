//
//  TextToSpeechService.swift
//  SwipeFresh
//
//  Created by Aleksandra Topalova on 26.03.24.
//

import Foundation
import AVFoundation

public class TextToSpeechService {
    // For using this service, first select one of the two constructors
    // It is only possible to set the language or voice of the output
    // Change from language to voice setting / voice to language setting possible
    // By selecting a language, the default voice for that language on the device is selected

    /// Language of output
    var language: String
    /// Read message
    var content: String
    var utterance: AVSpeechUtterance
    var synthesizer: AVSpeechSynthesizer
    
    /// True if language is set, false if voice is set
    var languageSet: Bool
    /// Voice of output
    var voice: String
    /// Voice volume
    var volume: Float
    /// Voice speed
    var rate: Float

    /// Constructor for Text-To-Speech with language setting
    init(language: String, content: String, volume: Float, rate: Float) {
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
    }

    /// Constructor for Text-To-Speech with voice setting
    init(voice: String, content: String, volume: Float, rate: Float) {
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
    }

    /// Initialize a `TextToSpeechService` with default values.
    convenience init() {
        self.init(voice: "com.apple.ttsbundle.Daniel-compact", content: "", volume: 150.0, rate: 0.5)
    }

    /// Read text
    func speak() {
        setUtterance() // No sequential speaking with same utterance
        self.synthesizer.speak(utterance)
    }

    /// Change language
    func setLanguage(language: String) {
        self.language = language
        self.utterance.voice = AVSpeechSynthesisVoice(language: language)
        self.voice = ""
        self.languageSet = true
    }

    /// Change volume
    func setVolume(volume: Float) {
        self.volume = volume
        self.utterance.volume = volume
    }

    /// Change voice
    func setVoice(voice: String) {
        self.voice = voice
        self.utterance.voice = AVSpeechSynthesisVoice(identifier: voice)
        self.language = ""
        self.languageSet = false
    }

    /// Change speed of output
    func setRate(rate: Float) {
        self.rate = rate
        self.utterance.rate = rate
    }
    
    /// Set new utterance with preferences
    private func setUtterance() {
        self.utterance = AVSpeechUtterance(string: content)
        // Set language, voice volume, rate settings again
        if languageSet {
            self.utterance.voice = AVSpeechSynthesisVoice(language: language)
        } else {
            self.utterance.voice = AVSpeechSynthesisVoice(identifier: voice)
        }
        setRate(rate: self.rate)
        setVolume(volume: self.volume)
    }
    
    /// Change message
    func setContent(content: String) {
        self.content = content
        setUtterance()
    }
}
