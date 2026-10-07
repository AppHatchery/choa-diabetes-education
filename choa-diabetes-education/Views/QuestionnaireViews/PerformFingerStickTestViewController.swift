//
//  PerformFingerStickTestViewController.swift
//  choa-diabetes-education
//
//  Created by Maxwell Kapezi Jr on 07/10/2026.
//

import UIKit

protocol PerformFingerStickTestViewProtocol: AnyObject {
	func didSelectFingerStickNextAction(_ question: Questionnaire)
}

/// Shown after choosing CGM in the hypoglycemia flow, asking for a finger stick to confirm the reading.
class PerformFingerStickTestView: UIView {
	static let nibName = "PerformFingerStickTestViewController"

	@IBOutlet weak var contentView: UIView!
	@IBOutlet weak var mainStackView: UIStackView!
	@IBOutlet weak var instructionsView: UIView!
	@IBOutlet weak var nextButton: UIButton!

	private var currentQuestion: Questionnaire!
	weak var delegate: PerformFingerStickTestViewProtocol?

	override init(frame: CGRect) {
		super.init(frame: frame)
		nibSetup()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		nibSetup()
	}

	private func nibSetup() {
		Bundle.main.loadNibNamed(PerformFingerStickTestView.nibName, owner: self)
		addSubview(contentView)
		contentView.frame = self.bounds
		contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
	}

	func setupView(currentQuestion: Questionnaire) {
		self.currentQuestion = currentQuestion

		nextButton.layer.cornerRadius = 12

		instructionsView.layer.cornerRadius = 20
		instructionsView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
		instructionsView.clipsToBounds = true
	}

	@IBAction func didTapNextButton(_ sender: UIButton) {
		delegate?.didSelectFingerStickNextAction(currentQuestion)
	}
}
