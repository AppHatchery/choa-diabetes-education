//
//  FoodDiary.swift
//  choa-diabetes-education
//
//  Created by Yago Arconada on 9/13/22.
//

import UIKit

protocol FoodDiaryDelegate
{
    func loadResource()
    func loadLowCarbsButton()
    func loadKnowYourCarbsButton()
    func loadFoodsRaiseBloodSugarButton()
    func loadFoodsDontRaiseBloodSugarButton()
}

class FoodDiary: UIView {
    
    @IBOutlet weak var lowCarbButton: UIButton!
    @IBOutlet weak var knowYourCarbsButton: UIButton!
    @IBOutlet weak var foodsRaiseBloodSugarButton: UIButton!
    @IBOutlet weak var foodsDontRaiseBloodSugarButton: UIButton!
    
    var delegate: FoodDiaryDelegate!
    
    //------------------------------------------------------------------------------
    init( frame: CGRect, delegate: FoodDiaryDelegate ) {
        super.init( frame : frame )
        
        self.delegate = delegate
        
        customInit()
    }
    
    //------------------------------------------------------------------------------
    required init?( coder aDecoder: NSCoder ) {
        super.init( coder : aDecoder )
        
        customInit()
    }
    
    //------------------------------------------------------------------------------
    func customInit() {
        let nibView = Bundle.main.loadNibNamed( "FoodDiary", owner: self, options: nil)!.first as! UIView
        self.addSubview( nibView )
        
        nibView.translatesAutoresizingMaskIntoConstraints = false
        
        nibView.leftAnchor.constraint( equalTo: self.leftAnchor ).isActive = true
        nibView.rightAnchor.constraint( equalTo: self.rightAnchor ).isActive = true
        nibView.topAnchor.constraint( equalTo: self.topAnchor ).isActive = true
        nibView.bottomAnchor.constraint( equalTo: self.bottomAnchor ).isActive = true
    }
    
    @IBAction func nextButtonPressed(_ sender: UIButton){
        switch sender.tag {
        case 0:
            delegate.loadLowCarbsButton()
        case 1:
            delegate.loadKnowYourCarbsButton()
        case 2:
            delegate.loadFoodsRaiseBloodSugarButton()
        case 3:
            delegate.loadFoodsDontRaiseBloodSugarButton()
        default:
            print("Error")
            break
        }
    }
}
