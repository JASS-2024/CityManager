//
//  LLMService.swift
//  SwipeFresh
//
//  Created by Julian Kraus on 26.03.24.
//

import Foundation
import SwiftUI

protocol LLMServiceProtocol {
    func sendMessage(message: String) async -> String
}

class MockLLMService: LLMServiceProtocol {
    func sendMessage(message: String) async -> String {
        return "Response to: " + message
    }
}

class GPTLLMService: LLMServiceProtocol {

    func sendMessage(message: String) async -> String {
        let apiKey = ""
        let modelName = "gpt-4"
        
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: Any] = [
            "model": modelName,
            "messages": [
                ["role": "system", "content": "Provide really concise answers to any questions."],
                ["role": "user", "content": message],
            ]
        ]
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
            return "Error: Could not encode parameters."
        }
        
        request.httpBody = httpBody
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let choices = jsonResponse["choices"] as? [[String: Any]],
               let message = choices.first?["message"] as? [String: Any],
               let content = message["content"] as? String {
                return content
            } else {
                return "Error: Invalid response format."
            }
        } catch {
            return "Error: \(error.localizedDescription)"
        }
    }

    
}
    

class LLMService: LLMServiceProtocol {
    
    @MainActor
    func sendMessage(message: String) async -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        var serverMessage = ServerMessage(text: message)
        
        guard let createdJSON = try? encoder.encode(serverMessage) else {
            print("Failed to create JSON from template")
            return "ERROR"
        }
        let url = URL(string: "http://192.168.3.75/request")
        
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = createdJSON
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Response status code: \(httpResponse.statusCode)")
                
                // Check if the response indicates success (status code 200-299)
                if (200...299).contains(httpResponse.statusCode) {
                    print("Posting succeeded")
                } else {
                    print(Thread.callStackSymbols)
                    print("Posting failed with status code: \(httpResponse.statusCode)")
                    return "ERROR"
                }
            } else {
                print("1")
                return "ERROR"
            }
            do {
                let decoder = JSONDecoder()
                let decodedObject = try decoder.decode(ServerMessage.self, from: data)
                //printJson(decodedObject)
                return decodedObject.text
            } catch {
                print("2")
                return "ERROR"
            }
        } catch {
            print("3")
            return "ERROR"
            
        }
    }
}
