//
//  BingService.swift
//  SimpleBrowser
//
//  Created by Weidel, Tyler on 8/5/19.
//  Copyright © 2019 Tyler Weidel. All rights reserved.
//

import UIKit

class BingService: NSObject {
    
    init(urlSession: URLSession) {
        self.urlSession = urlSession
    }
    
    typealias Handler = (Result<SearchResult, Error>) -> Void
    private let apiURL = "​https://api.bing.com/osjson.aspx"
    
    private var urlSession: URLSession?
    
    func getSearchResults(using query: String, then handler: @escaping Handler) {
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.bing.com"
        components.path = "/osjson.aspx"
        components.queryItems = [
            URLQueryItem(name: "query", value: query),
        ]
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        
        guard let url = components.url else {
            let error = NSError(domain: "Url Components Error", code: 0, userInfo: nil)
            handler(.failure(error))
            return
        }
        
        let request = URLRequest(url: url)

        urlSession?.dataTask(with: request, completionHandler: { (data, response, error) in
            if let error = error {
                handler(.failure(error))
                return
            }
            
            do {
                if let data = data {
                    let searchResult = try JSONDecoder().decode(SearchResult.self, from: data)
                    handler(.success(searchResult))
                }
            } catch let jsonDecodingError {
                handler(.failure(jsonDecodingError))
            }
            
        }).resume()
    }
}
