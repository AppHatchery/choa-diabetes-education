//
//  YesOrNoFollowUpView.swift
//  choa-diabetes-education
//
//  Created by Maxwell Kapezi Jr on 30/07/2025.
//

import Foundation
import UIKit

protocol YesOrNoFollowUpViewDelegate: AnyObject {
	func didSelectNextAction(currentQuestion: Questionnaire, userSelectedType: YesOrNo)
}

class YesOrNoFollowUpView: UIView {

	@IBOutlet var questionLabel: UILabel!
	@IBOutlet var yesButton: RoundedButton!
	@IBOutlet var noButton: RoundedButton!
	@IBOutlet var contentView: UIView!
	
	weak var delegate: YesOrNoFollowUpViewDelegate?

	private var currentQuestion: Questionnaire!

		// MARK: - XIB Loading
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
	}

		// MARK: - Actions
	@IBAction private func yesButtonTapped(_ sender: RoundedButton) {
			// Handle yes button tap
			// delegate?.didSelectNextAction(currentQuestion: <your_question>, userSelectedType: .yes)
	}

	@IBAction private func noButtonTapped(_ sender: RoundedButton) {
			// Handle no button tap
			// delegate?.didSelectNextAction(currentQuestion: <your_question>, userSelectedType: .no)
	}
}
