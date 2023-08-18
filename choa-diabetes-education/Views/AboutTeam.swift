//
//  AboutApp.swift
//  choa-diabetes-education
//
//  Created by Yago Arconada on 2/6/23.
//

import UIKit

class AboutTeam: UIView {

    @IBOutlet weak var aboutTitle: UILabel!
    @IBOutlet weak var collaboratorsTitle: UILabel!
    
    @IBOutlet weak var aboutDescriptionLabel: UILabel!
    @IBOutlet weak var collaboratorsTextView: UITextView!
    
    
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
        let nibView = Bundle.main.loadNibNamed( "AboutTeam", owner: self, options: nil)!.first as! UIView
        self.addSubview( nibView )
        
        nibView.translatesAutoresizingMaskIntoConstraints = false
        nibView.leftAnchor.constraint( equalTo: self.leftAnchor ).isActive = true
        nibView.rightAnchor.constraint( equalTo: self.rightAnchor ).isActive = true
        nibView.topAnchor.constraint( equalTo: self.topAnchor ).isActive = true
        nibView.bottomAnchor.constraint( equalTo: self.bottomAnchor ).isActive = true
        
        aboutTitle.text = "Team.Title.Hatchery".localized()
        collaboratorsTitle.text = "Team.Title.Collaborators".localized()
        aboutDescriptionLabel.text = "Team.Hatchery.Description".localized()
        collaboratorsTextView.text = "Team.Hatchery.Description".localized()
        
    }
    
    @IBAction func openLink(_ sender: UIButton) {
        guard let url = URLs.appHatchery else { return }
        UIApplication.shared.open(url)
    }
}
