//
//  AboutApp.swift
//  choa-diabetes-education
//
//  Created by Yago Arconada on 2/6/23.
//

import UIKit

class AboutApp: UIView {
    
    @IBOutlet weak var aboutTitle: UILabel!
    @IBOutlet weak var americanDiabetesTitle: UILabel!
    @IBOutlet weak var supportTitle: UILabel!
    
    @IBOutlet weak var aboutDescriptionLabel: UILabel!
    @IBOutlet weak var supportTextView: UITextView!
    
    //------------------------------------------------------------------------------
    override init( frame: CGRect ) {
        super.init( frame : frame )
        customInit()
    }
    
    //------------------------------------------------------------------------------
    required init?( coder aDecoder: NSCoder ) {
        super.init( coder : aDecoder )
        customInit()
    }
    
    //------------------------------------------------------------------------------
    func customInit() {
        let nibView = Bundle.main.loadNibNamed( "AboutApp", owner: self, options: nil)!.first as! UIView
        self.addSubview( nibView )
        
        nibView.translatesAutoresizingMaskIntoConstraints = false
        nibView.leftAnchor.constraint( equalTo: self.leftAnchor ).isActive = true
        nibView.rightAnchor.constraint( equalTo: self.rightAnchor ).isActive = true
        nibView.topAnchor.constraint( equalTo: self.topAnchor ).isActive = true
        nibView.bottomAnchor.constraint( equalTo: self.bottomAnchor ).isActive = true
        
        aboutTitle.text = "About.Title.AboutTheApp".localized()
        americanDiabetesTitle.text = "About.Title.AmericanDiabetes".localized()
        supportTitle.text = "About.Title.Support".localized()
        aboutDescriptionLabel.text = "About.Description".localized()
        supportTextView.text = "About.Support.Description".localized()
        
    }
    
    @IBAction func searchForResources(_ sender: UIButton) {
        guard let url = URLs.aboutAppAmericalDiabetes else { return }
        UIApplication.shared.open(url)
    }
}
