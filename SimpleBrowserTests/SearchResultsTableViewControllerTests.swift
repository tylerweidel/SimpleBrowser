//
//  SearchResultsViewControllerTests.swift
//  SimpleBrowserTests
//
//  Created by Weidel, Tyler on 8/6/19.
//  Copyright © 2019 Tyler Weidel. All rights reserved.
//

import XCTest

@testable import SimpleBrowser

class SearchResultsTableViewControllerTests: XCTestCase {

    var searchResultsVC: SearchResultsTableViewController!
    
    override func setUp() {
        searchResultsVC = SearchResultsTableViewController.mocked
    }

    func testSettingSearchResultReloadsTableViewData() {
        XCTAssertEqual(searchResultsVC.tableView.numberOfRows(inSection: 0), 0)
        let mockedSearchResult = SearchResult(query: "Test", results: ["Test1", "Test2", "Test3"])
        searchResultsVC.update(searchResult: mockedSearchResult)
        XCTAssertEqual(searchResultsVC.tableView.numberOfRows(inSection: 0), 3)
    }
    
    func testTouchingCellResetsSearchResultData() {
        let mockedSearchResult = SearchResult(query: "Test", results: ["Test1", "Test2", "Test3"])
        searchResultsVC.update(searchResult: mockedSearchResult)
        searchResultsVC.tableView(searchResultsVC!.tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
        XCTAssertNil(searchResultsVC.searchResult)
    }
}

extension SearchResultsTableViewController {
    class var mocked: SearchResultsTableViewController {
        let searchResultsTableViewController = SearchResultsTableViewController()
        _ = searchResultsTableViewController.view
        return searchResultsTableViewController
    }
    
}

