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
    
    func sendMessage(message: String) async -> String {
        guard let url = URL(string: "https://yourserver.com/api/endpoint") else {
            return "Invalid URL"
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("text/plain", forHTTPHeaderField: "Content-Type")
        request.httpBody = message.data(using: .utf8)
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            if let responseString = String(data: data, encoding: .utf8) {
                return responseString // Return the response string directly
            } else {
                return "Failed to decode response"
            }
        } catch {
            print("Request error: \(error)")
            return "Request error: \(error.localizedDescription)"
        }
    }
}
