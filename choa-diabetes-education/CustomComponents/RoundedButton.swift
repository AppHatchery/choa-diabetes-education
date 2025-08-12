//
//  UIButton+Extensions.swift
//  choa-diabetes-education
//

import Foundation
import UIKit

open class RoundedButton: UIButton {

	private var customFont: UIFont = .gothamRoundedBold

	required public override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}

	required public init?(coder: NSCoder) {
		super.init(coder: coder)
		commonInit()
	}

	private func commonInit() {
		layer.masksToBounds = true
		layer.cornerRadius = 8
		layer.borderWidth = 0
		layer.backgroundColor = UIColor.veryLightBlue.cgColor
//		setTitleColor(.primaryBlue, for: .normal)
//		setTitleColor(.primaryBlue, for: .highlighted)
//		setTitleColor(.white, for: .selected)
	}

	override public func setTitle(_ title: String?, for state: UIControl.State) {
		super.setTitle(title, for: state)
		setTitleColor(.primaryBlue, for: .normal)
//		invalidateIntrinsicContentSize()
	}

	override public func layoutSubviews() {
		super.layoutSubviews()
		titleLabel?.font = customFont
		titleLabel?.numberOfLines = 5
		titleLabel?.lineBreakMode = .byWordWrapping
		titleLabel?.textAlignment = .center
	}

		// Selection state
	public func updateButtonForSelection() {
		isSelected = true
		layer.borderColor = UIColor.primaryBlue.cgColor
		layer.borderWidth = 1
		layer.backgroundColor = UIColor.primaryBlue.cgColor
		tintColor = .white
		setTitleColor(.white, for: .normal)
		setNeedsLayout()
		layoutIfNeeded()
	}

	public func updateButtonForDeselection() {
		isSelected = false
		layer.backgroundColor = UIColor.veryLightBlue.cgColor
		layer.borderColor = UIColor.veryLightBlue.cgColor
		layer.borderWidth = 1
		tintColor = .primaryBlue
		setTitleColor(.primaryBlue, for: .normal)
		setNeedsLayout()
		layoutIfNeeded()
	}
}
