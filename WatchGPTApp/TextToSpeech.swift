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

    func speak(text: String) {
        // Create an utterance.
        let utterance = AVSpeechUtterance(string: text)

        // Configure the utterance.
//                    utterance.rate = 0.57
//                    utterance.pitchMultiplier = 0.8
//                    utterance.postUtteranceDelay = 0.2
//                    utterance.volume = 0.8

        // Retrieve the British English voice.
        let voice = AVSpeechSynthesisVoice(language: "en-US")

        // Assign the voice to the utterance.
        utterance.voice = voice
        
        synthesizer.speak(utterance)
    }
}
