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
    
    @Published var completionModel = COMPLETION_MODEL_DEFAULT
    @Published var completionHistory: [CompletionHistoryRecord] = [CompletionHistoryRecord]()
    
    @Published var passChatHistory = true
    @Published var chatCompletionModel = CHAT_COMPLETION_MODEL_DEFAULT
    @Published var chatCompletionHistory: [ChatCompletionHistoryRecord] = [ChatCompletionHistoryRecord]()
    
    init(apiKey: String,
         chatCompletionModel: String = CHAT_COMPLETION_MODEL_DEFAULT,
         completionModel: String = COMPLETION_MODEL_DEFAULT
    ) {
        self.apiKey = apiKey
        self.chatCompletionModel = chatCompletionModel
        self.completionModel = completionModel
    }
    
    func completions(prompt: String, completion:@escaping (CompletionHistoryRecord?) -> ()) {
        let completionRequest = CompletionRequest(
            model: completionModel,
            prompt: prompt,
            max_tokens: maxTokens,
            temperature: 0
        )
        
        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/completions")!)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = toJsonData(encodable: completionRequest)
        
        AF
            .request(request)
            .responseData { (response: AFDataResponse<Data>) in
                switch response.result {
                case .failure(let error):
                    print(error)
                case .success(let data):
                    let historyRecord = self.buildCompletionHistory(
                        request: completionRequest,
                        response: response,
                        data: data,
                        error: nil
                    )
                    self.completionHistory.insert(historyRecord, at: 0)
                    completion(historyRecord)
                }
            }
    }
    
    func chatCompletions(prompt: String, completion:@escaping (ChatCompletionHistoryRecord?) -> ()) {
        let completionRequest = ChatCompletionRequest(
            model: chatCompletionModel,
            messages: buildChatMessageHistory(prompt: prompt),
            max_tokens: maxTokens,
            temperature: 0
        )
        print(completionRequest)
        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = toJsonData(encodable: completionRequest)
        
        AF
            .request(request)
            .responseData { (response: AFDataResponse<Data>) in
                switch response.result {
                case .failure(let error):
                    print(error)
                case .success(let data):
                    let historyRecord = self.buildChatCompletionHistory(
                        request: completionRequest,
                        response: response,
                        data: data,
                        error: nil
                    )
                    self.chatCompletionHistory.insert(historyRecord, at: 0)
                    completion(historyRecord)
                }
            }
    }
    
    private func buildChatMessageHistory(prompt: String) -> [ChatCompletionMessage] {
        if self.passChatHistory{
            var history: [ChatCompletionMessage] = self.chatCompletionHistory
                .reversed()
                .filter({ record in
                    record.request.messages.count > 0 && record.response != nil && record.response!.choices.count > 0
                })
                .flatMap({ record in
                [
                    ChatCompletionMessage(
                        role: record.request.messages.last!.role,
                        content: record.request.messages.last!.content
                    ),
                    ChatCompletionMessage(
                        role: record.response!.choices.last!.message.role,
                        content: record.response!.choices.last!.message.content
                    )
                ]
            })
            history.append(
                ChatCompletionMessage(
                    role: "user",
                    content: prompt
                )
            )
            return history
        }
        return [
            ChatCompletionMessage(
                role: "user",
                content: prompt
            )
        ]
    }
    
    private func buildCompletionHistory(
        request: CompletionRequest,
        response: AFDataResponse<Data>,
        data: Data?,
        error: Error?
    ) -> CompletionHistoryRecord {
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
            if response.response?.statusCode == 401 {
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
                return CompletionHistoryRecord(
                    id: String(self.completionHistory.count),
                    request: request,
                    response: nil,
                    error: error.localizedDescription
                )
            }
        }
        return CompletionHistoryRecord(
            id: String(self.completionHistory.count),
            request: request,
            response: nil,
            error: "Unknown Error"
        )
    }
    
    private func buildChatCompletionHistory(
        request: ChatCompletionRequest,
        response: AFDataResponse<Data>,
        data: Data?,
        error: Error?
    ) -> ChatCompletionHistoryRecord {
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
            if response.response?.statusCode == 401 {
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
                return ChatCompletionHistoryRecord(
                    id: String(self.chatCompletionHistory.count),
                    request: request,
                    response: nil,
                    error: error.localizedDescription
                )
            }
        }
        return ChatCompletionHistoryRecord(
            id: String(self.chatCompletionHistory.count),
            request: request,
            response: nil,
            error: "Unknown Error"
        )
    }
    
    func clearCompletionHistory() {
        completionHistory.removeAll()
    }
    
    func clearChatCompletionHistory() {
        chatCompletionHistory.removeAll()
    }
    
    private func toJsonData(encodable: Encodable) -> Data {
        return toJson(encodable: encodable).data(using: .utf8)!
    }
    
    private func toJson(encodable: Encodable) -> String {
        do {
            let json = try JSONEncoder().encode(encodable)
            return String(data: json, encoding: .utf8)!
        } catch {
            return ""
        }
    }
    
}

let CHAT_COMPLETION_MODEL_DEFAULT = "gpt-3.5-turbo"
let CHAT_COMPLETION_MODELS = [
    "gpt-4",
    "gpt-4-0314",
    "gpt-4-32k",
    "gpt-4-32k-0314",
    "gpt-3.5-turbo",
    "gpt-3.5-turbo-0301"
]
let COMPLETION_MODEL_DEFAULT = "text-davinci-003"
let COMPLETION_MODELS = [
    "text-davinci-003",
    "text-davinci-002",
    "text-curie-001",
    "text-babbage-001",
    "text-ada-001",
    "davinci",
    "curie",
    "babbage",
    "ada"
]


// Chat GPT 3.0
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
