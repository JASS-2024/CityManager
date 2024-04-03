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
    var id: String
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.text, forKey: .text)
        try container.encode(self.plate, forKey: .plate)
        try container.encode(self.id, forKey: .id)
    }
    
    enum CodingKeys: CodingKey {
        case text
        case plate
        case id
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.text = try container.decode(String.self, forKey: .text)
        self.plate = ""
        self.id = ""
    }
    
    init(text: String, plate: String, id: String) {
        self.text = text
        self.plate = plate
        self.id = id
    }
}
