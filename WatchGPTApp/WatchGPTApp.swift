//
//  Created by Kenny Cason on 3/18/23.
//

import SwiftUI

@main
struct WatchGPTApp: App {
    @StateObject private var openAi = OpenAi()
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

