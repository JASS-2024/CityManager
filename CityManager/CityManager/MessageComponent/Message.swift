//
//  Message.swift
//  SwipeFresh
//
//  Created by Aleksandra Topalova on 26.03.24.
//

import Foundation
import SwiftUI

struct Message: Hashable {
    var id = UUID()
    var content: String
    var isCurrentUser: Bool
    var plate: String?
}

struct DataSourceWithSamples {
    
    static let messages = [
        
        Message(content: "Hi there!", isCurrentUser: true),
        
        Message(content: "Hello! How can I assist you today?", isCurrentUser: false),
        Message(content: "How are you doing?", isCurrentUser: true),
        Message(content: "I'm just a computer program, so I don't have feelings, but I'm here and ready to help you with any questions or tasks you have. How can I assist you today?", isCurrentUser: false),
        Message(content: "Tell me a joke.", isCurrentUser: true),
        Message(content: "Certainly! Here's one for you: Why don't scientists trust atoms? Because they make up everything!", isCurrentUser: false),
        Message(content: "How far away is the Moon from the Earth?", isCurrentUser: true),
        Message(content: "The average distance from the Moon to the Earth is about 238,855 miles (384,400 kilometers). This distance can vary slightly because the Moon follows an elliptical orbit around the Earth, but the figure I mentioned is the average distance.", isCurrentUser: false)
      
    ]
}

class StateData: ObservableObject {
    static let shared = StateData()
    private init(){}
    
    @Published var messages: [Message] = []
    @Published var plate: String = ""
    @Published var apnsToken: String = ""
    @Published var hasSentTokenToServer = false
    
    struct TokenPayload: Codable{
        let plate: String
        let token: String
        
    }
    func sendTokenToServer(payload: TokenPayload)async{
        let data = try! encoder.encode(payload)
        let url = URL(string: "http://\(Utils.LOCAL_CITY_SERVER_IP):8080/token")!
        var r: URLRequest = .init(url: url)
        r.httpMethod = "POST"
        r.httpBody = data
        r.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (_, resp) = try! await URLSession.shared.data(for: r)
        let httpResp = resp as! HTTPURLResponse
        assert (httpResp.statusCode >= 200 && httpResp.statusCode < 300)
        print("Sent token to server.")
    }
//    We can easily call this whenver we get the license plate or the token without doing any checking :p
    func sendTokenToServerIfPossible()async{
        guard let payload = hasTokenPayloadToSendToServer() else{
            print("Can't send token to server yet.")
            return
        }
        await sendTokenToServer(payload: payload)
    }
    func hasTokenPayloadToSendToServer() -> TokenPayload? {
        if apnsToken != "" && plate != ""{
            return .init(plate: plate, token: apnsToken)
        }
        return nil
    }

    //    in our case, this is logic to speak the message. set by the ContentView on app launch.
    var logicAfterReceivingMessageFromApollo: (String)->() = {_ in
        print("[EXTRA LOGIC DEFAULT!!!]")
    }
    
    func addNewMessageThreadSafe(_ m: Message, doExtraLogic: Bool = false){
        DispatchQueue.main.async{
            withAnimation{
                self.messages.append(m)
                if doExtraLogic{
                    self.logicAfterReceivingMessageFromApollo(m.content)
                }
            }
        }
    }
    
}



