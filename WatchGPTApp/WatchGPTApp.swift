//
//  Created by Kenny Cason on 3/18/23.
//

import SwiftUI

@main
struct WatchGPTApp: App {
    @StateObject private var openApi = OpenApi()
    var body: some Scene {
        WindowGroup {
            TabView {
                CompletionView()
                    .environmentObject(openApi)
                SettingsView()
                    .environmentObject(openApi)
            }
        }
    }
}

