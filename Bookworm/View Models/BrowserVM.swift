//
//  WebViewState.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/05/22.
//

import WebKit
import Foundation

class BrowserVM: NSObject, ObservableObject, WKNavigationDelegate {
    
    weak var webView: WKWebView? {
        didSet {
            webView?.navigationDelegate = self
        }
    }
    @Published var canGoBack: Bool = false
    @Published var canGoForward: Bool = false
    
    func goBack() {
        webView?.goBack()
    }
    
    func goForward() {
        webView?.goForward()
    }
    
    func reload() {
        webView?.reload()
    }
}

