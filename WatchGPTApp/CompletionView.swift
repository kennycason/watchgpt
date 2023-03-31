//
//  Created by Kenny Cason on 3/18/23.
//
import SwiftUI

struct CompletionView: View {
    @EnvironmentObject var openAi: OpenAi
    
    var body: some View {
        VStack(alignment: .leading) {
            CompletionInputView()
                .environmentObject(openAi)
            
            CompletionHistoryView()
                .environmentObject(openAi)
        }
        .frame(maxWidth: .infinity)
    }
}

struct CompletionInputView: View {
    @EnvironmentObject var openAi: OpenAi
    @State var prompt: String = ""
    @State var isLoading: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            TextField("Ask GPT3.0", text: $prompt)
                .onChange(of: prompt) { newValue in
                    print("prompt: \(prompt)")
                    if !prompt.isEmpty {
                        isLoading = true
                        openAi.completions(
                            prompt: prompt,
                            completion: { completionHistoryRecord in
                                self.prompt = ""
                                self.isLoading = false
                            }
                        )
                    }
                }
            
            if isLoading {
                Group {
                    Text("Loading...")
                        .bold()
                }
            }
            
        }
    }
}

struct CompletionHistoryView: View {
    @EnvironmentObject var openAi: OpenAi
    var body: some View {
        List(openAi.completionHistory) { record in
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
            
            if (record.error != nil) {
                Text(record.error!)
                    .fixedSize(horizontal: false, vertical: false)
                    .foregroundColor(.red)
            }
            else if (record.response != nil) {
                Text(record.response!.choices[0].text.trimmingCharacters(in: ["\n", " "]))
                    .fixedSize(horizontal: false, vertical: false)
            }
        }
    }
}
