//
//  QuotesView.swift
//  choa-diabetes-education
//
//  Created by Yago Arconada on 8/16/22.
//

import UIKit

class QuotesView: UIView {
    
    @IBOutlet weak var quoteContent: UILabel!
    @IBOutlet weak var quoteName: UILabel!
    
    var quoteContentLabel = ""
    var quoteNameLabel = ""

    init( frame: CGRect, quoteContent: String, quoteName: String )
    {
        super.init( frame : frame )
    
        quoteContentLabel = quoteContent
        quoteNameLabel = quoteName
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
        let nibView = Bundle.main.loadNibNamed( "QuotesView", owner: self, options: nil)!.first as! UIView
        self.addSubview( nibView )
        
        nibView.translatesAutoresizingMaskIntoConstraints = false
        
        nibView.leftAnchor.constraint( equalTo: self.leftAnchor ).isActive = true
        nibView.rightAnchor.constraint( equalTo: self.rightAnchor ).isActive = true
        nibView.topAnchor.constraint( equalTo: self.topAnchor ).isActive = true
        nibView.bottomAnchor.constraint( equalTo: self.bottomAnchor ).isActive = true
        
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.quotesViewBorderColor.cgColor
        self.layer.cornerRadius = 15
        
        quoteContent.text = quoteContentLabel
        quoteName.text = quoteNameLabel        
    }

}
