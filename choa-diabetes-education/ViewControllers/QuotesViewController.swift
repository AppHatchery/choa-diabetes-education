//
//  QuotesViewController.swift
//  choa-diabetes-education
//
//  Created by Yago Arconada on 8/16/22.
//

import UIKit

class QuotesViewController: UIViewController,QuotesFooterDelegate {
    
    @IBOutlet weak var contentView: UIView!
    
    var contentFrame: CGRect!
    var scrollView: UIScrollView!
    
    var sectionTitle: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        updateView()
    }
    
    func updateView() {
        if scrollView != nil {
            scrollView.removeFromSuperview()
        }
        
        contentFrame = self.view.frame
        
        scrollView = UIScrollView(frame: contentFrame)
        contentView.addSubview(scrollView)
        
        var y = 32
        
        let orientationHeaderView = OrientationHeader(frame: CGRect(x: 0, y: y, width: Int(contentFrame.width), height: 280))
        scrollView.addSubview(orientationHeaderView)
        y += 280
        
        orientationHeaderView.titleLabel.text = "Quotes.Title".localized()
        orientationHeaderView.subtitleLabel.text = "Quotes.Subtitle".localized()
        
        // YAGO TO DO: The height should be dynamic so the square adapts to the text size
        let quotesViewOne = QuotesView(frame: CGRect(x: 20, y: y, width: Int(contentFrame.width)-40, height: 164), quoteContent: "Quotes.First".localized(), quoteName: "- " + "Quotes.First.Age".localized())
        scrollView.addSubview(quotesViewOne)
        y += 184
        let quotesViewTwo = QuotesView(frame: CGRect(x: 20, y: y, width: Int(contentFrame.width)-40, height: 164), quoteContent: "Quotes.Second".localized(), quoteName: "- " + "Quotes.Second.Age".localized())
        scrollView.addSubview(quotesViewTwo)
        y += 184
        let quotesViewThree = QuotesView(frame: CGRect(x: 20, y: y, width: Int(contentFrame.width)-40, height: 164), quoteContent: "Quotes.Third".localized(), quoteName: "Quotes.Three.Age".localized())
        scrollView.addSubview(quotesViewThree)
        y += 184
        let quotesViewFour = QuotesView(frame: CGRect(x: 20, y: y, width: Int(contentFrame.width)-40, height: 164), quoteContent: "Quotes.Four".localized(), quoteName: "Quotes.Four.Age".localized())
        scrollView.addSubview(quotesViewFour)
        y += 184
        let orientationFooterView = QuotesFooter(frame: CGRect(x: 0, y: y, width: Int(contentFrame.width), height: 100), delegate: self)
        scrollView.addSubview(orientationFooterView)
        y += 200
        
        scrollView.contentSize = CGSize(width: Int(scrollView.frame.width), height: y)
    }
    
    func doneButton() {
        // Pop all view controllers to home
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func goToHome(_ sender: UIBarButtonItem){
        doneButton()
    }
}
