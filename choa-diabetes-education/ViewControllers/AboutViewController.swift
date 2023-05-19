//
//  AboutViewController.swift
//  choa-diabetes-education
//
//  Created by Yago Arconada on 2/6/23.
//

import UIKit

class AboutViewController: UIViewController {
    
    @IBOutlet weak var contentView: UIView!
    
    var scrollView: UIScrollView!
    var contentFrame: CGRect!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        updateView()
    }
    
    func updateView() {
        if scrollView != nil {
            scrollView.removeFromSuperview()
        }
        
        contentFrame = contentView.bounds
        
        scrollView = UIScrollView(frame: contentFrame)
        contentView.addSubview(scrollView)
        
        
        var y = 0
        
        let aboutApp = AboutApp(frame: CGRect(x: 0, y: y, width: Int(contentFrame.width), height: Int(contentFrame.height)))
        scrollView.addSubview(aboutApp)
        
        scrollView.contentSize = CGSize(width: Int(scrollView.frame.width), height: Int(contentFrame.height))
    }
}
