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
    
    private func fetchQuery(using query: String, then: @escaping ((SearchResult?) -> Void)) {

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
    
    private func loadWebPage(using query: String) {
        
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
    
    // Show SearchResultsViewController when textFieldDidBeginEditing is called
    func textFieldDidBeginEditing(_ textField: UITextField) {
        showSearchResults()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        loadWebPage(using: textField.text ?? "")
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
        loadWebPage(using: searchResult)
    }
}
