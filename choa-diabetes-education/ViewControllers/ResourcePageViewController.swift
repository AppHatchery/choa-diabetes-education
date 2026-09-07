//
//  ResourcePageViewController.swift
//  choa-diabetes-education
//
//  Created by Maxwell Kapezi Jr on 07/09/2026.
//

import UIKit
import WebKit

class ResourcePageViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {
    
    /// Name of the bundled html file to load, without the extension
    var contentURL = ""
    /// Title shown in the navigation bar
    var pageTitle = ""
    var fontSize = 100
    
    private var webView: WKWebView!
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        let appearance = UINavigationBarAppearance()
        
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .whiteColor
        appearance.shadowColor = .clear
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .black
        navigationItem.backButtonDisplayMode = .minimal
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .whiteColor
        navigationItem.title = pageTitle
        navigationItem.title = ""
        
        let icon = UIImage(named: "close_black")
        let rightButton = UIBarButtonItem(
            image: icon,
            style: .plain,
            target: self,
            action: #selector(didSelectExitAction)
        )
        
        navigationItem.rightBarButtonItem = rightButton
        
        let config = WKWebViewConfiguration()
        
        webView = WKWebView(frame: .zero, configuration: config)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        setupUI()
        
        if let htmlURL = Bundle.main.url(forResource: contentURL, withExtension: "html") {
            // Grant read access to the entire bundle so CSS, JS, fonts, and other resources can be loaded
            webView.loadFileURL(htmlURL, allowingReadAccessTo: Bundle.main.bundleURL)
        }
    }
    
    @objc func didSelectExitAction() {
        navigationController?.popViewController(animated: true)
    }
    
    private func setupUI() {
        view.addSubview(webView)
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0),
            webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            webView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: 0)
        ])
    }
    
    //--------------------------------------------------------------------------------------------------
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard let urlHeader = webView.url?.absoluteString, urlHeader.hasPrefix("file:///") else {
            print("outside the app, don't apply styling")
            return
        }
        
        let js = "var script = document.createElement('script'); script.src = 'uikit-icons.js'; document.body.appendChild(script);"
        let js2 = "var script2 = document.createElement('script'); script2.src = 'uikit.js'; document.body.appendChild(script2);"
        
        webView.evaluateJavaScript(js, completionHandler: nil)
        webView.evaluateJavaScript(js2, completionHandler: nil)
        
        let javascript = "document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '\(fontSize)%'"
        webView.evaluateJavaScript(javascript, completionHandler: nil)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, preferences: WKWebpagePreferences, decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
        if let url = navigationAction.request.url {
            // Resource pages are standalone, so there is no chapter to advance to
            if url.absoluteString.localizedStandardContains("next") {
                decisionHandler(.cancel, preferences)
                return
            }
            
            // Open YouTube links in Safari
            if url.host?.contains("youtube.com") == true || url.host?.contains("youtu.be") == true {
                UIApplication.shared.open(url)
                decisionHandler(.cancel, preferences)
                return
            }
        }
        preferences.preferredContentMode = .mobile
        decisionHandler(.allow, preferences)
    }
}

