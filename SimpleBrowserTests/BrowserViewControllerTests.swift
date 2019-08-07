//
//  BrowserViewControllerTests.swift
//  SimpleBrowserTests
//
//  Created by Weidel, Tyler on 8/6/19.
//  Copyright © 2019 Tyler Weidel. All rights reserved.
//

import XCTest
import WebKit

@testable import SimpleBrowser

class BrowserViewControllerTests: XCTestCase {
    
    var browserVC: BrowserViewController!

    override func setUp() {
        browserVC = BrowserViewController.mocked
    }

    func testInitialState() {
        XCTAssertTrue(browserVC.searchResultsView.isHidden)
        XCTAssertEqual(browserVC.searchField.text, "")
    }
    
    func testSearchResultsShow() {
        _ = browserVC.searchField.delegate?.textField?(browserVC.searchField, shouldChangeCharactersIn: NSRange(location: 0, length: 0), replacementString: "Test")
        XCTAssertFalse(browserVC.searchResultsView.isHidden)
    }
    
    func testSearchResultsHideWhenNoTextIsLeft() {
        _ = browserVC.searchField.delegate?.textField?(browserVC.searchField, shouldChangeCharactersIn: NSRange(location: 0, length: 0), replacementString: "Test")
        _ = browserVC.searchField.delegate?.textField?(browserVC.searchField, shouldChangeCharactersIn: NSRange(location: 0, length: 0), replacementString: "")
        XCTAssertTrue(browserVC.searchResultsView.isHidden)
    }
    
    func testSearchResultsShowWhenEditingSearchField() {
        browserVC.searchField.delegate?.textFieldDidBeginEditing?(browserVC.searchField)
        XCTAssertFalse(browserVC.searchResultsView.isHidden)
    }
    
    func testSearchResultsHideWhenSearchFieldIsCleared() {
        _ = browserVC.searchField.delegate?.textFieldShouldClear?(browserVC.searchField)
        XCTAssertTrue(browserVC.searchResultsView.isHidden)
    }
    
    func testSearchResultsClearDataWhenSearchFieldIsCleared() {
        _ = browserVC.searchField.delegate?.textFieldShouldClear?(browserVC.searchField)
        XCTAssertNil(browserVC.searchResultsTableViewController?.searchResult)
    }
    
    func testWebViewLoadsCorrectURLFromQueryString() {
        browserVC.searchField.text = "Test Test"
        _ = browserVC.searchField.delegate?.textFieldShouldReturn?(browserVC.searchField)
        XCTAssertEqual(browserVC.webView.url?.absoluteString, "https://www.bing.com/search?q=Test%20Test")
    }

}

extension BrowserViewController {
    class var mocked: BrowserViewController {
        let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        let browserViewController = storyboard.instantiateInitialViewController() as! BrowserViewController
        _ = browserViewController.view
        return browserViewController
    }
}
