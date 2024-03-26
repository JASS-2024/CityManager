//
//  LLMService.swift
//  SwipeFresh
//
//  Created by Julian Kraus on 26.03.24.
//

import Foundation

protocol LLMServiceProtocol {
    func sendMessage(message: String) async -> String
}

class MockLLMService: LLMServiceProtocol {
    func sendMessage(message: String) async -> String {
        return "Response to: " + message
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
