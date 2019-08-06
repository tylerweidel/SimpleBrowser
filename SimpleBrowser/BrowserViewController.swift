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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupSearchField()
        
        let urlSession = URLSession(configuration: .default)
        
        BingService(urlSession: urlSession).getSearchResults(using: "fire") { (result) in
            switch result {
            case .success(let searchResult):
                print(searchResult)
            case .failure(let error):
                print("Failed to fetch results:", error)
            }
        }
    }

    private func setupSearchField() {
        searchField.placeholder = "Search"
        searchField.delegate = self
    }

}

extension BrowserViewController: UITextFieldDelegate {
    
    // Show SearchResultsViewController when textFieldDidBeginEditing is called
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let text = textField.text ?? ""
        guard let stringRange = Range(range, in: text) else { return false }
        let typedText = text.replacingCharacters(in: stringRange, with: string)
        
        // Fire network call off here, remember to cancel previous network call so we arent wasting data
        print(typedText)
        return true
    }
    
}

