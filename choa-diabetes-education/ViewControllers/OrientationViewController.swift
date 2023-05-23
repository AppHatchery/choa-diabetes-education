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
        
        orientationHeaderView.titleLabel.text = "Orientation.Title".localized()
        orientationHeaderView.subtitleLabel.text = "Orientation.Subtitle".localized()
        
        let label = UILabel( frame: CGRect( x: 20, y: y, width: Int(contentFrame.width-40), height: 0 ) )
        label.font = UIFont.avenir
        label.numberOfLines = 100
        label.text = "Orientation.ParagraphText".localized()
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
