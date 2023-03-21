//
//  SettingsView.swift
//  WatchGPTApp
//
//  Created by Kenny Cason on 3/21/23.
//

import Foundation
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var openApi: OpenApi
    var body: some View {
        VStack {
            Text("Settings")
            MaxTokensTextField()
                .environmentObject(openApi)
            ModelTextField()
                .environmentObject(openApi)
            ApiKeyField()
                .environmentObject(openApi)
            CearHistoryButton()
                .environmentObject(openApi)
        }
    }
}

struct MaxTokensTextField: View {
    @EnvironmentObject var openApi: OpenApi
    
    var body: some View {
        TextField("Max Tokens", value: $openApi.maxTokens, format: .number)
    }
}

struct ModelTextField: View {
    @EnvironmentObject var openApi: OpenApi
    
    var body: some View {
        TextField("Model", text: $openApi.model)
    }
}


struct ApiKeyField: View {
    @EnvironmentObject var openApi: OpenApi
    
    var body: some View {
        TextField("Api Key", text: $openApi.apiKey)
    }
}


struct CearHistoryButton: View {
    @EnvironmentObject var openApi: OpenApi
    
    var body: some View {
        Button {
            openApi.clearCompletionHistory()
        } label: {
            Text("Clear History")
        }
        
    }
}
