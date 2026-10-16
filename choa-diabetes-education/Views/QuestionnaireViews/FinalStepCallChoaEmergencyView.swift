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

    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var callDetailsView: UIView!
    @IBOutlet var doneButton: UIButton!
	@IBOutlet var callInstructionsView: UIView!
	@IBOutlet var callChoaButton: UIButton!
	@IBOutlet var callTitleLabel: UILabel!
	@IBOutlet var phoneNumberLabel: UILabel!

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

		callChoaButton.layer.cornerRadius = 12
//		callChoaButton.titleLabel?.font = .nunitoBold20

        callDetailsView.layer.cornerRadius = 20
        callDetailsView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        callDetailsView.clipsToBounds = true

        // Patients cared for outside CHOA, and school nurses after giving glucagon, call their own care team
        let isCallCareTeam = currentQuestion.questionType == .callChoaEmergency(.callCareTeam)
        callTitleLabel.text = isCallCareTeam ? currentQuestion.finalStep?.title : "Call CHOA Emergency"
        phoneNumberLabel.isHidden = isCallCareTeam
        callChoaButton.isHidden = isCallCareTeam
        
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
