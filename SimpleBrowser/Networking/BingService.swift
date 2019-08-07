//
//  BingService.swift
//  SimpleBrowser
//
//  Created by Weidel, Tyler on 8/5/19.
//  Copyright © 2019 Tyler Weidel. All rights reserved.
//

import UIKit

class BingService: NSObject {
    
    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    typealias Handler = (Result<SearchResult, Error>) -> Void
    
    private var urlSession: URLSession?
    private var dataTask: URLSessionDataTask?
    
    private var searchResultsComponents: URLComponents {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.bing.com"
        components.path = "/osjson.aspx"
        return components
    }
    
    func getSearchResults(using query: String, then handler: @escaping Handler) {
                
        dataTask?.cancel()
        
        let components = URLComponents.buildSearchResult(with: query)
        
        guard let url = components.url else {
            let error = NSError(domain: "Url Components Error", code: 0, userInfo: nil)
            handler(.failure(error))
            return
        }
        
        let request = URLRequest(url: url)

        dataTask = urlSession?.dataTask(with: request, completionHandler: { (data, response, error) in
            // if error was from a canceled request, do not call handler
            // because the request was canceled from the user typing before the previous request finished
            if let error = error, error.localizedDescription != "cancelled" {
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
            
        })
        
        dataTask?.resume()
    }
    
}

extension URLComponents {
    static func buildSearchResult(with query: String) -> URLComponents {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.bing.com"
        components.path = "/osjson.aspx"
        components.queryItems = [
            URLQueryItem(name: "query", value: query)
        ]
        // handle plus sign in search results
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        return components
    }
}
