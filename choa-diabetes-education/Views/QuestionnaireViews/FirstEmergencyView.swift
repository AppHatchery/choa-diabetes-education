//
//  FirstEmergencyView.swift
//  choa-diabetes-education
//
//  Created by Maxwell Kapezi Jr on 18/08/2025.
//

import Foundation
import UIKit

protocol FirstEmergencyViewProtocol: AnyObject {
	func didSelectGotItAction(_ currentQuestion: Questionnaire)
}

class FirstEmergencyView: UIView {
	static let nibName = "FirstEmergencyView"

	private var currentQuestion: Questionnaire!
	weak var delegate: FirstEmergencyViewProtocol?

	weak var viewController: UIViewController?

	@IBOutlet var contentView: UIView!
	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var call911Button: UIButton!
	@IBOutlet var goToTheNearestLabel: UILabel!
	@IBOutlet var emergencyDepartmentLabel: UILabel!


	override init(frame: CGRect) {
		super.init(frame: frame)
		nibSetup()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		nibSetup()
	}

	private func nibSetup() {
		Bundle.main.loadNibNamed(FirstEmergencyView.nibName, owner: self)
		addSubview(contentView)
		contentView.frame = self.bounds
		contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
	}

	func setupView(currentQuestion: Questionnaire) {
		self.currentQuestion = currentQuestion
		titleLabel.font = .gothamRoundedBold26
		titleLabel.numberOfLines = 0
		titleLabel.textColor = .secondaryRedColor
		titleLabel.text = currentQuestion.finalStep?.title
		titleLabel.textAlignment = .center


		goToTheNearestLabel.font = .gothamRoundedBold26
		goToTheNearestLabel.numberOfLines = 0
		goToTheNearestLabel.textColor = .black
		goToTheNearestLabel.text = currentQuestion.finalStep?.title
		goToTheNearestLabel.textAlignment = .center

		emergencyDepartmentLabel.font = .gothamRoundedBold26
		emergencyDepartmentLabel.numberOfLines = 0
		emergencyDepartmentLabel.textColor = .secondaryRedColor
		emergencyDepartmentLabel.textAlignment = .center

		call911Button.layer.cornerRadius = 8
	}

	@IBAction func call911(_ sender: UIButton) {
		guard let url = URL(string: "tel://911") else { return }

		if UIApplication.shared.canOpenURL(url) {
			UIApplication.shared.open(url, options: [:], completionHandler: nil)
		}
//		delegate?.didSelectGotItAction(currentQuestion)
	}

}
