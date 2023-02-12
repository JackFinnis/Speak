//
//  WebView.swift
//  Speak
//
//  Created by Jack Finnis on 22/01/2023.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    @ObservedObject var webVM: WebVM
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = webVM
        webView.isOpaque = false
        webVM.webView = webView
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {}
}
