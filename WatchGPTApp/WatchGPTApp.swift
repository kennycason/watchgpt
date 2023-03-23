//
//  Created by Kenny Cason on 3/18/23.
//

import SwiftUI

@main
struct WatchGPTApp: App {
    @StateObject private var openAi = OpenAi(apiKey: "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")
    
    private var testApiKey = getOpenAiKey()
    var body: some Scene {
        WindowGroup {
            TabView {
                ChatCompletionView()
                    .environmentObject(openAi)
                CompletionView()
                    .environmentObject(openAi)
                SettingsView()
                    .environmentObject(openAi)
            }
        }
    }
}

private func getOpenAiKey() -> String {
    guard let infoDictionary: [String: Any] = Bundle.main.infoDictionary else { return "" }
    guard let openApiKey: String = infoDictionary["OPEN_AI_KEY"] as? String else { return "" }
    return openApiKey
}
