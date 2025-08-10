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
        self.titleLabel?.font = UIFont.avenirMedium20
        self.tintColor = UIColor.white
		self.layer.cornerRadius = 12.0
        self.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.layer.shadowOpacity = 0.1
        self.layer.shadowRadius = 2.0
        self.layer.shadowColor = UIColor.black.cgColor
    }
}
