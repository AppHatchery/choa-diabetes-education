//
//  Communities.swift
//  choa-diabetes-education
//
//  Created by Yago Arconada on 9/13/22.
//

import UIKit

class Communities: UIView {
    
//    @IBOutlet weak var strong4lifeButton: UIButton!
//    @IBOutlet weak var jdrfButton: UIButton!
//    @IBOutlet weak var campkudzeButton: UIButton!
    
    var url: URL!

    //------------------------------------------------------------------------------
    override init( frame: CGRect )
    {
        super.init( frame : frame )
    
        customInit()
    }
    
    //------------------------------------------------------------------------------
    required init?( coder aDecoder: NSCoder )
    {
        super.init( coder : aDecoder )
        
        customInit()
    }
    
    //------------------------------------------------------------------------------
    func customInit()
    {
        let nibView = Bundle.main.loadNibNamed( "Communities", owner: self, options: nil)!.first as! UIView
        self.addSubview( nibView )
        
        nibView.translatesAutoresizingMaskIntoConstraints = false
        
        nibView.leftAnchor.constraint( equalTo: self.leftAnchor ).isActive = true
        nibView.rightAnchor.constraint( equalTo: self.rightAnchor ).isActive = true
        nibView.topAnchor.constraint( equalTo: self.topAnchor ).isActive = true
        nibView.bottomAnchor.constraint( equalTo: self.bottomAnchor ).isActive = true
    }
    
    @IBAction func loadWebpage(_ sender: UIButton){
        switch sender.tag {
        case 0:
            url = URL(string: "https://www.strong4life.com/en")
            // Load strong4life
        case 1:
            url = URL(string: "https://www.jdrf.org/georgiasouthcarolina/")
            // Load jdrf
        case 2:
            // Load campkudze
            url = URL(string: "https://www.campkudzu.org/newly-diagnosed-resource-page/")
        default:
            // Error
            print("there was an error loading the url")
        }
        UIApplication.shared.open(url!)
    }

}
