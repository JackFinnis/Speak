//
//  WebVM.swift
//  Speak
//
//  Created by Jack Finnis on 22/01/2023.
//

import Foundation
import WebKit

class WebVM: NSObject, ObservableObject {
    @Published var loading = false
    @Published var text = "https://"
    @Published var url: URL?
    
    var webView: WKWebView?
    
    func submitUrl() {
        guard let url = URL(string: text) else { return }
        self.url = nil
        loading = true
        webView?.load(URLRequest(url: url))
    }
}

extension WebVM: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        url = webView.url
        text = url?.absoluteString ?? text
        loading = false
    }
}
