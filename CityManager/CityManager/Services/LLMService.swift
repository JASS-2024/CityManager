//
//  LLMService.swift
//  SwipeFresh
//
//  Created by Julian Kraus on 26.03.24.
//

import Foundation
import SwiftUI


let decoder = JSONDecoder()

protocol LLMServiceProtocol {
    func sendMessage(message: String, username: String) async -> String
}

class MockLLMService: LLMServiceProtocol {
    func sendMessage(message: String, username: String) async -> String {
        return "Response to: " + message
    }
}

class GPTLLMService: LLMServiceProtocol {

    func sendMessage(message: String, username: String) async -> String {
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
    
    let link = "http://192.168.3.250/test"
    
    func printJson<T: Codable>(_ elem: T) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        if let createdJSON = try? encoder.encode(elem) {
            if let jsonString = String(data: createdJSON, encoding: .utf8) {
                print(jsonString)
            } else {
                print("Failed to convert JSON data to string.")
            }
        }
    }

    
    @MainActor
    func sendMessage(message: String, username: String) async -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        var serverMessage = ServerMessage(text: message, username: username)
        
        guard let createdJSON = try? encoder.encode(serverMessage) else {
            print("Failed to create JSON from template")
            return "ERROR"
        }
        let url = URL(string: link)
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = createdJSON
        var result = "ERRORERRORERRORERRORERRORERRORERRORERRORERRORERRORERRORERRORERRORERRORERRORERRORERRORERRORERRORERRORERRORERRORERRORERRORERRORERRORERRORERRORERROR"
        
        do {
            let clock = ContinuousClock()
            var response: URLResponse? = nil
            var data2: Data? = nil
            var time = try await clock.measure {
                (data2, response) = try await URLSession.shared.data(for: request)
            }
            let data = data2!
            print("Time taken: " + time.description)

            if let httpResponse = response as? HTTPURLResponse {
                print("Response status code: \(httpResponse.statusCode)")
                
                // Check if the response indicates success (status code 200-299)
                if (200...299).contains(httpResponse.statusCode) {
                    print("Posting succeeded")
                } else {
                    print("Posting failed with status code: \(httpResponse.statusCode)")
                }
            } else {
                print("No response failed")
            }
            do {
                
                let decodedObject = try decoder.decode(ServerMessage.self, from: data)
                result = decodedObject.text
            } catch {
                print("Decoding failed")
                if let str = String(data: data, encoding: .utf8){
                    print(str)
                }
            }
            return result
        } catch {
            print("Timing failed")
            return "ERROR"
            
        }
    }
    
}
