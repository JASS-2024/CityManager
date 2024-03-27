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
    private var llmService = LLMService()
    @State private var presentAlert = true
    @State private var username: String = ""

    @State private var isRecording = false
    @State private var isThinking = false
    
    var body: some View {
        
        VStack {
            if !presentAlert {
            UsernameHeaderView(username: username)
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
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                newMessage = speechRecognizer.transcript
                                speechRecognizer.stopTranscribing()
                                sendMessage(message: speechRecognizer.transcript)
                            }
                        } else {
                            isRecording = true
                            textToSpeechService.stopSpeaking()
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
                    .foregroundColor(.white)
                    .disabled(isThinking)
                    .imageScale(.large)
                    .background(content: {
                        RoundedRectangle(cornerSize: CGSize(width: 5, height: 5))
                            .frame(width: 50, height: 50)
                            .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                    })
                    
                   // .buttonStyle(.borderedProminent)
                }
                .padding(20)
            }
        }
        }
        // Username login
        .alert("Login", isPresented: $presentAlert, actions: {
                TextField("Username", text: $username)
            
            Button("Login", action: {}).disabled(username.isEmpty)
            }, message: {
                Text("Please choose your username")
            })
        
        
    }
    
    func sendMessage(message: String) {
            messages.append(Message(content: message, isCurrentUser: true))
            DispatchQueue.main.async {
                Task {
                    isThinking = true
                    var response = await llmService.sendMessage(message: message, username: username)
                    DispatchQueue.main.asyncAfter(deadline: .now()) {
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

