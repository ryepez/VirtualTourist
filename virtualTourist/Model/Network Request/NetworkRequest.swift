//
//  NetworkRequest.swift
//  virtualTourist
//
//  Created by Ramon Yepez on 6/18/21.
//

import Foundation
import UIKit

class NetworkRequests {
    
    
    struct Auth {
        //add your own API key here from flickr 
        static var apiKey = "API goes here"
    }
    
    enum Endpoints {
        static let base = "https://www.flickr.com/services/rest/?method="
        
        case getPictureOneMileRadius(String, String, String)
        
        var stringValue: String {
            switch self {
            
            case .getPictureOneMileRadius(let lat, let lon, let pageNumber):
                return Endpoints.base + "flickr.photos.search&api_key=\(Auth.apiKey)&lat=\(lat)&lon=\(lon)&radius=1&radius_units=mi&per_page=10&page=\(pageNumber)&format=json&nojsoncallback=1&extras=url_sq"
                
            }
            
        }
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    class func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) {
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                do {
                    let errorResponse = try decoder.decode(ErrorResponse.self, from: data)
                    
                    DispatchQueue.main.async {
                        completion(nil,errorResponse)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
                
            }
            
        }
        task.resume()
    }
    
    
    class func getFotoLocation(url: URL, completion: @escaping ([OnePhoto], Error?) -> Void){
        
        taskForGETRequest(url: url, responseType: Photos.self) { (response, error) in
            
            if let response = response {
                completion(response.photos.photo, nil)
            } else {
                completion([], nil)
            }
        }
    }
    
    class func imageRequest(url: URL, completionHandler: @escaping (Data?, Error?) -> Void){
        let task = URLSession.shared.downloadTask(with: url) {(location, response, error) in
            guard let location = location else {
                completionHandler(nil, error)
                return
            }
            
            let imageData = try! Data(contentsOf: location)
            completionHandler(imageData, nil)
            
        }
        task.resume()
        
        
    }
    
    
}

