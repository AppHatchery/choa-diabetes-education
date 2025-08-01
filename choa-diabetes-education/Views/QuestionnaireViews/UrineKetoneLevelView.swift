//
//  UrineKetoneLevelView.swift
//  choa-diabetes-education
//
//  Created by Maxwell Kapezi Jr on 01/08/2025.
//

import Foundation
import UIKit

class UrineKetoneLevelView: UIView {
	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var levelButtons: [UIButton]!
	@IBOutlet var contentView: UIView!

	private var currentQuestion: Questionnaire!

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

	func setupView(currentQuestion: Questionnaire) {
		self.currentQuestion = currentQuestion

		switch currentQuestion.questionId {

		case TwoOptionsQuestionId.testType.id:
			print("SOME NEWS!")
		default:
			break
		}
	}

	@IBAction func didTapNegativeKetoneLevel(_ sender: Any) {
		
	}
}
