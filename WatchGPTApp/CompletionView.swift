//
//  Created by Kenny Cason on 3/18/23.
//
import SwiftUI

struct CompletionView: View {
    @EnvironmentObject var openApi: OpenApi
    
    var body: some View {
        VStack(alignment: .leading) {
            CompletionInputView()
                .environmentObject(openApi)
            
            CompletionHistoryView()
                .environmentObject(openApi)
        }
        .frame(maxWidth: .infinity)
    }
}

struct CompletionInputView: View {
    @EnvironmentObject var openApi: OpenApi
    @State var prompt: String = ""
    @State var isLoading: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            TextField("Ask GPT", text: $prompt)
                .onChange(of: prompt) { newValue in
                    print("prompt: \(prompt)")
                    if !prompt.isEmpty {
                        isLoading = true
                        openApi.completions(
                            prompt: prompt,
                            completion: { completionHistoryRecord in
//                                self.history.insert(completionHistoryRecord, at: 0)
                                self.prompt = ""
                                self.isLoading = false
                            }
                        )
                    }
                }
            
            Group {
                if isLoading {
                    Text("Loading...")
                        .bold()
                }
            }
        }
    }
}

struct CompletionHistoryView: View {
    @EnvironmentObject var openApi: OpenApi
    var body: some View {
        List(openApi.completionHistory) { record in
            CompletionHistoryRecordView(record: record)
        }
        .listStyle(.elliptical)
    }
}

struct CompletionHistoryRecordView: View {
    var record: CompletionHistoryRecord
    var body: some View {
        VStack(alignment: .leading) {
            Text(record.request.prompt)
                .fontWeight(.light)
                .italic()
                .foregroundColor(.white)
            
            Spacer(minLength: 5)
            
            Text(record.response.choices[0].text.trimmingCharacters(in: ["\n", " "]))
                .fixedSize(horizontal: false, vertical: false)
        }
    }
}
