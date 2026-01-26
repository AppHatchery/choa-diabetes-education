//
//  UIButton+Extensions.swift
//  choa-diabetes-education
//

import Foundation
import UIKit

open class RoundedButton: UIButton {

    private var baseTitle: String?

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

    private func commonInit() {
        configureButton()
        self.automaticallyUpdatesConfiguration = true
    }

    private func configureButton() {
        var config = UIButton.Configuration.filled()
        // Title handling via configuration
        let currentTitle = self.title(for: .normal) ?? baseTitle
        config.title = currentTitle
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var out = incoming
            out.font = .gothamRoundedMedium16
            return out
        }

        config.baseBackgroundColor = UIColor.whiteColor
        config.baseForegroundColor = UIColor.primaryBlue

        config.cornerStyle = .fixed
        config.background.cornerRadius = 8
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16)

        config.background.strokeColor = UIColor.highlightedBlueColor
        config.background.strokeWidth = 1

        self.configuration = config

        self.tintColor = UIColor.primaryBlue

        // Update configuration for states (selected vs. normal)
        self.configurationUpdateHandler = { [weak self] button in
            guard let self = self else { return }
            var updated = button.configuration ?? UIButton.Configuration.filled()

            if button.isSelected {
                updated.baseBackgroundColor = UIColor.primaryBlue
                updated.baseForegroundColor = UIColor.white
                updated.background.strokeColor = UIColor.primaryBlue
                updated.background.strokeWidth = 0
            } else {
                updated.baseBackgroundColor = UIColor.whiteColor
                updated.baseForegroundColor = UIColor.primaryBlue
                updated.background.strokeColor = UIColor.highlightedBlueColor
                updated.background.strokeWidth = 1
            }

            updated.cornerStyle = .fixed
            updated.background.cornerRadius = 8

            if updated.title == nil {
                updated.title = (button as? RoundedButton)?.baseTitle ?? button.title(for: .normal)
            }

            button.configuration = updated
        }
    }

    open override func setTitle(_ title: String?, for state: UIControl.State) {
        super.setTitle(title, for: state)
        if state == .normal {
            baseTitle = title
        }
        // Keep configuration's title in sync
        if var cfg = self.configuration {
            cfg.title = title ?? baseTitle
            self.configuration = cfg
        }
        setNeedsUpdateConfiguration()
    }

    // Public API maintained for callers
    public func updateButtonForSelection() {
        // Toggle to selected appearance using configuration
        isSelected = true
    }

    public func updateButtonForDeselection() {
        isSelected = false
    }
}
