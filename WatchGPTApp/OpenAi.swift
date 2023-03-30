//
//  OpenAi.swift
//  WatchGPTApp
//
//  Created by Kenny Cason on 3/18/23.
//

import SwiftUI
import Foundation
import Alamofire

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
    
    func completions(prompt: String, completion:@escaping (CompletionHistoryRecord?) -> ()) {
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
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            let historyRecord = self.buildCompletionHistory(request: completionRequest, response: response, data: data, error: error)
            if historyRecord != nil {
                self.completionHistory.insert(historyRecord!, at: 0)
            }
            completion(historyRecord)
        }
        .resume()
    }
    
    func chatCompletions(prompt: String, completion:@escaping (ChatCompletionHistoryRecord?) -> ()) {
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
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            let historyRecord = self.buildChatCompletionHistory(request: completionRequest, response: response, data: data, error: error)
            if historyRecord != nil {
                self.chatCompletionHistory.insert(historyRecord!, at: 0)
            }
            completion(historyRecord)
        }
        .resume()
    }
    
    private func buildCompletionHistory(
        request: CompletionRequest,
        response: URLResponse?,
        data: Data?,
        error: Error?
    ) -> CompletionHistoryRecord? {
        if let error = error {
            print("dataTaskWithURL fail: \(error.localizedDescription)")
            return CompletionHistoryRecord(
                id: String(self.completionHistory.count),
                request: request,
                response: nil,
                error: error.localizedDescription
            )
        }
        else if let data = data {
            if (response as! HTTPURLResponse).statusCode == 401 {
                return CompletionHistoryRecord(
                    id: String(self.completionHistory.count),
                    request: request,
                    response: nil,
                    error: "Bad Token"
                )
            }
            do {
                let completionResponse = try JSONDecoder().decode(CompletionResponse.self, from: data)
                print(completionResponse)
                return CompletionHistoryRecord(
                    id: String(self.completionHistory.count),
                    request: request,
                    response: completionResponse,
                    error: nil
                )
            } catch {
                print(error)
            }
        }
        return nil
    }
    
    private func buildChatCompletionHistory(
        request: ChatCompletionRequest,
        response: URLResponse?,
        data: Data?,
        error: Error?
    ) -> ChatCompletionHistoryRecord? {
        if let error = error {
            print("dataTaskWithURL fail: \(error.localizedDescription)")
            return ChatCompletionHistoryRecord(
                id: String(self.chatCompletionHistory.count),
                request: request,
                response: nil,
                error: error.localizedDescription
            )
        }
        else if let data = data {
            if (response as! HTTPURLResponse).statusCode == 401 {
                return ChatCompletionHistoryRecord(
                    id: String(self.chatCompletionHistory.count),
                    request: request,
                    response: nil,
                    error: "Bad Token"
                )
            }
            do {
                let completionResponse = try JSONDecoder().decode(ChatCompletionResponse.self, from: data)
                print(completionResponse)
                return ChatCompletionHistoryRecord(
                    id: String(self.chatCompletionHistory.count),
                    request: request,
                    response: completionResponse,
                    error: nil
                )
            } catch {
                print(error)
            }
        }
        return nil
    }
    
    func clearCompletionHistory() {
        completionHistory.removeAll()
    }
    
    func clearChatCompletionHistory() {
        chatCompletionHistory.removeAll()
    }
    
}

let chatCompletionModels = [
    "gpt-3.5-turbo"
]
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
    let response: CompletionResponse?
    let error: String?
}


// Chat GPT 3.5
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
    let response: ChatCompletionResponse?
    let error: String?
}
