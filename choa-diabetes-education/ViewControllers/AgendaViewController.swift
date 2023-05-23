//
//  AgendaViewController.swift
//  choa-diabetes-education
//
//  Created by Yago Arconada on 8/16/22.
//

import UIKit

class AgendaViewController: UIViewController,OrientationFooterDelegate {
    
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
        
        orientationHeaderView.titleLabel.text = "Agenda".localized()
        
        // The height should be dynamic so the square adapts to the text size
        let agendaHeaderView = AgendaView(frame: CGRect(x: 0, y: y, width: Int(contentFrame.width), height: 950))
        scrollView.addSubview(agendaHeaderView)
        y += 950
        
        let orientationFooterView = OrientationFooter(frame: CGRect(x: 0, y: y, width: Int(contentFrame.width), height: 100), delegate: self)
        scrollView.addSubview(orientationFooterView)
        y += 200
        
        scrollView.contentSize = CGSize(width: Int(scrollView.frame.width), height: y)
    }
    
    func nextButton() {
        performSegue(withIdentifier: "SegueToMedicalTeamViewController", sender: nil )
    }
}
