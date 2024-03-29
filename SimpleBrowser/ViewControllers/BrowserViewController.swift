//
//  ViewController.swift
//  SimpleBrowser
//
//  Created by Weidel, Tyler on 8/5/19.
//  Copyright © 2019 Tyler Weidel. All rights reserved.
//

import UIKit
import WebKit

class BrowserViewController: UIViewController {

    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var searchResultsView: UIView!
    
    lazy var bingService = BingService()
    var searchResultsTableViewController: SearchResultsTableViewController? {
        didSet {
            setupSearchResultsTableViewController()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupSearchField()
    }

    private func setupSearchField() {
        searchField.placeholder = "Search"
        searchField.delegate = self
    }

    // This gets called from the prepareForSegue setting the searchResultsTableViewController didSet
    private func setupSearchResultsTableViewController() {
        searchResultsTableViewController?.delegate = self
        hideSearchResults()
    }
    
    private func showSearchError(with error: Error) {
        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)

        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    /// Calls the BingService to get the search suggestions using the provided query and calls a completion handler with the `SearchResult`. If there is an error, an error dialog will show on the screen with the returned error message
    private func fetchSearchResults(using query: String, then: @escaping ((SearchResult?) -> Void)) {

        bingService.getSearchResults(using: query) { [weak self] (result) in
            switch result {
            case .success(let searchResult):
                then(searchResult)
            case .failure(let error):
                self?.showSearchError(with: error)
                then(nil)
            }
        }
    }
    
    private func showSearchResults() {
        searchResultsView.isHidden = false
    }
    
    private func hideSearchResults() {
        // Hide search results and clear search result data
        searchResultsView.isHidden = true
        searchResultsTableViewController?.update(searchResult: nil)
    }
    
    /// Loads a bing search webpage using the passed in query string
    private func loadBingSearch(using query: String) {
        // Build webpage url using components
        var components = URLComponents()
        components.scheme = "https"
        components.host = "www.bing.com"
        components.path = "/search"
        components.queryItems = [
            URLQueryItem(name: "q", value: query)
        ]
        
        guard let url = components.url else {
            showSearchError(with: NSError(domain: "Url Components Error", code: 0, userInfo: nil))
            return
        }
        
        let request = URLRequest(url: url)
        
        webView.load(request)
        hideSearchResults()
        searchField.text = query
        searchField.resignFirstResponder()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let searchResultsTVC = segue.destination as? SearchResultsTableViewController {
            searchResultsTableViewController = searchResultsTVC
        }
    }

}

extension BrowserViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        showSearchResults()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        loadBingSearch(using: textField.text ?? "")
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        searchResultsTableViewController?.update(searchResult: nil)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let text = textField.text ?? ""
        guard let stringRange = Range(range, in: text) else { return false }
        let typedText = text.replacingCharacters(in: stringRange, with: string)

        // If user deleted all text, hide search results
        if typedText == "" {
            hideSearchResults()
            return true
        } else {
            showSearchResults()
        }
        
        // Fetch the search suggestions each time the user types and update the search results table view
        fetchSearchResults(using: typedText) { [weak self] (result) in
            DispatchQueue.main.async {
                self?.searchResultsTableViewController?.update(searchResult: result)
            }
        }

        return true
    }
}

extension BrowserViewController: SearchResultsDelegate {
    // This delegate method is called when a user taps on a cell in the search results table view
    func tappedSearchResult(searchResult: String) {
        loadBingSearch(using: searchResult)
    }
}
