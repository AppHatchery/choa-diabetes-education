//
//  FinalStepNoDescView.swift
//  choa-diabetes-education
//
//  Created by Maxwell Kapezi Jr on 12/08/2025.
//

import UIKit

protocol FinalStepNoDescViewProtocol: AnyObject {
	func didSelectGotItAction(_ currentQuestion: Questionnaire)
}

class FinalStepNoDescView: UIView {
	static let nibName = "FinalStepNoDescView"

	@IBOutlet var contentView: UIView!
	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var doneButton: UIButton!
	@IBOutlet var finalImage: UIImageView!

	private var currentQuestion: Questionnaire!
	weak var delegate: FinalStepNoDescViewProtocol?

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
		Bundle.main.loadNibNamed(FinalStepNoDescView.nibName, owner: self)
		addSubview(contentView)
		contentView.frame = self.bounds
		contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
	}

	func setupView(currentQuestion: Questionnaire) {

		self.currentQuestion = currentQuestion
		titleLabel.font = .gothamRoundedBold26
		titleLabel.numberOfLines = 0
		titleLabel.textColor = .choaGreenColor
		titleLabel.text = currentQuestion.finalStep?.title
		titleLabel.textAlignment = .center

		doneButton.setTitleWithStyle("Exit", font: .gothamRoundedMedium20)
	}

	@IBAction func didDoneButtonTap(_ sender: UIButton) {
		delegate?.didSelectGotItAction(currentQuestion)
	}

}
