//
//  MedicalTeamViewController.swift
//  choa-diabetes-education
//
//  Created by Yago Arconada on 8/16/22.
//

import UIKit

class MedicalTeamViewController: UIViewController,OrientationFooterDelegate {
    
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
        
        let orientationHeaderView = OrientationHeader(frame: CGRect(x: 0, y: y, width: Int(contentFrame.width), height: 260))
        scrollView.addSubview(orientationHeaderView)
        y += 260
        
        orientationHeaderView.titleLabel.text = "MedicalTeam.Title".localized()
        orientationHeaderView.subtitleLabel.text = "MedicalTeam.subtitle".localized()
        
        let medicalTeamView = MedicalTeam(frame: CGRect(x: 0, y: y, width: Int(contentFrame.width), height: 480))
        scrollView.addSubview(medicalTeamView)
        y += 480
        
        let orientationFooterView = OrientationFooter(frame: CGRect(x: 0, y: y, width: Int(contentFrame.width), height: 100), delegate: self)
        scrollView.addSubview(orientationFooterView)
        y += 200
        
        scrollView.contentSize = CGSize(width: Int(scrollView.frame.width), height: y)
    }
    
    func nextButton() {
        performSegue(withIdentifier: "SegueToQuotesViewController", sender: nil )
        
    }
}
