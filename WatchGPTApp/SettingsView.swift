//
//  SettingsView.swift
//  WatchGPTApp
//
//  Created by Kenny Cason on 3/21/23.
//

import Foundation
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var openAi: OpenAi
    var body: some View {
        ScrollView {
            VStack {
                Text("Settings")
                MaxTokensTextField()
                    .environmentObject(openAi)
                ChatCompletionsModelPicker()
                    .environmentObject(openAi)
                CompletionsModelPicker()
                    .environmentObject(openAi)
                ApiKeyField()
                    .environmentObject(openAi)
                PassChatHistoryField()
                    .environmentObject(openAi)
                CearHistoryButton()
                    .environmentObject(openAi)
            }
        }
    }
}

struct MaxTokensTextField: View {
    @EnvironmentObject var openAi: OpenAi
    
    var body: some View {
        LabeledContent {
            TextField("", value: $openAi.maxTokens, format: .number)
        } label: {
            Text("Max Tokens")
        }
    }
}

struct CompletionsModelPicker: View {
    @EnvironmentObject var openAi: OpenAi
    
    var body: some View {
        LabeledContent {
            Picker("", selection: $openAi.completionModel) {
                ForEach(COMPLETION_MODELS, id: \.self) { model in
                    Text(model)
                }
            }
        } label: {
            Text("GPT3.0 Model")
        }
        .padding(5)
    }
}


struct ChatCompletionsModelPicker: View {
    @EnvironmentObject var openAi: OpenAi
    
    var body: some View {
        LabeledContent {
            Picker("", selection: $openAi.chatCompletionModel) {
                ForEach(CHAT_COMPLETION_MODELS, id: \.self) { model in
                    Text(model)
                }
            }
        } label: {
            Text("GPT3.5 Model")
        }
        .padding(5)
    }
}


struct ApiKeyField: View {
    @EnvironmentObject var openAi: OpenAi
    
    var body: some View {
        LabeledContent {
            TextField("", text: $openAi.apiKey)
        } label: {
            Text("Api Key")
        }
    }
}


struct PassChatHistoryField: View {
    @EnvironmentObject var openAi: OpenAi
    
    var body: some View {
        LabeledContent {
            Toggle("", isOn: $openAi.passChatHistory)
        } label: {
            Text("Pass History")
        }
        .padding(5)
    }
}


struct CearHistoryButton: View {
    @EnvironmentObject var openAi: OpenAi
    
    var body: some View {
        Button {
            openAi.clearCompletionHistory()
            openAi.clearChatCompletionHistory()
        } label: {
            Text("Clear History")
        }
        
    }
}
