//
//  UIButton+Extensions.swift
//  choa-diabetes-education
//
//  Created by Maxwell Kapezi Jr on 25/08/2025.
//

import Foundation
import UIKit

extension UIButton {
	enum ImagePlacement {
		case left, right
	}

	func setTitleWithStyle(
		_ title: String,
		font: UIFont? = nil,
		color: UIColor? = nil,
		image: UIImage? = nil,
		imagePlacement: ImagePlacement = .left,
		spacing: CGFloat = 8,
		for state: UIControl.State = .normal
	) {
		let finalFont = font ?? self.titleLabel?.font ?? UIFont.systemFont(ofSize: 16)
		let finalColor = color ?? self.titleColor(for: state) ?? .black

		let attributes: [NSAttributedString.Key: Any] = [
			.font: finalFont,
			.foregroundColor: finalColor
		]
		let attributedTitle = NSAttributedString(string: title, attributes: attributes)
		self.setAttributedTitle(attributedTitle, for: state)

		if let image = image {
			self.setImage(image.withRenderingMode(.alwaysTemplate), for: state)

			self.configuration?.imagePadding = .zero
			self.configuration?.titlePadding = .zero
			self.configuration?.contentInsets = .zero

			switch imagePlacement {
			case .left:
				self.semanticContentAttribute = .forceLeftToRight
				self.contentHorizontalAlignment = .center
				self.configuration?.imagePadding = spacing

			case .right:
				self.semanticContentAttribute = .forceRightToLeft
				self.contentHorizontalAlignment = .center
				self.configuration?.imagePadding = spacing
			}
		} else {
			self.setImage(nil, for: state)
		}
	}}
