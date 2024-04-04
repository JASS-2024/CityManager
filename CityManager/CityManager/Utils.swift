//
//  Utils.swift
//  SwipeFresh
//
//  Created by Julian Kraus on 28.03.24.
//

import Foundation


class Utils {
//    static let LOCAL_CITY_SERVER_IP = "192.168.3.250"
    static let LOCAL_CITY_SERVER_IP = "192.168.1.13"
    static let link = "http://\(LOCAL_CITY_SERVER_IP):8080/request"//"http://192.168.3.250/test"
    
    static let plates = ["ABC123",
                         "ABC133",
                         "BBA123",
                         "BBA133",
                         "CBC123"]
    
    static let stopWords = ["cancel", "terminate", "abort", "halt", "stop", "end", "cease", "discontinue", "suspend", "quit", "not", "don't", "never"]
}
