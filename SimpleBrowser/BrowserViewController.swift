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
    }

    private func setupSearchField() {
        searchField.placeholder = "Search"
        searchField.delegate = self
    }

}

extension BrowserViewController: UITextFieldDelegate {
    
}

