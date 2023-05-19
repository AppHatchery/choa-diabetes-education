//
//  OrientationViewController.swift
//  choa-diabetes-education
//
//  Created by Yago Arconada on 8/16/22.
//

import UIKit

class OrientationViewController: UIViewController,OrientationFooterDelegate {
    
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
        
        contentFrame = self.view.bounds
        
        scrollView = UIScrollView(frame: contentFrame)
        contentView.addSubview(scrollView)
        
        
        var y = 32
        
        let orientationHeaderView = OrientationHeader(frame: CGRect(x: 0, y: y, width: Int(contentFrame.width), height: 280))
        scrollView.addSubview(orientationHeaderView)
        y += 280
        
        orientationHeaderView.titleLabel.text = "Orientation"
        
        let label = UILabel( frame: CGRect( x: 20, y: y, width: Int(contentFrame.width-40), height: 0 ) )
        label.font = UIFont(name: "Avenir", size: 17)
        label.numberOfLines = 100
        label.text = """
        Diabetes can be overwhelming. Our team of doctors and diabetes educators wants to make sure you are as comfortable and confident as possible in managing diabetes as you leave the hospital. You will learn a lot over the next few days and you can rest assured your Diabetes Team is behind you every step of the way. We are always available to answer questions you may have as you navigate diabetes.
        
        While you are in the hospital, you can expect a comprehensive diabetes education experience over the course of two days. You’ll learn about everything from giving an insulin injection, to treating low blood sugars and will have the basics to manage diabetes. This app will be available to you once you leave the hospital to reference as you need, making the information you learn in class available at your fingertips!
         
        As you leave the hospital, you can rest assured that you have a community behind you to help you successfully navigate this new normal. With added blood sugar checks, insulin injections, and carb counting this can be an adjustment as you settle into a new routine. Through diabetes education and practice, you can do this! You will be incredibly proud to look back and see just how much you have learned and how far you have come in a short period of time!
         
        Best,
         
        Your Children’s Diabetes Team
        """
        label.textColor = UIColor.darkGray
        label.frame = CGRect( x: label.frame.origin.x, y: label.frame.origin.y, width: label.frame.width, height: label.requiredHeight )
        
        scrollView.addSubview( label )
        
        y += Int(label.frame.height) + 50
        
        let orientationFooterView = OrientationFooter(frame: CGRect(x: 0, y: y, width: Int(contentFrame.width), height: 100), delegate: self)
        scrollView.addSubview(orientationFooterView)
        y += 200
        
        scrollView.contentSize = CGSize(width: Int(scrollView.frame.width), height: y)
    }
    
    func nextButton() {
        performSegue(withIdentifier: "SegueToAgendaViewController", sender: nil )
    }
    
}
