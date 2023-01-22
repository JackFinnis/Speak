//
//  WebVM.swift
//  Speak
//
//  Created by Jack Finnis on 22/01/2023.
//

import Foundation
import WebKit

class WebVM: NSObject, ObservableObject {
    @Published var text = "https://"
    @Published var url: URL?
    
    var webView: WKWebView?
    
    func submitUrl() {
        guard let url = URL(string: text) else { return }
        webView?.load(URLRequest(url: url))
    }
}

extension WebVM: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print(1)
        url = webView.url
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print(2)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print(3)
    }
}

