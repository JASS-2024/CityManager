//
//  ServerMessage.swift
//  SwipeFresh
//
//  Created by Julian Kraus on 27.03.24.
//

import Foundation

struct ServerMessage : Codable {
    var text: String
    var username: String
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.text, forKey: .text)
        try container.encode(self.username, forKey: .username)
    }
    
    enum CodingKeys: CodingKey {
        case text
        case username
    }
    init(text: String, username: String) {
        self.text = text
        self.username = username
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.text = try container.decode(String.self, forKey: .text)
        self.username = ""
    }
}
