//
//  TextToSpeech.swift
//  WatchGPTApp
//
//  Created by Kenny Cason on 3/31/23.
//

import Foundation
import AVFoundation

class TextToSpeech {
    private let synthesizer: AVSpeechSynthesizer = AVSpeechSynthesizer()
    
    init() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)
         }
        catch {
            print("Fail to enable AVAudioSession")
        }
    }
    
    func stopSpeaking() {
        if (isSpeaking()) {
            synthesizer.stopSpeaking(at: .immediate)
        }
    }

    func isSpeaking() -> Bool {
        return synthesizer.isSpeaking
    }
    
    func speak(text: String) {
        let utterance = AVSpeechUtterance(string: text)
//        utterance.rate = 0.57
//        utterance.pitchMultiplier = 0.8
//        utterance.postUtteranceDelay = 0.2
        utterance.volume = 1.0

        let languageDetector = LanguageDetector()
        let language = languageDetector.detect(text: text)
        let voice = AVSpeechSynthesisVoice(language: language)
        utterance.voice = voice
        
        synthesizer.speak(utterance)
    }
}
