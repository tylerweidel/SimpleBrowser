//
//  SearchResultsViewController.swift
//  SimpleBrowser
//
//  Created by Weidel, Tyler on 8/5/19.
//  Copyright © 2019 Tyler Weidel. All rights reserved.
//

import UIKit

protocol SearchResultsDelegate: class {
    /// This function passes the search suggestion tapped by the user
    func tappedSearchResult(searchResult: String)
}

private let SearchResultIdentifier = "SearchResultIdentifier"

class SearchResultsTableViewController: UITableViewController {

    weak var delegate: SearchResultsDelegate?
    private(set) var searchResult: SearchResult? {
        didSet {
            tableView.reloadData()
        }
    }

    /// The function that updates the table view
    ///
    /// - Parameters:
    ///     - searchResult: The `SearchResult` to be passed in. Passing a non-optional value reloads the tableView with the searchResult data. Passing a nil value clears the tableView and reloads with zero rows
    func update(searchResult: SearchResult?) {
        self.searchResult = searchResult
    }
    
}

extension SearchResultsTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let searchResult = searchResult else { return 0 }
        return searchResult.results.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultIdentifier, for: indexPath)
        cell.textLabel?.text = searchResult?.results[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let searchResult = searchResult else { return }
        delegate?.tappedSearchResult(searchResult: searchResult.results[indexPath.row])
        // Reset searchResult after tapping on a cell to reset next time typing in search
        update(searchResult: nil)
    }
}
