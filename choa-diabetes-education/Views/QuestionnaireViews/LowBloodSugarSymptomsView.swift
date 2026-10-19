//
//  LowBloodSugarSymptomsView.swift
//  choa-diabetes-education
//
//  Created by Maxwell Kapezi Jr on 07/10/2026.
//

import UIKit

protocol LowBloodSugarSymptomsViewProtocol: AnyObject {
	func didSelectLowBloodSugarSymptoms(_ question: Questionnaire, hasSymptoms: Bool)
}

/// Shows the low blood sugar symptoms. The user either notices them or picks none of the above.
class LowBloodSugarSymptomsView: UIView {
	static let nibName = "LowBloodSugarSymptomsView"

	@IBOutlet weak var contentView: UIView!
	@IBOutlet weak var mainStackView: UIStackView!
	@IBOutlet weak var questionLabel: UILabel!
	@IBOutlet weak var noticeSymptomsButton: PrimaryButton!
	@IBOutlet weak var noneOfTheAboveButton: PrimaryButton!

	private var currentQuestion: Questionnaire!
	weak var delegate: LowBloodSugarSymptomsViewProtocol?

	override init(frame: CGRect) {
		super.init(frame: frame)
		nibSetup()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		nibSetup()
	}

	private func nibSetup() {
		Bundle.main.loadNibNamed(LowBloodSugarSymptomsView.nibName, owner: self)
		addSubview(contentView)
		contentView.frame = self.bounds
		contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
	}

	func setupView(currentQuestion: Questionnaire) {
		self.currentQuestion = currentQuestion

		questionLabel.text = currentQuestion.question
		noticeSymptomsButton.layer.cornerRadius = 12
	}

	@IBAction func didTapNoticeSymptomsButton(_ sender: UIButton) {
		delegate?.didSelectLowBloodSugarSymptoms(currentQuestion, hasSymptoms: true)
	}

	@IBAction func didTapNoneOfTheAboveButton(_ sender: UIButton) {
		delegate?.didSelectLowBloodSugarSymptoms(currentQuestion, hasSymptoms: false)
	}
}
