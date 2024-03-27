//
//  ContentView.swift
//  CityManager
//
//  Created by Julian Kraus on 26.03.24.
//

import Combine
import SwiftUI

struct ContentView: View {
    @State var messages = DataSourceEmpty.messages
    @State var newMessage: String = "This is a new message"
    private var textToSpeechService = TextToSpeechService()
    @StateObject var speechRecognizer = SpeechRecognizer()
    private var llmService = GPTLLMService()

    @State private var isRecording = false
    @State private var isThinking = false
    
    var body: some View {
        
            VStack {
                ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack {
                        ForEach(messages, id: \.self) { message in
                            MessageView(currentMessage: message)
                                .id(message)
                        }
                    }
                    .onReceive(Just(messages)) { _ in
                        withAnimation {
                            proxy.scrollTo(messages.last, anchor: .bottom)
                        }
                        
                    }.onAppear {
                        withAnimation {
                            proxy.scrollTo(messages.last, anchor: .bottom)
                        }
                    }
                }
                
                // send new message
                HStack {
                    
                    Button(action: {
                        if isRecording {
                            isRecording = false
                            newMessage = speechRecognizer.transcript
                            speechRecognizer.stopTranscribing()
                            sendMessage(message: speechRecognizer.transcript)
                        } else {
                            isRecording = true
                            speechRecognizer.resetTranscript()
                            speechRecognizer.startTranscribing()
                        }
                    }, label: {
                        if isRecording {
                            Image(systemName: "mic.fill")
                        } else if isThinking {
                            LoadingButtonView()
                        } else {
                            Image(systemName: "mic")
                        }
                        
                    })
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
        }
        
        
        
    }
    
    func sendMessage(message: String) {
        
            messages.append(Message(content: message, isCurrentUser: true))
            DispatchQueue.main.async {
                Task {
                    isThinking = true
                    var response = await llmService.sendMessage(message: message)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        messages.append(Message(content: response, isCurrentUser: false))
                        //Text to Speech usage
                        textToSpeechService.setContent(content: response)
                        textToSpeechService.speak()
                        isThinking = false
                    }
                }
        }
    }
}

#Preview {
    ContentView()
}

