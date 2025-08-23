//
//  FinalStepCallChoaView.swift
//  choa-diabetes-education
//
//  Created by Maxwell Kapezi Jr on 23/08/2025.
//

import Foundation
import UIKit

protocol FinalStepCallChoaViewProtocol: AnyObject {
	func didSelectGotItAction(_ currentQuestion: Questionnaire)
}

class FinalStepCallChoaView: UIView {
	static let nibName = "FinalStepCallChoaView"

	@IBOutlet weak var contentView: UIView!
	@IBOutlet weak var titleLabel: UILabel!
//	@IBOutlet weak var doneButton: UIButton!
//	@IBOutlet var iLetPumpInfoStackView: UIStackView!

	private var currentQuestion: Questionnaire!
	weak var delegate: FinalStepCallChoaViewProtocol?

	weak var viewController: UIViewController?

	override init(frame: CGRect) {
		super.init(frame: frame)
		nibSetup()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		nibSetup()
	}

	private func nibSetup() {
		Bundle.main.loadNibNamed(FinalStepCallChoaView.nibName, owner: self)
		addSubview(contentView)
		contentView.frame = self.bounds
		contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
	}

	func setupView(currentQuestion: Questionnaire) {

		self.currentQuestion = currentQuestion
		titleLabel.font = .gothamRoundedBold20
		titleLabel.numberOfLines = 0
		titleLabel.text = currentQuestion.finalStep?.title
		titleLabel.textAlignment = .natural

//		if QuestionnaireManager.instance.iLetPump {
//			iLetPumpInfoStackView.isHidden = false
//		} else {
//			iLetPumpInfoStackView.isHidden = true
//		}


		if currentQuestion.questionId == FinalQuestionId.shot.id {
//			doneButton.setTitle("Next", for: .normal)
		} else {
				// Understand if users click done and then have to come back through the calculator to review the insulin dose
//			doneButton.setTitle("Exit", for: .normal)
		}


	}

	@IBAction func didDoneButtonTap(_ sender: UIButton) {
		delegate?.didSelectGotItAction(currentQuestion)
	}
}
