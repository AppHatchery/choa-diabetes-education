//
//  AboutViewController.swift
//  choa-diabetes-education
//
//  Created by Yago Arconada on 2/6/23.
//

import UIKit

class AboutViewController: UIViewController {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var aboutTitle: UILabel!
    
    var scrollView: UIScrollView!
    var contentFrame: CGRect!
    
    @IBOutlet weak var segment: UISegmentedControl!
    
    @IBAction func valueChanged(_ sender: UISegmentedControl) {
        updateView(index: sender.selectedSegmentIndex)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        aboutTitle.text = "About.Title".localized()
        
        let selectedTitle = [NSAttributedString.Key.foregroundColor: UIColor.white]
        let normalTitle = [NSAttributedString.Key.foregroundColor: UIColor.darkGray, NSAttributedString.Key.font: UIFont.gothamRoundedMedium16]

        segment.setTitleTextAttributes(selectedTitle, for: .selected)
        segment.setTitleTextAttributes(normalTitle, for: .normal)
        
        
        updateView(index: 0)
    }
    

    func updateView(index: Int) {
        if scrollView != nil {
            contentView.subviews.forEach({$0.removeFromSuperview()})
        }
        contentFrame = contentView.bounds
        scrollView = UIScrollView(frame: contentFrame)
        
        let y = 0
        
        let aboutApp = AboutApp(frame: CGRect(x: 0, y: y, width: Int(contentFrame.width), height: 900))
        
        let aboutTeam = AboutTeam(frame: CGRect(x: 0, y: 0, width: Int(contentView.frame.width), height: 900))
        
        let currentView = index == 0 ? aboutApp : aboutTeam
                                 
        scrollView.addSubview(currentView)
        scrollView.contentSize = currentView.frame.size
        contentView.addSubview(scrollView)
        
    }
}
