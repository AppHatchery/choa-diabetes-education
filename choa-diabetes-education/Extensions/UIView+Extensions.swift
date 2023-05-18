//
//  UIView+Extensions.swift
//  choa-diabetes-education
//
//  Created by Yago Arconada on 8/16/22.
//

import UIKit

extension UIView {

    func dropShadow() {
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 2.0
        layer.shadowColor = self.backgroundColor?.cgColor
//        layer.cornerRadius = 2
//        layer.masksToBounds = false
//        layer.shadowColor = UIColor.black.cgColor
//        layer.shadowOpacity = 0.5
//        layer.shadowOffset = CGSize(width: 1, height: 1)
//        layer.shadowRadius = 2
//        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
//        layer.shouldRasterize = true
//        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    func hwDropShadow() {
        layer.shadowOffset = CGSize(width: 0, height: 12)
        layer.shadowOpacity = 1.0
        layer.shadowRadius = 15.0
        layer.shadowColor = UIColor.shadowColor.cgColor
    }
    
    func detailedDropShadow(color: CGColor, blur: CGFloat,offset: Int,opacity: Float){
        layer.shadowOffset = CGSize(width: 0, height: offset)
        layer.shadowOpacity = opacity
        layer.shadowRadius = blur // Defines the blur of the shadow
        layer.shadowColor = color
        layer.masksToBounds = false
    }
}

