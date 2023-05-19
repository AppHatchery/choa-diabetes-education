//
//  ResourceDetailViewController.swift
//  choa-diabetes-education
//
//  Created by Yago Arconada on 9/13/22.
//

import UIKit
import WebKit

class ResourceDetailViewController: UIViewController, WKUIDelegate, WKNavigationDelegate  {
    
    @IBOutlet weak var contentView: UIView!
    
    var webView: WKWebView!
    var webViewTopConstraint: NSLayoutConstraint!
    
    var contentURL = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create WebView Content
        let config = WKWebViewConfiguration()
        
        webView = WKWebView(frame: .zero, configuration: config)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        setupUI()
        
        // TEST: Probably could set up unit tests to make sure the content loads properly
        webView.load( URLRequest( url: Bundle.main.url(forResource: contentURL, withExtension: "html")! ))
        // Potentially opening up a webview to display the AboutPage
    }
    
    func setupUI() {
        contentView.addSubview(webView)
        
        webViewTopConstraint = webView.topAnchor
            .constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 0)
        NSLayoutConstraint.activate([
            webViewTopConstraint,
            webView.leftAnchor
                .constraint(equalTo: contentView.safeAreaLayoutGuide.leftAnchor, constant: 5),
            webView.bottomAnchor
                .constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor),
            webView.rightAnchor
                .constraint(equalTo: contentView.safeAreaLayoutGuide.rightAnchor, constant: -5)
        ])
    }
    
    //--------------------------------------------------------------------------------------------------
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        if let urlHeader = webView.url?.absoluteString, urlHeader.hasPrefix("file:///"){
            
            // Could potentially replace this with just the link to the file rather than having to convert it to string, save some computational power
            // Need to test if JS is correctly imported
            let js = "var script = document.createElement('script'); script.src = 'uikit-icons.js'; document.body.appendChild(script);"
            let js2 = "var script2 = document.createElement('script'); script2.src = 'uikit.js'; document.body.appendChild(script2);"
            
            webView.evaluateJavaScript(js, completionHandler: nil)
            webView.evaluateJavaScript(js2, completionHandler: nil)
        } else {
            print("outside the app, don't apply styling")
        }
    }
    
    //--------------------------------------------------------------------------------------------------
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, preferences: WKWebpagePreferences, decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
        preferences.preferredContentMode = .mobile
        decisionHandler(.allow,preferences)
    }
    
}
