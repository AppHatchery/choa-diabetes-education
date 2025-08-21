//
//  PrimaryButton.swift
//  choa-diabetes-education
//

import Foundation
import UIKit

open class PrimaryButton: UIButton {

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
		self.titleLabel?.font = .gothamRoundedBold16
        self.tintColor = UIColor.white
		self.layer.cornerRadius = 12.0
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowOpacity = 0
        self.layer.shadowRadius = 0
        self.layer.shadowColor = UIColor.black.cgColor
    }
}
