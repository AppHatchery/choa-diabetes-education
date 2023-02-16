//
//  AboutApp.swift
//  choa-diabetes-education
//
//  Created by Yago Arconada on 2/6/23.
//

import UIKit

class AboutApp: UIView {

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
        let nibView = Bundle.main.loadNibNamed( "AboutApp", owner: self, options: nil)!.first as! UIView
        self.addSubview( nibView )
        
        nibView.translatesAutoresizingMaskIntoConstraints = false
        
        nibView.leftAnchor.constraint( equalTo: self.leftAnchor ).isActive = true
        nibView.rightAnchor.constraint( equalTo: self.rightAnchor ).isActive = true
        nibView.topAnchor.constraint( equalTo: self.topAnchor ).isActive = true
        nibView.bottomAnchor.constraint( equalTo: self.bottomAnchor ).isActive = true
    }
    
    @IBAction func searchForResources(_ sender: UIButton){
        if let url = URL(string:"https://diabetes.org/newsroom/press-releases/2022/american-diabetes-association-2023-standards-care-diabetes-guide-for-prevention-diagnosis-treatment-people-living-with-diabetes"){
            UIApplication.shared.open(url)
            
        }
    }

}