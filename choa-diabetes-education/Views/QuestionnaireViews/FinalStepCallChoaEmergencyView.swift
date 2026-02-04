//
//  FinalStepCallChoaEmergencyView.swift
//  choa-diabetes-education
//
//  Created by Maxwell Kapezi Jr on 23/08/2025.
//

import Foundation
import UIKit

protocol FinalStepCallChoaEmergencyViewProtocol: AnyObject {
	func didSelectExitAction()
}

class FinalStepCallChoaEmergencyView: UIView {
	static let nibName = "FinalStepCallChoaEmergencyView"

	@IBOutlet weak var contentView: UIView!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet var doneButton: UIButton!
	@IBOutlet var callInstructionsView: UIView!
	@IBOutlet var callChoaButton: UIButton!
	@IBOutlet var callYourCareTeamLabel: UILabel!
	@IBOutlet var mainStackView: UIStackView!

	private var currentQuestion: Questionnaire!
	weak var delegate: FinalStepCallChoaEmergencyViewProtocol?

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
		Bundle.main.loadNibNamed(FinalStepCallChoaEmergencyView.nibName, owner: self)
		addSubview(contentView)
		contentView.frame = self.bounds
		contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
	}

	func setupView(currentQuestion: Questionnaire) {
		self.currentQuestion = currentQuestion
		titleLabel.font = .gothamRoundedBold24
		titleLabel.numberOfLines = 0
		titleLabel.text = currentQuestion.finalStep?.title

		callChoaButton.layer.cornerRadius = 12
//		callChoaButton.titleLabel?.font = .gothamRoundedBold20

        callInstructionsView.isHidden = true
        mainStackView.removeArrangedSubview(callInstructionsView)
        
//		mainStackView.removeArrangedSubview(callYourCareTeamLabel)
	}

	@IBAction func didCallChoaButtonTap(_ sender: Any) {
		guard let url = URL(string: "tel://+404-785-5437") else { return }

		if UIApplication.shared.canOpenURL(url) {
			UIApplication.shared.open(url, options: [:], completionHandler: nil)
		}
	}

	@IBAction func didTapExitButton(_ sender: UIButton) {
		delegate?.didSelectExitAction()
	}
}
