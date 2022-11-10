//
//  ChapterViewController.swift
//  choa-diabetes-education
//
//  Created by Yago Arconada on 8/17/22.
//

import UIKit
import WebKit

class ChapterViewController: UIViewController, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler, UIScrollViewDelegate, SearchViewDelegate, UISearchBarDelegate  {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        //
    }
    
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var headerTitle: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var progressPercentage: UILabel!
    
    var webView: WKWebView!
    var webViewTopConstraint: NSLayoutConstraint!
    var nextButton: UIButton!
    
    var titleURL = ""
    var contentURL = ""
    var contentIndex = 0
    var fontSize = 100
    
    var searchView: SearchView!

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
        webView.addObserver(self, forKeyPath: "URL", options: [.new, .old], context: nil)
        
        webView.scrollView.delegate = self
        progressBar.setProgress(Float(0), animated: false)
        headerTitle.text = titleURL
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        // Potentially opening up a webview to display the AboutPage
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        closeSearch()
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
            
            // Will be needed for font adjustment feature
            let javascript = "document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '\(fontSize)%'"
            webView.evaluateJavaScript(javascript) { (response, error) in
                print("changed the font size to \(self.fontSize)")
            }
            
        } else {
            print("outside the app, don't apply styling")
        }
    }
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        // WARNING: If the webview hasn't finished loading by the time the button gets added it will be added to the top of the view. It'd be better to put it under a function that detects scrolling
//        let chapterContentHeight = webView.scrollView.contentSize.height
//        let nextButton = UIButton()
//        nextButton.frame = CGRect(x: self.view.frame.width/2-70, y: chapterContentHeight-90, width: 140, height: 60)
//        nextButton.backgroundColor = UIColor.choaGreenColor
//        nextButton.layer.cornerRadius = nextButton.frame.height/2
//        nextButton.setTitle("Done", for: .normal)
//        nextButton.setTitleColor(UIColor.white, for: .normal)
//        nextButton.addTarget(self, action: #selector(goForward), for: .touchDown)
//        webView.scrollView.addSubview(nextButton)
    }
    
    //--------------------------------------------------------------------------------------------------
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {

        // Handle connection to resources pages, etc
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        // Need to use Drag because scrollView fires by itself on viewcontroller load
        
        // Add a flag so that the first scroll does not fire and causes a crash
        
        print(webView.scrollView.contentSize.height)
        // If a Done button has already been added or the user is in the resources section, do not include the button
        addNextButton()
    }
    
    func addNextButton(){
        if nextButton == nil && titleURL != "Food Diary" {
            let chapterContentHeight = webView.scrollView.contentSize.height
            nextButton = UIButton()
            nextButton.frame = CGRect(x: self.view.frame.width/2-70, y: chapterContentHeight-90, width: 140, height: 48)
            nextButton.backgroundColor = UIColor.choaGreenColor
            nextButton.layer.cornerRadius = nextButton.frame.height/2
            nextButton.setTitle("Done", for: .normal)
            nextButton.setTitleColor(UIColor.white, for: .normal)
            nextButton.addTarget(self, action: #selector(goForward), for: .touchDown)
            webView.scrollView.addSubview(nextButton)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Connect scroll view to progress bar
        let offset = webView.scrollView.contentOffset
                
        let percentageOfFullHeight = offset.y / (webView.scrollView.contentSize.height - scrollView.frame.height)
        
        if (percentageOfFullHeight >= 0 && percentageOfFullHeight <= 1){
            progressBar.setProgress(Float(percentageOfFullHeight), animated: true)
            progressPercentage.text = "\(Int(percentageOfFullHeight*100))%"
        } /// subtract the height of the scroll view, because the bottom of the content won't scroll all the way to the top
        
    }
    
    //--------------------------------------------------------------------------------------------------
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, preferences: WKWebpagePreferences, decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
        preferences.preferredContentMode = .mobile
        decisionHandler(.allow,preferences)
    }
        
    
    @IBAction func sliderControl(_ sender: UIButton){
        if fontSize == 100 {
            fontSize = 150
        } else {
            fontSize = 100
        }
        webView.reload()
        if nextButton != nil {
            nextButton.removeFromSuperview()
            nextButton = nil
        }
    }
    
    @objc func goForward(){
        performSegue(withIdentifier: "SegueToEndChapterViewController", sender: nil)
    }
    
    @IBAction func openSearch(_ sender: UIButton){
        let windowScene = UIApplication.shared.connectedScenes.first as! UIWindowScene
        let sceneDelegate = windowScene.delegate as! SceneDelegate
        
        if let window = sceneDelegate.window
        {
            if searchView == nil {
                searchView = SearchView( frame: CGRect(x: 0, y: self.view.bounds.height, width: self.view.bounds.width, height: 180), delegate: self, searchPage: contentURL)

                window.addSubview( searchView )
                
                // Issue is that because the view is not on view when it gets added something on the delegate must not get assigned properly which leads to nothing on the view being responsive
                
                // Interaction to make the search field appear
                UIView.animate( withDuration: 0.25, delay: 0.0, options: UIView.AnimationOptions(), animations: {
                    self.searchView.transform = CGAffineTransform(translationX: 0, y: -1*self.searchView.frame.height)
                    
                }, completion: { _ in
                    
                })
            } else {
                // Animate Up to call users attention
                UIView.animate( withDuration: 0.1, delay: 0.0, options: UIView.AnimationOptions(), animations: {
                    self.searchView.frame.origin.y = self.searchView.frame.origin.y-self.searchView.frame.height/4
                }, completion: { _ in
                    // Animate Down to return to normal state
                    UIView.animate( withDuration: 0.25, delay: 0.0, options: UIView.AnimationOptions(), animations: {
                        self.searchView.frame.origin.y = self.searchView.frame.origin.y+self.searchView.frame.height/4
                    }, completion: { _ in })
                })
            }
        }
        
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 44))
        customView.backgroundColor = UIColor( red: 0xd5/255.0, green: 0xd8/255.0, blue: 0xdc/255.0, alpha: 1)

        let doneButton = UIButton( frame: CGRect( x: view.frame.width - 70 - 10, y: 0, width: 70, height: 44 ))
        doneButton.setTitle( "Dismiss", for: .normal )
        doneButton.setTitleColor( UIColor.systemBlue, for: .normal)
        doneButton.addTarget( self, action: #selector( self.dismissKeyboard), for: .touchUpInside )
        doneButton.addTarget(self, action: #selector(self.moveSearchToBottom), for: .touchUpInside)
        customView.addSubview( doneButton )
        searchView.searchField.inputAccessoryView = customView
    }
    
    func closeSearch(){
        if searchView != nil {
            UIView.animate( withDuration: 0.25, delay: 0.0, options: UIView.AnimationOptions(), animations: {
                self.searchView.contentView.transform = CGAffineTransform(translationX: 0, y: self.searchView.bounds.height)
                
            }, completion: { (value: Bool) in
                self.searchView.removeFromSuperview()
                self.searchView = nil
            })
        }
    }
    
    func closeKeyboard() {
        dismissKeyboard()
    }
    
    func moveSearchView(expansion: CGFloat) {
        print(expansion)
        // Make sure the size of the search field is less than the heigh of the webview
        var newPosition: CGFloat!
        if expansion < (self.view.frame.height - webView.frame.origin.y) && expansion > 0 {
            // Need to adjust the code here so it displays all results in first click, otherwise have to wait for second search query
            searchView.frame = CGRect(x: searchView.frame.origin.x, y: searchView.frame.origin.y, width: searchView.frame.width, height: searchView.frame.height + (expansion-searchView.tableView.frame.height))
            newPosition = self.view.frame.height - searchView.frame.height
        } else if expansion == 0 {
            searchView.frame = CGRect(x: 0, y: searchView.frame.origin.y, width: searchView.frame.width, height: 180)
            newPosition = self.view.frame.height - searchView.frame.height
        } else {
            searchView.frame = CGRect(x: searchView.frame.origin.x, y: searchView.frame.origin.y, width: searchView.frame.width, height: webView.frame.origin.y)
            newPosition = webView.frame.origin.y
        }
        UIView.animate( withDuration: 0.25, delay: 0.0, options: UIView.AnimationOptions(), animations: {
            self.searchView.frame.origin.y = newPosition
            
        }, completion: { (value: Bool) in
            //
        })
    }
    
        
    @objc func keyboardWillShow(notification: NSNotification) {
        print("in Show")
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            else {
            // if keyboard size is not available for some reason, dont do anything
                print("in else")
                
            return
        }
        searchView.frame.origin.y = (self.view.frame.height - keyboardSize.height) - searchView.frame.height+40
    }
    
    //--------------------------------------------------------------------------------------------------
    @objc func dismissKeyboard() {
        // To hide the keyboard when the user clicks search
        self.searchView.endEditing(true)
    }
    
    @objc func moveSearchToBottom(){
        UIView.animate( withDuration: 0.25, delay: 0.0, options: UIView.AnimationOptions(), animations: {
            self.searchView.frame.origin.y = self.view.frame.height - self.searchView.frame.height
            
        }, completion: { (value: Bool) in
            //
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let chapterEndViewController = segue.destination as? ChapterEndViewController
        {
            chapterEndViewController.contentIndex = contentIndex
            chapterEndViewController.chapterEndTitle = titleURL
        }
    }

    
    @objc func keyboardWillHide(notification: NSNotification) {
      // move back the root view origin to zero
        self.view.frame.origin.y = 0
    }

}
