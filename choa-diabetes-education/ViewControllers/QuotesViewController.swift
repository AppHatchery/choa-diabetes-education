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
    
    func updateView()
    {
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
        
        orientationHeaderView.titleLabel.text = "You are not alone!"
        orientationHeaderView.subtitleLabel.text = "Voices from other diabetes paitients"
        
        // The height should be dynamic so the square adapts to the text size
        let quotesViewOne = QuotesView(frame: CGRect(x: 20, y: y, width: Int(contentFrame.width)-40, height: 164), quoteContent: "“The hospital did great trying to prepare us for diabetes management. My child has not been overwhelmed with all the new things that have been introduced.”", quoteName: "- Child age 15")
        scrollView.addSubview(quotesViewOne)
        y += 184
        let quotesViewTwo = QuotesView(frame: CGRect(x: 20, y: y, width: Int(contentFrame.width)-40, height: 164), quoteContent: "“The teacher was very informative and gave a good overview of the material. ”", quoteName: "- Child age 7")
        scrollView.addSubview(quotesViewTwo)
        y += 184
        let quotesViewThree = QuotesView(frame: CGRect(x: 20, y: y, width: Int(contentFrame.width)-40, height: 164), quoteContent: "“I feel everything has been covered. I am very grateful to all the insight and the support. It feels great to know we have childrens’ healthcare of Atlanta and their staffs to help up along the way. ”", quoteName: "- Child age 4")
        scrollView.addSubview(quotesViewThree)
        y += 184
        let quotesViewFour = QuotesView(frame: CGRect(x: 0, y: y, width: Int(contentFrame.width), height: 164), quoteContent: "“While it is all overwhelming and a lot of information it is all very helpful. We feel like we have been given the tools to successfully manage diabetes for your child.”", quoteName: "- Child age 10")
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
