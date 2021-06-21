//
//  fotoResponse.swift
//  virtualTourist
//
//  Created by Ramon Yepez on 6/19/21.
//

import Foundation

struct Photos: Codable {
    
    let photos: Result
    
    let stat: String
    
}

struct Result: Codable {
    
    let page: Int
    let pages: Int
    let perpage: Int
    let total: Int
    let photo: [OnePhoto]
}
    
struct OnePhoto: Codable {
    
    let id: String
    let owner: String
    let secret: String
    let server: String
    let farm: Int
    let title: String
    let ispublic: Int
    let isfriend: Int
    let isfamily: Int
    let url_sq: String
    let height_sq: Int
    let width_sq: Int
    
}
