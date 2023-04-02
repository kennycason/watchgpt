//
//  Created by Kenny Cason on 3/18/23.
//
import SwiftUI
import AVFoundation

struct ChatCompletionView: View {
    @EnvironmentObject var openAi: OpenAi
    private let textToSpeech = TextToSpeech()
    
    var body: some View {
        VStack(alignment: .leading) {
            ChatCompletionInputView()
                .environmentObject(openAi)
            
            ChatCompletionHistoryView(textToSpeech: textToSpeech)
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
            TextField("Chat w/ GPT3.5+", text: $prompt)
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
            
            
            if isLoading {
                Group {
                    Text("Loading...")
                        .bold()
                }
            }
        }
    }
}

struct ChatCompletionHistoryView: View {
    let textToSpeech: TextToSpeech
    @EnvironmentObject var openAi: OpenAi
    
    var body: some View {
        List(openAi.chatCompletionHistory) { record in
            ChatCompletionHistoryRecordView(
                record: record,
                textToSpeech: textToSpeech
            )
        }
        .listStyle(.elliptical)
    }
}

struct ChatCompletionHistoryRecordView: View {
    let record: ChatCompletionHistoryRecord
    let textToSpeech: TextToSpeech
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(record.request.messages.last!.content)
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
                VStack(alignment: .leading) {
                    Text(record.response!.choices[0].message.content.trimmingCharacters(in: ["\n", " "]))
                        .fixedSize(horizontal: false, vertical: false)
                    HStack {
                        Button(action: {
                            if (!textToSpeech.isSpeaking()) {
                                textToSpeech.speak(text: record.response!.choices[0].message.content)
                            }
                        }) {
                            Text("🔊")
                                .padding()
                                .cornerRadius(5)
                        }
                        .buttonStyle(.borderless)
                        Spacer()
                        Button(action: {
                            textToSpeech.stopSpeaking()
                        }) {
                            Text("🔇")
                                .padding()
                                .cornerRadius(5)
                        }
                        .buttonStyle(.borderless)
                    }
                }
            }
        }
    }
}
