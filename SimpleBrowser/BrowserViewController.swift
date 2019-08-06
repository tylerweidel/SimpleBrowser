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
    
    var urlSession: URLSession?
    var searchResultsTableViewController: SearchResultsTableViewController? {
        didSet {
            setupSearchResultsTableViewController()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupSearchField()
        setupURLSession()
    }

    private func setupSearchField() {
        searchField.placeholder = "Search"
        searchField.delegate = self
    }
    
    private func setupURLSession() {
        urlSession = URLSession(configuration: .default)
    }
    
    private func setupSearchResultsTableViewController() {
        searchResultsTableViewController?.delegate = self
        hideSearchResults()
    }
    
    private func showSearchError(with error: Error) {
        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)

        present(alertController, animated: true, completion: nil)
    }
    
    private func fetchQuery(using query: String, then: @escaping ((SearchResult) -> Void)) {

        guard let urlSession = urlSession else { return }
        BingService(urlSession: urlSession).getSearchResults(using: query) { [weak self] (result) in
            switch result {
            case .success(let searchResult):
                then(searchResult)
            case .failure(let error):
                print("Failed to fetch results:", error)
                self?.showSearchError(with: error)
            }
        }
    }
    
    private func showSearchResults() {
        searchResultsView.isHidden = false
    }
    
    private func hideSearchResults() {
        searchResultsView.isHidden = true
//        searchField.resignFirstResponder()
    }
    
    private func loadWebPage(using query: String) {
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "www.bing.com"
        components.path = "/search"
        components.queryItems = [
            URLQueryItem(name: "q", value: query)
        ]
        components.percentEncodedQuery = components.percentEncodedQuery?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        guard let url = components.url else {
            return
        }
        
        let request = URLRequest(url: url)
        
        webView.load(request)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let searchResultsTVC = segue.destination as? SearchResultsTableViewController {
            searchResultsTableViewController = searchResultsTVC
        }
    }

}

extension BrowserViewController: UITextFieldDelegate {
    
    // Show SearchResultsViewController when textFieldDidBeginEditing is called
    func textFieldDidBeginEditing(_ textField: UITextField) {
        showSearchResults()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        hideSearchResults()
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        hideSearchResults()
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
        
        fetchQuery(using: typedText) { [weak self] (result) in
            DispatchQueue.main.async {
                self?.searchResultsTableViewController?.update(searchResult: result)
            }
        }

        return true
    }
}

extension BrowserViewController: SearchResultsDelegate {
    func touchedSearchResult(searchResult: String) {
        hideSearchResults()
        loadWebPage(using: searchResult)
        searchField.text = searchResult
    }
}

