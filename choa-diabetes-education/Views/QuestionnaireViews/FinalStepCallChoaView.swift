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
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet var insulinPumpStackView: UIStackView!
	@IBOutlet var injectionStackView: UIStackView!

	@IBOutlet var callView: UIView!
	@IBOutlet var callInstructions: UILabel!
	@IBOutlet var callChoaButton: UIButton!

	@IBOutlet var giveNormalDoseLabel: UILabel!
	@IBOutlet var checkBloodSugarLabel: UILabel!
	@IBOutlet var repeatCorrectionLabel: UITextView!

	@IBOutlet var removePumpLabel: UILabel!
	@IBOutlet var calculateAndCorrectLabel: UILabel!
	@IBOutlet var replacePumpLabel: UILabel!
	@IBOutlet var repeatCorrections2: UILabel!
	@IBOutlet var switchBackLabel: UILabel!
    
    @IBOutlet weak var replaceStackView: UIStackView!
    @IBOutlet weak var correctionsStackView: UIStackView!
    @IBOutlet weak var switchBackStackView: UIStackView!
    @IBOutlet weak var stayHydratedStack: UIStackView!
    

	@IBOutlet var hydrationExampleInfoTextView: UITextView!

	@IBOutlet var doneButton: UIButton!

	private let questionnaireManager = QuestionnaireManager.instance
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

		giveNormalDoseLabel.setText(
			"Final.CallChoa.GiveNormalDose.text".localized(),
			boldPhrases: ["normal correction dose", "rapid-acting insulin"]
		)

		checkBloodSugarLabel.setText(
			"Final.CallChoa.CheckBloodSugar.text".localized(),
			boldPhrases: ["blood sugar", "ketones", "2 hours"]
		)

		repeatCorrectionLabel.setText(
			"Final.CallChoa.RepeatCorrection.text".localized(),
			boldPhrases: ["correction every 2 hours", "Urine ketones", "trace or negative", "Blood ketones are below 0.6 mmol/L"]
		)

		callInstructions.setText(
			"Final.CallChoa.CallInstructions.text".localized(),
			boldPhrases: ["Call 404-785-5437", "blood sugar", "ketones", "after 2 corrections"]
		)

			// Insulin Pump Text
		removePumpLabel.setText(
			"Final.CallChoa.RemovePump.text".localized(),
			boldPhrases: ["Remove"]
		)

		calculateAndCorrectLabel.setText(
			"Final.CallChoa.CalculateCorrectionDose.text".localized(),
			boldPhrases: ["correction dose", "rapid-acting", "insulin pen", "pen"]
		)

		replacePumpLabel.setText("Final.CallChoa.ReplacePump.text".localized(), boldPhrases: ["manual mode"])

		repeatCorrections2.setText("Final.CallChoa.RepeatCorrection.text2".localized(), boldPhrases: ["corrections every 2 hours", "Urine ketones", "trace or negative", "Blood ketones", "below 0.6 mmol/L"])

		switchBackLabel.setText("Final.CallChoa.SwitchBack.text".localized(), boldPhrases: ["Switch back to automated mode"])

		hydrationExampleInfoTextView.setText("Final.HydrationExampleInfo.text".localized(), boldPhrases: ["blood sugar is 150 or lower", "blood sugar is over 150"])

		self.currentQuestion = currentQuestion
		titleLabel.font = .gothamRoundedBold20
		titleLabel.numberOfLines = 0
		titleLabel.text = currentQuestion.finalStep?.title
		titleLabel.textAlignment = .natural

		doneButton.titleLabel?.font = .gothamRoundedMedium20
		callChoaButton.titleLabel?.font = .gothamRoundedMedium20

		callView.layer.cornerRadius = 12
		callChoaButton.layer.cornerRadius = 12



		if questionnaireManager.currentTestType == .insulinShots {
			insulinPumpStackView.isHidden = true
			injectionStackView.isHidden = false
		} else {
			insulinPumpStackView.isHidden = false
			injectionStackView.isHidden = true
            
            setupPumpRecheck()
		}
	}
    
    func setupILetPump() {
        if questionnaireManager.yesOver2hours {
            setupILetPumpRecheck()
        } else {
            
        }
    }
    
    func setupILetPumpRecheck() {
        
    }
    
    func setupPumpRecheck() {
        if questionnaireManager.yesOver2hours && (questionnaireManager.urineKetones == .negative || questionnaireManager.bloodKetones == .low) {
            removePumpLabel
                .setText(
                    "Final.CallChoa.ChangePumpSite.text".localized(),
                    boldPhrases: ["Change pump site", "correction dose"]
                )
            
            calculateAndCorrectLabel
                .setText(
                    "Final.CallChoa.Recheck.text".localized(),
                    boldPhrases: ["Recheck blood sugar", "ketones"]
                )
            
            replaceStackView.isHidden = true
            correctionsStackView.isHidden = true
            switchBackStackView.isHidden = true
            stayHydratedStack.isHidden = true
        } else {
            replaceStackView.isHidden = false
            correctionsStackView.isHidden = false
            switchBackStackView.isHidden = false
            stayHydratedStack.isHidden = false
        }
    }

	@IBAction func didCallChoaButtonTap(_ sender: Any) {
		guard let url = URL(string: "tel://+404-785-5437") else { return }

		if UIApplication.shared.canOpenURL(url) {
			UIApplication.shared.open(url, options: [:], completionHandler: nil)
		}
	}

	@IBAction func didDoneButtonTap(_ sender: UIButton) {
		delegate?.didSelectGotItAction(currentQuestion)
	}
}
