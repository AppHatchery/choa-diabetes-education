//
//  TwoOptionsView.swift
//  choa-diabetes-education
//

import Foundation
import UIKit

protocol TwoOptionsViewProtocol: AnyObject {
    func didSelectNextAction(currentQuestion: Questionnaire, selectedAnswer: TwoOptionsAnswer, followUpAnswer: TwoOptionsAnswer?)

	func didSelectNextAction(currentQuestion: Questionnaire, selectedAnswer: TwoOptionsAnswer, followUpAnswer: YesOrNo?)

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
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var nextButton: PrimaryButton!

	@IBOutlet var optionButtons: [UIView]!
	@IBOutlet var optionButtonLabels: [UILabel]!
	@IBOutlet var optionButtonImages: [UIImageView]!

	@IBOutlet var firstButtonLabel: UILabel!
	@IBOutlet var secondButtonLabel: UILabel!

	@IBOutlet var followUpQuestionStackView: UIStackView!
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

	private var followUpSubview = YesOrNoFollowUpView()

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
		questionLabel.font = .gothamRoundedMedium
        questionLabel.numberOfLines = 0
        questionLabel.textColor = .headingGreenColor
        questionLabel.text = currentQuestion.question
        questionLabel.textAlignment = .left

//		nextButton.titleLabel?.font = .gothamRoundedMedium20

		optionButtonImages.forEach {
			$0.layer.cornerRadius = 8
		}

		optionButtons.forEach {
			$0.layer.cornerRadius = 8
			$0.layer.borderWidth = 1
			$0.layer.borderColor = UIColor.highlightedBlueColor.cgColor
		}

		if (currentQuestion.questionId == TwoOptionsQuestionId.testType.id) {
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
			nextButton.titleLabel?.font = .gothamRoundedMedium20
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
		print("Learn How label tapped!")
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

				if currentQuestion.questionId == TwoOptionsQuestionId.testType.id && selected == 1 {
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

	func didFirstButtonTap() {
		switch currentQuestion.questionId {
		case TwoOptionsQuestionId.testType.id:
			followUpQuestionStackView.subviews.forEach { $0.removeFromSuperview() }

		case TwoOptionsQuestionId.measuringType.id:

				// Guard against adding duplicate UrineKetoneLevelView
			if followUpQuestionStackView.subviews.contains(where: { $0 is UrineKetoneLevelView }) {
				return
			}

				// Clear any existing subviews
			followUpQuestionStackView.subviews.forEach { $0.removeFromSuperview() }

				// Show urine ketone level view (first option)
			let followUpSubview = UrineKetoneLevelView()

			followUpSubview.translatesAutoresizingMaskIntoConstraints = false
			followUpQuestionStackView.addArrangedSubview(followUpSubview)

			NSLayoutConstraint.activate([
				followUpSubview.leadingAnchor.constraint(equalTo: followUpQuestionStackView.leadingAnchor),
				followUpSubview.trailingAnchor.constraint(equalTo: followUpQuestionStackView.trailingAnchor)
			])

			followUpSubview.delegate = self

		default:
			break
		}
	}

	func didSecondButtonTap() {
		switch currentQuestion.questionId {

		case TwoOptionsQuestionId.testType.id:

				// Guard against adding duplicate YesOrNoFollowUpView
			if followUpQuestionStackView.subviews.contains(where: { $0 is YesOrNoFollowUpView }) {
				return
			}

			questionnaireManager.saveMeasuringMethod(.urineKetone)

				// Clear any existing subviews first
			followUpQuestionStackView.subviews.forEach { $0.removeFromSuperview() }

			let followUpSubview = YesOrNoFollowUpView()

			followUpSubview.translatesAutoresizingMaskIntoConstraints = false
			followUpQuestionStackView.addArrangedSubview(followUpSubview)

			NSLayoutConstraint.activate([
				followUpSubview.leadingAnchor.constraint(equalTo: followUpQuestionStackView.leadingAnchor),
				followUpSubview.trailingAnchor.constraint(equalTo: followUpQuestionStackView.trailingAnchor)
			])

			followUpSubview.delegate = self
			followUpSubview.setupView(currentQuestion: currentQuestion)

		case TwoOptionsQuestionId.measuringType.id:

				// Guard against adding duplicate BloodKetoneLevelView
			if followUpQuestionStackView.subviews.contains(where: { $0 is BloodKetoneLevelView }) {
				return
			}

			questionnaireManager.saveMeasuringMethod(.bloodKetone)

				// Clear any existing subviews
			followUpQuestionStackView.subviews.forEach { $0.removeFromSuperview() }

				// Show blood ketone level view (second option)
			let followUpSubview = BloodKetoneLevelView()

			followUpSubview.translatesAutoresizingMaskIntoConstraints = false
			followUpQuestionStackView.addArrangedSubview(followUpSubview)

			NSLayoutConstraint.activate([
				followUpSubview.leadingAnchor.constraint(equalTo: followUpQuestionStackView.leadingAnchor),
				followUpSubview.trailingAnchor.constraint(equalTo: followUpQuestionStackView.trailingAnchor)
			])

			followUpSubview.delegate = self

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

		case TwoOptionsQuestionId.measuringType.id:
				guard followUpAnswer != 0 else { return }

				if selected == 1 {
						// Urine ketones selected
					let answerEnum = UrineKetoneLevel(id: followUpAnswer)
					questionnaireManager.saveMeasuringMethod(.urineKetone)

					delegate?.didSelectNextAction(
						currentQuestion: currentQuestion,
						selectedAnswer: .UrineKetoneLevel(answerEnum),
						followUpAnswer: .UrineKetoneLevel(answerEnum)
					)
				} else if selected == 2 {
						// Blood ketones selected
					let answerEnum = BloodKetoneLevel(id: followUpAnswer)
					questionnaireManager.saveMeasuringMethod(.bloodKetone)

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
