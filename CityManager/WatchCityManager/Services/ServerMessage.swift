//
//  ServerMessage.swift
//  SwipeFresh
//
//  Created by Julian Kraus on 27.03.24.
//

import Foundation

struct ServerMessage : Codable {
    var text: String
    var plate: String
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.text, forKey: .text)
        try container.encode(self.plate, forKey: .plate)
    }
    
    enum CodingKeys: CodingKey {
        case text
        case plate
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.text = try container.decode(String.self, forKey: .text)
        self.plate = ""
    }
    
    init(text: String, plate: String) {
        self.text = text
        self.plate = plate
    }
}
