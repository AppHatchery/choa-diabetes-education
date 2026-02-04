//
//  UrineKetoneLevelView.swift
//  choa-diabetes-education
//
//  Created by Maxwell Kapezi Jr on 01/08/2025.
//

import Foundation
import UIKit

class UrineKetoneLevelView: UIView {
	protocol UrineKetoneLevelDelegate: AnyObject {
		func urineKetoneFollowUpView(_ view: UrineKetoneLevelView, didSelect answer: Int)
	}

	@IBOutlet var contentView: UIView!
	@IBOutlet var ketoneLevelButtons: [UIButton]!
	@IBOutlet var ketoneLevelsStackView: UIStackView!

	private var currentQuestion: Questionnaire!

	weak var delegate: UrineKetoneLevelDelegate?

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

        view.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(view)
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: leadingAnchor),
            view.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])

		ketoneLevelButtons.forEach {
			$0.layer.cornerRadius = 4
		}

		ketoneLevelsStackView.layer.borderWidth = 1
		ketoneLevelsStackView.layer.borderColor = UIColor.ketoneBorderColor.cgColor
		ketoneLevelsStackView.layer.cornerRadius = 12
		ketoneLevelsStackView.isLayoutMarginsRelativeArrangement = true
		ketoneLevelsStackView.layoutMargins = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
	}
	
	@IBAction func ketoneLevelButtonTapped(_ sender: UIButton) {
		let level: UrineKetoneLevel

		switch sender.tag {
		case 0: level = .negative
		case 1: level = .zeroPointFive
		case 2: level = .onePointFive
		case 3: level = .four
		case 4: level = .eight
		case 5: level = .sixteen
		default: return
		}

		selected = sender.tag + 1
		delegate?.urineKetoneFollowUpView(self, didSelect: selected)
		print("Follow up answer FROM URINE KETONE LEVEL VIEW: \(selected)")

		for button in ketoneLevelButtons {
			button.alpha = (button == sender) ? 1.0 : 0.3
		}

		switch level {
		case .negative, .zeroPointFive:
			print("Level: \(level) - Low/Negative")
		case .onePointFive, .four:
			print("Level: \(level) - Moderate")
		case .eight, .sixteen:
			print("Level: \(level) - High")
		}
	}
}
