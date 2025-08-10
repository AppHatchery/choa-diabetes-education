//
//  UIButton+Extensions.swift
//  choa-diabetes-education
//

import Foundation
import UIKit

open class RoundedButton: UIButton {

	override open var intrinsicContentSize: CGSize {
		let originalSize = super.intrinsicContentSize
		let minHeight: CGFloat = 36 // Set your minimum height here
		return CGSize(width: originalSize.width, height: max(originalSize.height, minHeight))
	}

		// Custom property to ensure font consistency
	private var customFont: UIFont = .gothamRoundedBold {
		didSet {
			titleLabel?.font = customFont
		}
	}

		// Store original text for restoration
	private var originalMainTitle: String?
	private var originalSubtitle: String?

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
			// Ensure font is set after layout
		titleLabel?.font = customFont
	}

	func commonInit() {
		setupComponents()
	}

	func setupComponents() {
		self.layer.masksToBounds = true
		self.layer.backgroundColor = UIColor.veryLightBlue.cgColor
		setTitleColor(UIColor.primaryBlue, for: .normal)
		setTitleColor(UIColor.primaryBlue, for: .highlighted)
		self.layer.cornerRadius = 8
		self.layer.borderColor = UIColor.veryLightBlue.cgColor
		self.layer.borderWidth = 0
		self.frame.height

			// Set font using custom property
		titleLabel?.font = customFont

			// Alternative approach - override the font property
			// This ensures any external font changes are ignored
		titleLabel?.adjustsFontForContentSizeCategory = false

			// Configure for multi-line text
		titleLabel?.numberOfLines = 0
		titleLabel?.lineBreakMode = .byWordWrapping
		titleLabel?.textAlignment = .center
	}

		// Override this method to prevent external font changes
	override public func setTitle(_ title: String?, for state: UIControl.State) {
		super.setTitle(title, for: state)
		titleLabel?.font = customFont
	}

	public func setupTwoLineText(mainTitle: String, subtitle: String) {
		originalMainTitle = mainTitle
		originalSubtitle = subtitle

		let mainAttributes: [NSAttributedString.Key: Any] = [
			.font: UIFont.gothamRoundedBold,
			.foregroundColor: titleColor(for: .normal) ?? UIColor.primaryBlue
		]

		let subtitleAttributes: [NSAttributedString.Key: Any] = [
			.font: UIFont.gothamRoundedBold, // Regular weight for subtitle
			.foregroundColor: titleColor(for: .normal) ?? UIColor.black
		]

		let attributedString = NSMutableAttributedString()
		attributedString.append(NSAttributedString(string: mainTitle, attributes: mainAttributes))
		attributedString.append(NSAttributedString(string: "\n", attributes: mainAttributes))
		attributedString.append(NSAttributedString(string: subtitle, attributes: subtitleAttributes))

			// Set paragraph style for center alignment
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.alignment = .center
		paragraphStyle.lineSpacing = 2

		attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))

		setAttributedTitle(attributedString, for: .normal)
		setAttributedTitle(attributedString, for: .highlighted)
	}

	public func updateButtonForSelection() {
		self.layer.masksToBounds = true
		self.isSelected = true
		self.layer.borderColor = UIColor.primaryBlue.cgColor
		self.layer.borderWidth = 1
		self.layer.backgroundColor = UIColor.primaryBlue.cgColor
		self.tintColor = UIColor.white
		self.layer.cornerRadius = 10

			// Update attributed text colors for selected state
		if let attributedTitle = attributedTitle(for: .normal) {
			let mutableAttributedString = NSMutableAttributedString(attributedString: attributedTitle)
			mutableAttributedString.addAttribute(.foregroundColor, value: UIColor.white, range: NSRange(location: 0, length: mutableAttributedString.length))
			setAttributedTitle(mutableAttributedString, for: .normal)
			setAttributedTitle(mutableAttributedString, for: .highlighted)
		}
	}

	public func updateButtonForDeselection() {
		self.isSelected = false

			// Reset visual properties without calling setupComponents()
		self.layer.masksToBounds = true
		self.layer.backgroundColor = UIColor.veryLightBlue.cgColor
		self.layer.borderColor = UIColor.veryLightBlue.cgColor
		self.layer.borderWidth = 0
		self.layer.cornerRadius = 10
		self.tintColor = UIColor.primaryBlue

			// Restore original attributed text with correct colors
		if let mainTitle = originalMainTitle, let subtitle = originalSubtitle {
			setupTwoLineText(mainTitle: mainTitle, subtitle: subtitle)
		} else {
				// Fallback to setting title colors if no attributed text
			setTitleColor(UIColor.primaryBlue, for: .normal)
			setTitleColor(UIColor.primaryBlue, for: .highlighted)
		}
	}
}
