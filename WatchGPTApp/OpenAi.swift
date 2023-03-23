//
//  OpenAi.swift
//  WatchGPTApp
//
//  Created by Kenny Cason on 3/18/23.
//

import SwiftUI
import Foundation
//import Alamofire

class OpenAi : ObservableObject {
    @Published var apiKey: String = ""
    @Published var maxTokens = 256
    @Published var completionModel = completionModels[0]
    @Published var completionHistory: [CompletionHistoryRecord] = [CompletionHistoryRecord]()
    @Published var chatCompletionModel = chatCompletionModels[0]
    @Published var chatCompletionHistory: [ChatCompletionHistoryRecord] = [ChatCompletionHistoryRecord]()
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }

    func completions(prompt: String, completion:@escaping (CompletionHistoryRecord) -> ()) {
        let url = URL(string: "https://api.openai.com/v1/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let completionRequest = CompletionRequest(
            model: completionModel,
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
    
    func chatCompletions(prompt: String, completion:@escaping (ChatCompletionHistoryRecord) -> ()) {
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let completionRequest = ChatCompletionRequest(
            model: chatCompletionModels[0],
            messages: [
                ChatCompletionMessage(
                    role: "user",
                    content: prompt
                )
            ],
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
                    let completionResponse = try JSONDecoder().decode(ChatCompletionResponse.self, from: data)
                    print(completionResponse)
                    DispatchQueue.main.async {
                        let completionHistoryRecord = ChatCompletionHistoryRecord(
                            id: String(self.chatCompletionHistory.count),
                            request: completionRequest,
                            response: completionResponse
                        )
                        self.chatCompletionHistory.insert(completionHistoryRecord, at: 0)
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
    
    func clearChatCompletionHistory() {
        chatCompletionHistory.removeAll()
    }
    
}


let completionModels = [
    "text-davinci-003"
]

struct CompletionRequest: Codable {
    let model: String
    let prompt: String
    let max_tokens: Int
    let temperature: Float
}


struct CompletionResponse: Codable {
    let id: String
    let object: String
    let created: Int64
    let model: String
    let choices: [CompletionChoice]
}

struct CompletionChoice: Codable {
    let text: String
    let index: Int
}


struct CompletionHistoryRecord: Identifiable {
    let id: String
    let request: CompletionRequest
    let response: CompletionResponse
}


// Chat GPT 3.5

let chatCompletionModels = [
    "gpt-3.5-turbo"
]

struct ChatCompletionRequest: Codable {
    let model: String
    let messages: [ChatCompletionMessage]
    let max_tokens: Int
    let temperature: Float
}
struct ChatCompletionMessage: Codable {
    let role: String // "user"
    let content: String
}


struct ChatCompletionResponse: Codable {
    let id: String
    let object: String
    let created: Int64
    let model: String
    let usage: ChatCompletionUsage
    let choices: [ChatCompletionChoice]
}

struct ChatCompletionUsage: Codable {
    let prompt_tokens: Int
    let completion_tokens: Int
    let total_tokens: Int
}

struct ChatCompletionChoice: Codable {
    let message: ChatCompletionChoiceMessage
    let finish_reason: String // "length"
    let index: Int
}

struct ChatCompletionChoiceMessage: Codable {
    let role: String
    let content: String
}


struct ChatCompletionHistoryRecord: Identifiable {
    let id: String
    let request: ChatCompletionRequest
    let response: ChatCompletionResponse
}
