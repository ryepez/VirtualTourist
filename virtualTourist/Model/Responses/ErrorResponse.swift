//
//  ErrorResponse.swift
//  virtualTourist
//
//  Created by Ramon Yepez on 6/19/21.
//

import Foundation

struct ErrorResponse: Codable {
    
    let stat: String
    let code: Int
    let message: String
}


extension ErrorResponse: LocalizedError {
    var errorDescription: String? {
        return message
    }
}
