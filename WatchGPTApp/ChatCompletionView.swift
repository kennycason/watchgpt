//
//  Created by Kenny Cason on 3/18/23.
//
import SwiftUI

struct ChatCompletionView: View {
    @EnvironmentObject var openAi: OpenAi
    
    var body: some View {
        VStack(alignment: .leading) {
            ChatCompletionInputView()
                .environmentObject(openAi)
            
            ChatCompletionHistoryView()
                .environmentObject(openAi)
        }
        .frame(maxWidth: .infinity)
    }
}

struct ChatCompletionInputView: View {
    @EnvironmentObject var openAi: OpenAi
    @State var prompt: String = ""
    @State var isLoading: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            TextField("Ask GPT3.5", text: $prompt)
                .onChange(of: prompt) { newValue in
                    print("prompt: \(prompt)")
                    if !prompt.isEmpty {
                        isLoading = true
                        openAi.chatCompletions(
                            prompt: prompt,
                            completion: { chatCompletionHistoryRecord in
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

struct ChatCompletionHistoryView: View {
    @EnvironmentObject var openAi: OpenAi
    var body: some View {
        List(openAi.chatCompletionHistory) { record in
            ChatCompletionHistoryRecordView(record: record)
        }
        .listStyle(.elliptical)
    }
}

struct ChatCompletionHistoryRecordView: View {
    var record: ChatCompletionHistoryRecord
    var body: some View {
        VStack(alignment: .leading) {
            Text(record.request.messages[0].content)
                .fontWeight(.light)
                .italic()
                .foregroundColor(.white)
            
            Spacer(minLength: 5)
            
            Text(record.response.choices[0].message.content.trimmingCharacters(in: ["\n", " "]))
                .fixedSize(horizontal: false, vertical: false)
        }
    }
}