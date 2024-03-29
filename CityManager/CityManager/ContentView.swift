//
//  ContentView.swift
//  CityManager
//
//  Created by Julian Kraus on 26.03.24.
//

import Combine
import SwiftUI
import AVKit

struct ContentView: View {
    @State var messages = DataSourceEmpty.messages
    @State var newMessage: String = "This is a new message"
    @ObservedObject var textToSpeechService = TextToSpeechService()
    @StateObject var speechRecognizer = SpeechRecognizer()
    private var llmService = LLMService()
    @State private var presentAlert = false
    @State private var username: String = ""
    @State private var plate: String = ""
    @State private var intermediatePlate = ""
    @State private var savedMessage: String?

    @State private var isRecording = false
    @State private var isThinking = false
    @State private var gettingLicensePlate = false
    @State private var licensePlateAlert = false
    
   
    
    var body: some View {
        
        VStack {
            PlateHeaderView(plate: plate)
                
            GifImage(talking: textToSpeechService.isSpeaking)
                .cornerRadius(15)
                .padding(.horizontal)
                .animation(.easeInOut(duration: 0.3), value: textToSpeechService.isSpeaking)
            
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
                                    self.newMessage = speechRecognizer.transcript
                                    speechRecognizer.stopTranscribing()
                                    if self.newMessage.isEmpty {
                                        sendMessage(message: "???")
                                        respondToUser(response: "I couldn't understand that, could you please repeat your question?")
                                        return
                                    } else {
                                        sendMessage(message: newMessage)
                                    }
                                    if gettingLicensePlate {
                                        for plate in Utils.plates {
                                            if newMessage.contains(plate) {
                                                savePlate(plate: plate)
                                                return
                                            }
                                        }
                                        for stopWord in Utils.stopWords {
                                            if newMessage.contains(stopWord) {
                                                cancelPlateSelection()
                                                return
                                            }
                                        }
                                        respondToUser(response: "Sorry, I didn't understand that. Would you mind spelling the license plate for me?")
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                            licensePlateAlert = true
                                        }
                                    } else {
                                        postMessage(message: speechRecognizer.transcript)
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
        .overlay(content: {
            if licensePlateAlert {
                ZStack {
                    Rectangle()
                        .fill(Color.gray.tertiary)
                        .ignoresSafeArea()
                    PlateEntryView()
                }
            }
        })
    }
    
    @ViewBuilder
    func PlateEntryView() -> some View {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white) // Adapts to the color scheme
                    .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 10)
                VStack {
                    Text("License Plate")
                        .bold()
                        .padding()
                    TextField("Plate number", text: $intermediatePlate)
                        .textFieldStyle(.roundedBorder)
                        .padding()
                    HStack {
                        
                        Button("Save") {
                            sendMessage(message: intermediatePlate)
                            savePlate(plate: intermediatePlate)
                            licensePlateAlert = false // Dismiss the sheet
                        }
                        .padding()
                        .disabled(!Utils.plates.contains(intermediatePlate))
                        Button(action: {
                            sendMessage(message: "Cancel")
                            cancelPlateSelection()
                            licensePlateAlert = false // Dismiss the sheet
                        }, label: {
                            Text("Cancel")
                                .foregroundColor(.red)
                        })
                        .padding()
                    }
            }
        }            .fixedSize()

    }
    func postMessage(message: String, send: Bool = true) {
        DispatchQueue.main.async {
            Task {
                isThinking = true
                let response = await llmService.sendMessage(message: message, plate: self.plate)
                isThinking = false
                if response == "LICENCEPLATE" {
                    getLicensePlate(originalMessage: message)
                } else {
                   respondToUser(response: response)
                }
            }
        }
    }
    
    func sendMessage(message: String, isCurrentUser: Bool = true) {
        messages.append(Message(content: message, isCurrentUser: isCurrentUser))
    }
    
    func savePlate(plate: String) {
        self.plate = plate
        self.intermediatePlate = ""
        respondToUser(response: "I have saved the license plate " + plate + " for your current session.")
        if let message = savedMessage {
            postMessage(message: message, send: false)
            savedMessage = nil
        }
        self.gettingLicensePlate = false
    }
    
    func cancelPlateSelection() {
        respondToUser(response: "Okay, I will ignore this request. Can I help you with something else?")
        gettingLicensePlate = false
    }
    
    func getLicensePlate(originalMessage: String) {
        gettingLicensePlate = true
        savedMessage = originalMessage
        respondToUser(response: "For this request I need to know in which car you currently are. Could you please tell me your license plate number?")
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

