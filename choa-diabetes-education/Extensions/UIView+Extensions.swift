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

	func roundedCorners(corners: UIRectCorner, radius: CGFloat) {
		let maskPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
		let shape = CAShapeLayer()
		shape.path = maskPath.cgPath
		layer.mask = shape
	}

	func updateViewForSelection() {
		self.backgroundColor = .answerSelectionColor
		self.layer.borderColor = UIColor.primaryBlue.cgColor
		self.layer.borderWidth = 1.0
		self.layer.cornerRadius = 8.0
		self.layer.masksToBounds = true
	}

	func updateViewForDeselection() {
		self.backgroundColor = .white
		self.layer.borderColor = UIColor.highlightedBlueColor.cgColor
		self.layer.borderWidth = 1.0
		self.layer.cornerRadius = 8.0
		self.layer.masksToBounds = true
	}

    // MARK: - load from nibs
    class func instantiateFromNib<T: UIView>(viewType: T.Type, owner: AnyObject!) -> T? {
        if let url = NSURL(string: NSStringFromClass(viewType)) {
            return Bundle(for: T.self).loadNibNamed((url.pathExtension)!, owner: owner, options: nil)!.first as? T
        } else {
            return nil
        }
    }

    class func instantiateFromNib() -> Self {
        return instantiateFromNib(viewType: self, owner: nil)!
    }

    class func instantiateFromNibWithOwner(owner: AnyObject!) -> Self {
        return instantiateFromNib(viewType: self, owner: owner)!
    }
    
    func setGradientBackground(colors: [UIColor],
                                   startPoint: CGPoint = CGPoint(x: 0.0, y: 0.5),
                                   endPoint: CGPoint = CGPoint(x: 1.0, y: 0.5),
                                   cornerRadius: CGFloat = 12) {
            // Remove any existing gradient layer to avoid stacking
            layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })

            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = bounds
            gradientLayer.colors = colors.map { $0.cgColor }
            gradientLayer.startPoint = startPoint
            gradientLayer.endPoint = endPoint
            gradientLayer.cornerRadius = cornerRadius
            layer.insertSublayer(gradientLayer, at: 0)
        }
}

