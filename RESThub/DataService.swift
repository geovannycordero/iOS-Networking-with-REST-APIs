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
    
    fileprivate let baseURLString = "https://api.github.com"
    
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
}
