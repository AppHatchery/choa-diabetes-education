//
//  OrientationFooter.swift
//  choa-diabetes-education
//
//  Created by Yago Arconada on 8/16/22.
//

import UIKit

protocol OrientationFooterDelegate
{
    func nextButton()
}

class OrientationFooter: UIView {
    
    var delegate: OrientationFooterDelegate!
    
    @IBOutlet weak var nextButton: UIButton!

    //------------------------------------------------------------------------------
    init( frame: CGRect,delegate: OrientationFooterDelegate )
    {
        super.init( frame : frame )
        
        self.delegate = delegate
    
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
        let nibView = Bundle.main.loadNibNamed( "OrientationFooter", owner: self, options: nil)!.first as! UIView
        self.addSubview( nibView )
        
        nibView.translatesAutoresizingMaskIntoConstraints = false
        
        nibView.leftAnchor.constraint( equalTo: self.leftAnchor ).isActive = true
        nibView.rightAnchor.constraint( equalTo: self.rightAnchor ).isActive = true
        nibView.topAnchor.constraint( equalTo: self.topAnchor ).isActive = true
        nibView.bottomAnchor.constraint( equalTo: self.bottomAnchor ).isActive = true
        
        nextButton.dropShadow()
    }

    @IBAction func nextButtonPressed(_ sender: Any){
        delegate.nextButton()
    }
}
