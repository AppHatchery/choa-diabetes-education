//
//  UIButton+Extensions.swift
//  choa-diabetes-education
//
//  Created by Maxwell Kapezi Jr on 25/08/2025.
//

import Foundation
import UIKit
import ObjectiveC

extension UIButton {
	/// Every button in the app uses this corner radius
	static let standardCornerRadius: CGFloat = 12

	/// Rounds the button and, for configured buttons, the background the configuration draws.
	/// That background ignores the layer's radius and defaults to a capsule on iOS 26.
	func applyStandardCornerRadius() {
		applyCornerRadius(UIButton.standardCornerRadius)

		guard var configuration,
			  configuration.cornerStyle != .fixed || configuration.background.cornerRadius != UIButton.standardCornerRadius else { return }
		configuration.cornerStyle = .fixed
		configuration.background.cornerRadius = UIButton.standardCornerRadius
		self.configuration = configuration
	}

	/// Applies the standard corner radius to every app button as it's shown, including ones from xibs and storyboards.
	/// Call once at launch.
	static func enforceStandardCornerRadius() {
		_ = swizzleDidMoveToWindow
	}

	// Runs once, however many times enforceStandardCornerRadius is called
	private static let swizzleDidMoveToWindow: Void = {
		let originalSelector = #selector(didMoveToWindow)
		let replacementSelector = #selector(standardCornerRadius_didMoveToWindow)
		guard let original = class_getInstanceMethod(UIButton.self, originalSelector),
			  let replacement = class_getInstanceMethod(UIButton.self, replacementSelector) else { return }

		// UIButton may inherit didMoveToWindow from UIView. Add it to UIButton first so the swap
		// only affects buttons, not every view in the app.
		let didAddMethod = class_addMethod(UIButton.self, originalSelector, method_getImplementation(replacement), method_getTypeEncoding(replacement))
		if didAddMethod {
			class_replaceMethod(UIButton.self, replacementSelector, method_getImplementation(original), method_getTypeEncoding(original))
		} else {
			method_exchangeImplementations(original, replacement)
		}
	}()

	@objc private func standardCornerRadius_didMoveToWindow() {
		// Calls the original didMoveToWindow, since the implementations are swapped
		standardCornerRadius_didMoveToWindow()

		// Only the app's own buttons, so system controls like the search bar's Cancel button keep their native shape
		let buttonClass: AnyClass = type(of: self)
		guard window != nil,
			  buttonClass == UIButton.self || Bundle(for: buttonClass) == Bundle.main else { return }
		applyStandardCornerRadius()
	}

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
