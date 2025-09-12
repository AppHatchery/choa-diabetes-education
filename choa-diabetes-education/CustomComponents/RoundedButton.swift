//
//  UIButton+Extensions.swift
//  choa-diabetes-education
//

import Foundation
import UIKit

open class RoundedButton: UIButton {

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
		titleLabel?.font = .gothamRoundedBold16
	}

	func commonInit() {
		setupComponents()
	}

	func setupComponents() {
		self.layer.masksToBounds = true
		self.layer.backgroundColor = UIColor.whiteColor.cgColor
		self.tintColor = UIColor.primaryBlue
		self.layer.cornerRadius = 8
		self.layer.borderColor = UIColor.highlightedBlueColor.cgColor
		self.layer.borderWidth = 1
	}

	public func updateButtonForSelection() {
		self.layer.masksToBounds = true
		self.isSelected = true
		self.layer.backgroundColor = UIColor.primaryBlue.cgColor
		self.tintColor = UIColor.white
		self.layer.cornerRadius = 8
		self.layer.borderColor = UIColor.primaryBlue.cgColor
		self.layer.borderWidth = 0
	}

	public func updateButtonForDeselection() {
		self.isSelected = false
		setupComponents()
	}
}
