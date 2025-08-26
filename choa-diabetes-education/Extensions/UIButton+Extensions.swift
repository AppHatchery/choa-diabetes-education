//
//  UIButton+Extensions.swift
//  choa-diabetes-education
//
//  Created by Maxwell Kapezi Jr on 25/08/2025.
//

import Foundation
import UIKit

extension UIButton {
	func setTitleWithStyle(_ title: String, font: UIFont? = nil, color: UIColor? = nil, for state: UIControl.State = .normal) {

		let finalFont = font ?? self.titleLabel?.font ?? UIFont.systemFont(ofSize: 16)
		let finalColor = color ?? self.titleColor(for: state) ?? .black

		let attributes: [NSAttributedString.Key: Any] = [
			.font: finalFont,
			.foregroundColor: finalColor
		]

		let attributedTitle = NSAttributedString(string: title, attributes: attributes)
		self.setAttributedTitle(attributedTitle, for: state)
	}
}
