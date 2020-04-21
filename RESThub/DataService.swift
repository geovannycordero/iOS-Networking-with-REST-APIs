//
//  DataService.swift
//  RESThub
//
//  Created by Geovanny Cordero on 4/20/20.
//  Copyright © 2020 Harrison. All rights reserved.
//

import Foundation

class DataService {
    static let shared = DataService()
    
    // fileprivate let baseURLString = "https://api.github.com"
    
    func fetchGists(completion: @escaping (Result<[Gist], Error>) -> Void) {
        // var baseURL = URL(string: baseURLString)
        // baseURL?.appendPathComponent("/somePath")
        // let compusedURL = URL(string: "/somePath", relativeTo: baseURL)
        // print("url: \(String(describing: baseURL))")
        // print("\(compusedURL?.absoluteString ?? "Relative url failed...")")
        
        var componetURL = URLComponents()
        componetURL.scheme = "https"
        componetURL.host = "api.github.com"
        componetURL.path = "/gists/public"
        // print(componetURL.url!)
        
        guard let validURL = componetURL.url else {
            print("URL creation failed")
            return
        }
        
        URLSession.shared.dataTask(with: validURL) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                print("API status: \(httpResponse.statusCode)")
            }
            
            guard let validData = data, error == nil else {
                completion(.failure(error!))
                return
            }
            
            do {
               // let json = try JSONSerialization.jsonObject(with: validData, options: [])
                let gists = try JSONDecoder().decode([Gist].self, from: validData)
                completion(.success(gists))
            } catch let serializationError {
                completion(.failure(serializationError))
            }
        }.resume()
    }
    
    
    func createNewGist(completion: @escaping (Result<Any, Error>) -> Void) {
        let postComponents = createURLComponents(path: "/gists")
        
        guard let composedURL = postComponents.url else {
            print("Url creation failed...")
            return
        }
        
        var postRequest = URLRequest(url: composedURL)
        postRequest.httpMethod = "POST"
        
        let authString = "username:password"
        var authStringBase64 = ""
        
        if let authData = authString.data(using: .utf8) {
            authStringBase64 = authData.base64EncodedString()
        }
        
        postRequest.setValue("Basic \(authStringBase64)", forHTTPHeaderField: "Authorization")
        postRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        postRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let newGist = Gist(id: nil, isPublic: true, description: "A brand new gist", files: ["test_file.txt": File(content: "Hello World!")])
        
        do {
            let gistData = try JSONEncoder().encode(newGist)
            postRequest.httpBody = gistData
        } catch {
            print("Gist encoding failed...")
        }
        
        URLSession.shared.dataTask(with: postRequest) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                print("Status code: \(httpResponse.statusCode)")
                
                guard let validData = data, error == nil else {
                    completion(.failure(error!))
                    return
                }
                
                do {
                    let json = try JSONSerialization.jsonObject(with: validData, options: [])
                    completion(.success(json))
                } catch let serializationError {
                    completion(.failure(serializationError))
                }
            }
        }.resume()
    }
    
    func createURLComponents(path: String) -> URLComponents {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.github.com"
        components.path = path
        
        return components
    }
}


struct File: Codable {
    var content: String?
}
