//
//  LanguageDetector.swift
//  WatchGPTApp
//
//  Created by Kenny Cason on 3/31/23.
//

import Foundation


import NaturalLanguage

class LanguageDetector {
    let codes: [String: String] = [
        "es": "es-ES",
        "en": "en-US",
        "fr": "fr-FR",
        "it": "it-IT",
        "ja": "ja-JP",
        "ko": "ko-KR",
        "zh": "zh-CN",
    ]
    func detect(text: String) -> String {
        let languageRecognizer = NLLanguageRecognizer()
        languageRecognizer.processString(text)
        if let dominantLanguage = languageRecognizer.dominantLanguage {
            if codes.keys.contains(dominantLanguage.rawValue) {
                return codes[dominantLanguage.rawValue]!
            }
            return dominantLanguage.rawValue
        }
        return "en-US"
    }
}
