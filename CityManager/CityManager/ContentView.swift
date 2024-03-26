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
                    Button(action: sendMessage)   {
                        Image(systemName: "mic")
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
        }
        
        
        
    }
    
    func sendMessage() {
        
        if !newMessage.isEmpty{
            messages.append(Message(content: newMessage, isCurrentUser: true))
            var systemMessage = "Reply of " + newMessage
            messages.append(Message(content: systemMessage, isCurrentUser: false))
            //Text to Speech usage
            textToSpeechService.setContent(content: systemMessage)
            textToSpeechService.speak()
            
            newMessage = "This is a new message"
        }
    }
}

#Preview {
    ContentView()
}

