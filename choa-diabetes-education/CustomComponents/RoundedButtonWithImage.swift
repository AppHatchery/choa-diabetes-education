//
//  RoundedButtonWithImage.swift
//  choa-diabetes-education
//
//  Created by Maxwell Kapezi Jr on 13/08/2025.
//

import Foundation
import UIKit

open class RoundedButtonWithImage: UIButton {

	required public override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}

	required public init?(coder: NSCoder) {
		super.init(coder: coder)
		commonInit()
	}

	override public func layoutSubviews() {
		super.layoutSubviews()
	}

	func commonInit() {
		setupComponents()
	}

	func setupComponents() {
		self.layer.masksToBounds = true
		self.layer.backgroundColor = UIColor.veryLightBlue.cgColor
		setTitleColor(UIColor.black, for: .normal)
		setTitleColor(UIColor.black, for: .highlighted)
		self.layer.cornerRadius = 10
		self.layer.borderColor = UIColor.lightGreenColor.cgColor
		self.layer.borderWidth = 0
	}

	public func updateButtonForSelection() {
		self.layer.masksToBounds = true
		self.isSelected = true
			//		self.layer.borderColor = UIColor.choaGreenColor.cgColor
			//		self.layer.borderWidth = 1
		self.layer.backgroundColor = UIColor.primaryBlue.cgColor
		self.tintColor = UIColor.white
		self.layer.cornerRadius = 10
	}

	public func updateButtonForDeselection() {
		self.isSelected = false
		setupComponents()
	}
}
