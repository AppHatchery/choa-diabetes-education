//
//  PrimaryButton.swift
//  choa-diabetes-education
//

import Foundation
import UIKit

open class PrimaryButton: UIButton {

    private static let cornerRadius: CGFloat = UIButton.standardCornerRadius

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
        self.layer.masksToBounds = false
        self.layer.backgroundColor = UIColor.primaryGreenColor.cgColor
		self.titleLabel?.font = .nunitoBold20
        self.tintColor = UIColor.white
		applyCornerRadius(PrimaryButton.cornerRadius)
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowOpacity = 0
        self.layer.shadowRadius = 0
        self.layer.shadowColor = UIColor.black.cgColor

        // Keep the title and image white when disabled instead of the system gray.
        // The faded look comes from the alpha set by the screens using this button.
        setTitleColor(.white, for: .disabled)
        // Configured buttons (e.g. "plain" style from a xib) apply their own disabled color on top of
        // baseForegroundColor, so force white through the title and image color transformers instead.
        configurationUpdateHandler = { button in
            guard var configuration = button.configuration else { return }
            configuration.baseForegroundColor = .white
            configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attributes in
                var attributes = attributes
                attributes.foregroundColor = UIColor.white
                return attributes
            }
            configuration.imageColorTransformer = UIConfigurationColorTransformer { _ in .white }
            // Keep any configuration background at the same fixed radius
            configuration.background.cornerRadius = PrimaryButton.cornerRadius
            configuration.cornerStyle = .fixed
            button.configuration = configuration
        }
    }
}
