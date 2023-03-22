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
        VStack {
            Text("Settings")
            MaxTokensTextField()
                .environmentObject(openAi)
            ModelTextField()
                .environmentObject(openAi)
            ApiKeyField()
                .environmentObject(openAi)
            CearHistoryButton()
                .environmentObject(openAi)
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

struct ModelTextField: View {
    @EnvironmentObject var openAi: OpenAi
    var body: some View {
        //        NavigationView {
        //            Form {
        
//        Picker("", selection: $openAi.model) {
//            ForEach(models, id: \.self) { model in
//                Text(model)
//
//            }
//        }
        
        LabeledContent {
            TextField("", text: $openAi.completionModel)
        } label: {
            Text("Model")
        }
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
