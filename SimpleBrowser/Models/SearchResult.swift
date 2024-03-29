//
//  SearchResult.swift
//  SimpleBrowser
//
//  Created by Weidel, Tyler on 8/5/19.
//  Copyright © 2019 Tyler Weidel. All rights reserved.
//

import UIKit

struct SearchResult: Codable, Equatable {
    var query: String
    var results: [String]
    
    // Because our expected json has no keys, we have to use a custom init to try to decode the unkeyed values
    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        query = try container.decode(String.self)
        results = try container.decode([String].self)
    }
    
    // Convenience init mostly used for testing purposes.
    init(query: String, results: [String]) {
        self.query = query
        self.results = results
    }
}
