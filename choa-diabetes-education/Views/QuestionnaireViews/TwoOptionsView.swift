//
//  TwoOptionsView.swift
//  choa-diabetes-education
//

import Foundation
import UIKit

protocol TwoOptionsViewProtocol: AnyObject {
    func didSelectNextAction(currentQuestion: Questionnaire, selectedAnswer: TwoOptionsAnswer, followUpAnswer: TwoOptionsAnswer?)

	func didSelectNextAction(currentQuestion: Questionnaire, selectedAnswer: TwoOptionsAnswer, followUpAnswer: YesOrNo?)

	// For questions with no follow-up, like how blood sugar was checked
	func didSelectNextAction(currentQuestion: Questionnaire, selectedAnswer: TwoOptionsAnswer)

	func didSelectNextAction(currentQuestion: Questionnaire, selectedAnswer: SixOptionsAnswer, followUpAnswer: SixOptionsAnswer?)
	
	func didSelectNextAction(currentQuestion: Questionnaire, selectedAnswer: ThreeOptionsAnswer, followUpAnswer: ThreeOptionsAnswer?)

	func didSelectNextAction(currentQuestion: Questionnaire, selectedAnswer: SixOptionsAnswer)

	func didSelectNextAction(currentQuestion: Questionnaire, selectedAnswer: ThreeOptionsAnswer)

	func didSelectExitAction()

	func didSelectLearnHowAction()
}

class TwoOptionsView: UIView, TwoOptionsFollowUpQuestionView.TwoOptionsFollowUpDelegate, UrineKetoneLevelView.UrineKetoneLevelDelegate, BloodKetoneLevelView.BloodKetoneLevelDelegate, YesOrNoFollowUpView.YesOrNoFollowUpViewDelegate {

	func urineKetoneFollowUpView(_ view: UrineKetoneLevelView, didSelect answer: Int) {
		self.followUpAnswer = answer

		nextButton.alpha = 1
	}

	func bloodKetoneFollowUpView(_ view: BloodKetoneLevelView, didSelect answer: Int) {
		self.followUpAnswer = answer

		nextButton.alpha = 1
	}

    
    func followUpView(_ view: TwoOptionsFollowUpQuestionView, didSelect answer: Int) {
        self.followUpAnswer = answer

		nextButton.alpha = 1
    }

	func yesOrNoFollowUpView(_ view: YesOrNoFollowUpView, didSelect answer: Int) {
		self.followUpAnswer = answer

		nextButton.alpha = 1
	}

    static let nibName = "TwoOptionsView"
    
    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var nextButton: PrimaryButton!

	@IBOutlet var optionButtons: [UIView]!
	@IBOutlet var optionButtonLabels: [UILabel]!
	@IBOutlet var optionButtonImages: [UIImageView]!

	@IBOutlet var firstButtonLabel: UILabel!
	@IBOutlet var secondButtonLabel: UILabel!

	@IBOutlet var mainStackView: UIStackView!
	@IBOutlet var optionsStackView: UIStackView!

	@IBOutlet var resourcesStackView: UIStackView!
	@IBOutlet var learnHowLabel: UILabel!

	@IBOutlet var firstButtonImage: UIImageView!
	@IBOutlet var secondButtonImage: UIImageView!

	private var currentQuestion: Questionnaire!
	private var followUpQuestion: Questionnaire?

	private let questionnaireManager: QuestionnaireManager = QuestionnaireManager.instance

    weak var delegate: TwoOptionsViewProtocol?
    
    private var selected = 0
    private var followUpAnswer = 0

	// The follow-up for the selected option, shown as the last arranged subview of mainStackView
	private var followUpView: UIView?

    override init(frame: CGRect) {
        super.init(frame: frame)
        nibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        nibSetup()
    }
    
