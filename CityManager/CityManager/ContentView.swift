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
    @State private var plate: String = ""
    @State private var savedMessage: String?

    @State private var isRecording = false
    @State private var isThinking = false
    @State private var gettingLicensePlate = false
    @State private var licensePlateAlert = false
    
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
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    newMessage = speechRecognizer.transcript
                                    speechRecognizer.stopTranscribing()
                                    if gettingLicensePlate {
                                        for plate in llmService.plates {
                                            if newMessage.contains(plate) {
                                                savePlate(plate: plate)
                                                return
                                            }
                                        }
                                        for stopWord in llmService.stopWords {
                                            if newMessage.contains(stopWord) {
                                                cancelPlateSelection()
                                                return
                                            }
                                        }
                                        respondToUser(response: "Sorry, I didn't understand that. Would you mind spelling the license plate for me?")
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                            licensePlateAlert = true
                                        }
                                    } else {
                                        sendMessage(message: speechRecognizer.transcript)
                                    }
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
                    }
                    .padding(20)
                }
            }
        }
        // Username login
        /*.alert("Login", isPresented: $presentAlert, actions: {
                TextField("Username", text: $username)
            
            Button("Login", action: {}).disabled(username.isEmpty)
            }, message: {
                Text("Please choose your username")
            })*/
        // Licenseplate Allert
        .alert("License plate", isPresented: $licensePlateAlert, actions: {
            Text("License plates I know: " + llmService.plateString)
                TextField("Plate number", text: $plate)
            
            Button("Save", action: {
                savePlate(plate: plate)
            }).disabled(llmService.plates.contains(plate))
            Button("Cancel", action: {
                cancelPlateSelection()
            })
            }, message: {
                Text("Please spell your license plate")
            })
        
        
    }
    
    func sendMessage(message: String) {
        if message.isEmpty {
            return
        }
        //messages.append(Message(content: message, plate, self.plate, isCurrentUser: true))
        DispatchQueue.main.async {
            Task {
                isThinking = true
                let response = await llmService.sendMessage(message: message, username: username)
                if response == "Licenceplate" {
                    getLicensePlate(originalMessage: message)
                } else {
                    isThinking = false
                   respondToUser(response: response)
                }
            }
        }
    }
    
    func savePlate(plate: String) {
        self.plate = plate
        respondToUser(response: "I have saved the license plate " + plate + " for your current session")
        if let message = savedMessage {
            sendMessage(message: message)
        }
        gettingLicensePlate = false
    }
    
    func cancelPlateSelection() {
        respondToUser(response: "Okay, I will ignore this request. Can I help you with something else?")
        gettingLicensePlate = false
    }
    
    func getLicensePlate(originalMessage: String) {
        gettingLicensePlate = true
        respondToUser(response: "Sorry, for this request I need to in which car you currently are. Could you please tell me the license plate?")
    }
    
    func respondToUser(response: String) {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            messages.append(Message(content: response, isCurrentUser: false))
            textToSpeechService.setContent(content: response)
            textToSpeechService.speak()
        }
    }
}

#Preview {
    ContentView()
}

