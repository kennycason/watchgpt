//
//  OpenApi.swift
//  WatchGPTApp
//
//  Created by Kenny Cason on 3/18/23.
//

import SwiftUI
import Foundation
//import Alamofire

struct CompletionRequest: Codable {
    let model: String
    let prompt: String
    let max_tokens: Int
    let temperature: Int
}

struct CompletionResponse: Codable {
    let id: String
    let object: String
    let created: Int64
    let model: String
    let choices: [Choice]
}

struct Choice: Codable {
    let text: String
    let index: Int
}

struct CompletionHistoryRecord: Identifiable {
    let id: String
    let request: CompletionRequest
    let response: CompletionResponse
}

class OpenApi : ObservableObject {
    @Published var apiKey: String = "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"
    @Published var maxTokens = 256
    @Published var model = "text-davinci-003"
    @Published var completionHistory: [CompletionHistoryRecord] = [// [CompletionHistoryRecord]()
        CompletionHistoryRecord(
            id: "1",
            request: CompletionRequest(
                model: "k",
                prompt: "Sample Question",
                max_tokens: 10,
                temperature: 10
            ),
            response: CompletionResponse(
                id: "1",
                object: "o",
                created: 0,
                model: "model",
                choices: [
                    Choice(text: "\n  Sample answer about something random that takes multiple lines", index: 0)
                ]
            )
        ),
        CompletionHistoryRecord(
            id: "1",
            request: CompletionRequest(
                model: "k",
                prompt: "Sample Question test two",
                max_tokens: 10,
                temperature: 10
            ),
            response: CompletionResponse(
                id: "2",
                object: "o",
                created: 0,
                model: "model",
                choices: [
                    Choice(text: "  Sample answer about something random that takes multiple linesdfasdfSample answer about something random that takes multiple line. Sample answer about something random that takes multiple line.", index: 0)
                ]
            )
        )
    ]

    func completions(prompt: String, completion:@escaping (CompletionHistoryRecord) -> ()) {
        let url = URL(string: "https://api.openai.com/v1/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let completionRequest = CompletionRequest(
            model: model,
            prompt: prompt,
            max_tokens: maxTokens,
            temperature: 0
        )
        do {
            let requestJsonData = try JSONEncoder().encode(completionRequest)
            let str = String(data: requestJsonData, encoding: .utf8)!
            print(str)
            request.httpBody = requestJsonData
        } catch {
            print(error)
        }

        URLSession.shared.dataTask(with: request) { data, res, error in
            do {
                if let error = error {
                    print("dataTaskWithURL fail: \(error.localizedDescription)")
                }
                else if let data = data {
                    let completionResponse = try JSONDecoder().decode(CompletionResponse.self, from: data)
                    print(completionResponse)
                    DispatchQueue.main.async {
                        let completionHistoryRecord = CompletionHistoryRecord(
                            id: String(self.completionHistory.count),
                            request: completionRequest,
                            response: completionResponse
                        )
                        self.completionHistory.insert(completionHistoryRecord, at: 0)
                        completion(completionHistoryRecord)
                    }
                }
            } catch {
                print(error)
            }
        }.resume()
    }
    
    func clearCompletionHistory() {
        completionHistory.removeAll()
    }
    
}
