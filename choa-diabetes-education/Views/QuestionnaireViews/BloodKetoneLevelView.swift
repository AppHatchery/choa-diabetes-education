//
//  BloodKetoneLevelView.swift
//  choa-diabetes-education
//
//  Created by Yago Arconada on 08/08/2025.
//

import Foundation
import UIKit

class BloodKetoneLevelView: UIView {
	protocol BloodKetoneLevelDelegate: AnyObject {
		func bloodKetoneFollowUpView(_ view: BloodKetoneLevelView, didSelect answer: Int)
	}

	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var contentView: UIView!
	@IBOutlet var ketoneLevelButtons: [UIButton]!
	@IBOutlet var ketoneLevelsStackView: UIStackView!

	private var currentQuestion: Questionnaire!

	weak var delegate: BloodKetoneLevelDelegate?

	private var selected = 0

	override init(frame: CGRect) {
		super.init(frame: frame)
		loadFromNib()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		loadFromNib()
	}

	private func loadFromNib() {
		let bundle = Bundle(for: type(of: self))
		let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
		guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else {
			return
		}

		addSubview(view)
		view.frame = self.bounds
		view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

		ketoneLevelsStackView.layer.borderWidth = 1
		ketoneLevelsStackView.layer.borderColor = UIColor.black.cgColor
		ketoneLevelsStackView.layer.cornerRadius = 12
		ketoneLevelsStackView.isLayoutMarginsRelativeArrangement = true
		ketoneLevelsStackView.layoutMargins = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)

	}
	
	func setupView(currentQuestion: Questionnaire) {
		self.currentQuestion = currentQuestion
		
		// Configure the title label
		titleLabel.font = .gothamRoundedBold16
		titleLabel.numberOfLines = 0
		titleLabel.textColor = .headingGreenColor
		titleLabel.text = "Blood Ketone Level"
		titleLabel.textAlignment = .left
		
		// Reset button states
		for button in ketoneLevelButtons {
			button.alpha = 0.5
		}
		
		selected = 0
	}
	
	@IBAction func ketoneLevelButtonTapped(_ sender: UIButton) {
		let level: BloodKetoneLevel

		switch sender.tag {
		case 0: level = .low
		case 1: level = .moderate
		case 2: level = .large
		default: return
		}

		selected = sender.tag + 1
		delegate?.bloodKetoneFollowUpView(self, didSelect: selected)
		print("Follow up answer FROM BLOOD KETONE LEVEL VIEW: \(selected)")

		for button in ketoneLevelButtons {
			button.alpha = (button == sender) ? 1.0 : 0.5
		}

		switch level {
		case .low:
			print("Level: \(level) - Low")
		case .moderate:
			print("Level: \(level) - Moderate")
		case .large:
			print("Level: \(level) - Large")
		}
	}
}
