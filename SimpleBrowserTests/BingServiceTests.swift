//
//  BingServiceTests.swift
//  SimpleBrowserTests
//
//  Created by Weidel, Tyler on 8/6/19.
//  Copyright © 2019 Tyler Weidel. All rights reserved.
//

import XCTest

@testable import SimpleBrowser

class BingServiceTests: XCTestCase {

    func testGetSearchResultReturnsSuccessfully() {

        let query = "TestQuery"
        let jsonData: Data = """
                ["TestQuery",
                    ["Test1",
                    "Test2",
                    "Test3"]]
            """.data(using: .utf8)!

        let componets = URLComponents.buildSearchResult(with: query)
        guard let url = componets.url else {
            XCTFail("URL Components Failed")
            return
        }
        
        URLProtocolMock.testURLs = [url: jsonData]

        // Set up a configuration to use our mock
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolMock.self]
        
        // Create the URLSession with the mock config
        let mockSession = URLSession(configuration: config)
        // Initialize BingService using dependency injection to insert the mock session
        let bingService = BingService(urlSession: mockSession)

        let expectation = XCTestExpectation(description: "Download and successfully decode test data")

        bingService.getSearchResults(using: query) { (result) in
            if let searchResult = try? result.get() {
                let expectedResult = SearchResult(query: "TestQuery", results: ["Test1","Test2","Test3"])
                XCTAssertEqual(searchResult, expectedResult)
            } else {
                XCTFail()
            }
            
            expectation.fulfill()
        }
    }
    
    func testGetSearchResultReturnsError() {
        // Do not set URLProtocolMock.testData to simulate receiving an error
        
        // now set up a configuration to use our mock
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolMock.self]
        
        // and create the URLSession from that
        let mockSession = URLSession(configuration: config)
        
        let bingService = BingService(urlSession: mockSession)
        
        let expectation = XCTestExpectation(description: "Download no data and get an error")
        
        bingService.getSearchResults(using: "") { (result) in
            var searchResult: SearchResult?
            do {
                searchResult = try result.get()
                XCTFail()
            } catch let error {
                XCTAssertNil(searchResult)
                XCTAssertNotNil(error)
            }

            expectation.fulfill()
        }
    }
}

class URLProtocolMock: URLProtocol {
    // This is the expected test data
    static var testURLs = [URL?: Data]()

    // We want to handle all types of request
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    // Ignore this method; just send back what we were given
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        // If we have a valid URL…
        if let url = request.url {
            // …and if we have test data for that URL…
            if let data = URLProtocolMock.testURLs[url] {
                // …load it immediately.
                self.client?.urlProtocol(self, didLoad: data)
            }
        }

        // And mark that we've finished
        self.client?.urlProtocolDidFinishLoading(self)
    }
    
    // This method is required but doesn't need to do anything
    override func stopLoading() { }
}