    private func nibSetup() {
        Bundle.main.loadNibNamed(TwoOptionsView.nibName, owner: self)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    func setupView(currentQuestion: Questionnaire) {
        self.currentQuestion = currentQuestion
		questionLabel.font = .nunitoMedium
        questionLabel.numberOfLines = 0
        questionLabel.textColor = .headingGreenColor
        questionLabel.text = currentQuestion.question
        questionLabel.textAlignment = .left
        
        instructionsLabel.text = "GetHelp.Que.CheckChildsKetoneLevel.title"
            .localized()

		optionButtonImages.forEach {
			$0.layer.cornerRadius = 8
		}

		optionButtons.forEach {
			$0.layer.cornerRadius = 8
			$0.layer.borderWidth = 1
			$0.layer.borderColor = UIColor.highlightedBlueColor.cgColor
		}

		if (currentQuestion.questionId == TwoOptionsQuestionId.testType.id ||
			currentQuestion.questionId == TwoOptionsQuestionId.bloodSugarCheckMethod.id) {
			resourcesStackView.isHidden = true
		} else {
			setupLearnHowLabel()
		}

		if (currentQuestion.questionId == TwoOptionsQuestionId.measuringType.id) {
			firstButtonImage.image = UIImage(named: "ketone_strip")
			secondButtonImage.image = UIImage(named: "blood_ketone")
		}

		if selected == 0 {
			nextButton.alpha = 0.3
		}
        

        
		for (index, view) in optionButtons.enumerated() {
			view.isUserInteractionEnabled = true
			let tap = UITapGestureRecognizer(target: self, action: #selector(optionButtonViewTapped(_:)))
			view.addGestureRecognizer(tap)
			view.tag = index
		}

		if let answerOptions = currentQuestion.answerOptions {
			firstButtonLabel.text = answerOptions[0].localized()
			secondButtonLabel.text = answerOptions[1].localized()
		}
    }

	private func setupLearnHowLabel() {
			// Create underlined attributed text
		let text = "Learn how to measure ketones"
		let attributedString = NSMutableAttributedString(string: text)
		attributedString.addAttribute(.underlineStyle,
									  value: NSUnderlineStyle.single.rawValue,
									  range: NSRange(location: 0, length: text.count))

			// Optional: Change text color to make it look like a link
		attributedString.addAttribute(.foregroundColor,
									  value: UIColor.primaryBlue,
									  range: NSRange(location: 0, length: text.count))

		learnHowLabel.attributedText = attributedString

			// Make it tappable
		learnHowLabel.isUserInteractionEnabled = true
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(learnHowLabelTapped))
		learnHowLabel.addGestureRecognizer(tapGesture)
	}

	@objc private func learnHowLabelTapped() {
		delegate?.didSelectLearnHowAction()
	}

	@objc private func optionButtonViewTapped(_ sender: UITapGestureRecognizer) {
		guard let tappedView = sender.view else { return }

			// Loop through all views & labels
		for (index, view) in optionButtons.enumerated() {
			let label = optionButtonLabels[index]

				// This is here since we have less images than we have views/buttons
//			let image = optionButtonImages.indices.contains(index) ? optionButtonImages[index] : nil

			if index == tappedView.tag {
				selected = index + 1
				view.updateViewForSelection()
				label.updateLabelForSelection()

				if (currentQuestion.questionId == TwoOptionsQuestionId.testType.id && selected == 1) ||
					currentQuestion.questionId == TwoOptionsQuestionId.bloodSugarCheckMethod.id {
					nextButton.alpha = 1
				} else {
					nextButton.alpha = 0.3
					followUpAnswer = 0
				}

			} else {
				view.updateViewForDeselection()
				label.updateLabelForDeselection()
			}
		}

		if selected == 1 {
			didFirstButtonTap()
		} else if selected == 2 {
			didSecondButtonTap()
		}
	}

    private func showFollowUpView(_ view: UIView) {
        removeFollowUpView()
        mainStackView.addArrangedSubview(view)
        followUpView = view
    }

    private func removeFollowUpView() {
        followUpView?.removeFromSuperview()
        followUpView = nil
    }

    func didFirstButtonTap() {
        switch currentQuestion.questionId {
        case TwoOptionsQuestionId.testType.id:
            removeFollowUpView()

        case TwoOptionsQuestionId.measuringType.id:
            // Guard against adding duplicate UrineKetoneLevelView
            if followUpView is UrineKetoneLevelView {
                return
            }

            // Save method first - this will clear blood ketones
            questionnaireManager.saveMeasuringMethod(.urineKetone)
            followUpAnswer = 0 // Reset selection

            // Show urine ketone level view (first option)
            let followUpSubview = UrineKetoneLevelView()
            followUpSubview.delegate = self
            showFollowUpView(followUpSubview)

            print("🔄 Selected urine ketone measurement")
            questionnaireManager.printCurrentKetoneState()

        default:
            break
        }
    }

    func didSecondButtonTap() {
        switch currentQuestion.questionId {

        case TwoOptionsQuestionId.testType.id:
            // Guard against adding duplicate YesOrNoFollowUpView
            if followUpView is YesOrNoFollowUpView {
                return
            }

            questionnaireManager.saveMeasuringMethod(.urineKetone)

            let followUpSubview = YesOrNoFollowUpView()
            followUpSubview.delegate = self
            followUpSubview.setupView(currentQuestion: currentQuestion)
            showFollowUpView(followUpSubview)

        case TwoOptionsQuestionId.measuringType.id:
            // Guard against adding duplicate BloodKetoneLevelView
            if followUpView is BloodKetoneLevelView {
                return
            }

            // Save method first - this will clear urine ketones
            questionnaireManager.saveMeasuringMethod(.bloodKetone)
            followUpAnswer = 0 // Reset selection

            // Show blood ketone level view (second option)
            let followUpSubview = BloodKetoneLevelView()
            followUpSubview.delegate = self
            showFollowUpView(followUpSubview)

            print("🔄 Selected blood ketone measurement")
            questionnaireManager.printCurrentKetoneState()

        default:
            break
        }
    }

    @IBAction func didNextButtonTap(_ sender: UIButton) {
        
        // TODO: Architecture Discussion -> Switch Logic to VC
        
        if selected == 0 { return }
        
        switch currentQuestion.questionId {
        case TwoOptionsQuestionId.testType.id:
			if selected == 1 {
				// Uses Injection / Insulin Pen
				delegate?.didSelectNextAction(currentQuestion: currentQuestion, selectedAnswer: .TestType(TestType(id: selected)), followUpAnswer: .CalculationType(CalculationType(id: followUpAnswer)) )
			} else if selected == 2 {
				guard followUpAnswer != 0 else { return }
				// Uses Insulin Pump
				delegate?
					.didSelectNextAction(
						currentQuestion: currentQuestion,
						selectedAnswer: .TestType(TestType(id: selected)),
						followUpAnswer: followUpAnswer == 1 ? .yes : .no
					)
			}

		case TwoOptionsQuestionId.bloodSugarCheckMethod.id:
			delegate?.didSelectNextAction(
				currentQuestion: currentQuestion,
				selectedAnswer: .BloodSugarCheckMethod(BloodSugarCheckMethod(id: selected))
			)

		case TwoOptionsQuestionId.measuringType.id:
				guard followUpAnswer != 0 else { return }

				if selected == 1 {
						// Urine ketones selected
					let answerEnum = UrineKetoneLevel(id: followUpAnswer)
					questionnaireManager.saveMeasuringMethod(.urineKetone)
                    questionnaireManager.incrementKetoneVisitCount()

					delegate?.didSelectNextAction(
						currentQuestion: currentQuestion,
						selectedAnswer: .UrineKetoneLevel(answerEnum),
						followUpAnswer: .UrineKetoneLevel(answerEnum)
					)
				} else if selected == 2 {
						// Blood ketones selected
					let answerEnum = BloodKetoneLevel(id: followUpAnswer)
					questionnaireManager.saveMeasuringMethod(.bloodKetone)
                    questionnaireManager.incrementKetoneVisitCount()

					delegate?.didSelectNextAction(
						currentQuestion: currentQuestion,
						selectedAnswer: .BloodKetoneLevel(answerEnum),
						followUpAnswer: .BloodKetoneLevel(answerEnum)
					)
				}
        default:
            break
        
        }
        
    }


	@IBAction func didTapExitButton(_ sender: UIButton) {
		delegate?.didSelectExitAction()
	}

}
