//
//  TwoOptionsView.swift
//  choa-diabetes-education
//

import Foundation
import UIKit

protocol TwoOptionsViewProtocol: AnyObject {
    func didSelectNextAction(currentQuestion: Questionnaire, selectedAnswer: TwoOptionsAnswer, followUpAnswer: TwoOptionsAnswer?)

	func didSelectNextAction(currentQuestion: Questionnaire, selectedAnswer: SixOptionsAnswer, followUpAnswer: SixOptionsAnswer?)
	
	func didSelectNextAction(currentQuestion: Questionnaire, selectedAnswer: ThreeOptionsAnswer, followUpAnswer: ThreeOptionsAnswer?)

	func didSelectExitAction()
}

class TwoOptionsView: UIView, TwoOptionsFollowUpQuestionView.TwoOptionsFollowUpDelegate, UrineKetoneLevelView.UrineKetoneLevelDelegate, BloodKetoneLevelView.BloodKetoneLevelDelegate, YesOrNoFollowUpView.YesOrNoFollowUpViewDelegate {

	func urineKetoneFollowUpView(_ view: UrineKetoneLevelView, didSelect answer: Int) {
		self.followUpAnswer = answer
	}

	func bloodKetoneFollowUpView(_ view: BloodKetoneLevelView, didSelect answer: Int) {
		self.followUpAnswer = answer
	}

    
    func followUpView(_ view: TwoOptionsFollowUpQuestionView, didSelect answer: Int) {
        self.followUpAnswer = answer
    }

	func followUpView(_ view: YesOrNoFollowUpView, didSelect answer: Int) {
		self.followUpAnswer = answer
	}

    static let nibName = "TwoOptionsView"
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var nextButton: PrimaryButton!

	@IBOutlet var optionButtons: [UIView]!
	@IBOutlet var optionButtonLabels: [UILabel]!

	@IBOutlet var firstButtonLabel: UILabel!
	@IBOutlet var secondButtonLabel: UILabel!

	@IBOutlet var followUpQuestionStackView: UIStackView!
	@IBOutlet var optionsStackView: UIStackView!

	private var currentQuestion: Questionnaire!
	private var followUpQuestion: Questionnaire?
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

		optionButtons.forEach {
			$0.layer.cornerRadius = 8
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

	@objc private func optionButtonViewTapped(_ sender: UITapGestureRecognizer) {
		guard let tappedView = sender.view else { return }

			// Loop through all views & labels
		for (index, view) in optionButtons.enumerated() {
			let label = optionButtonLabels[index]
			if index == tappedView.tag {
				selected = index + 1
				view.updateViewForSelection()
				label.updateLabelForSelection()
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

			print("Current Question: \(currentQuestion.questionId ?? 0)")
			print("Selected Answer: \(selected)")

			// Clear any existing subviews
			followUpQuestionStackView.subviews.forEach { $0.removeFromSuperview() }

			// Show urine ketone level view (first option)
			let followUpSubview = UrineKetoneLevelView()

			if followUpSubview.isDescendant(of: followUpQuestionStackView) {
				return
			} else {
				followUpSubview.translatesAutoresizingMaskIntoConstraints = false
				followUpQuestionStackView.addArrangedSubview(followUpSubview)

				NSLayoutConstraint.activate([
					followUpSubview.leadingAnchor.constraint(equalTo: followUpQuestionStackView.leadingAnchor),
					followUpSubview.trailingAnchor.constraint(equalTo: followUpQuestionStackView.trailingAnchor)
				])

				followUpSubview.delegate = self

			}
		default:
			break
		}
    }

	func didSecondButtonTap() {
		switch currentQuestion.questionId {

		case TwoOptionsQuestionId.testType.id:
				// followUpQuestionView.isHidden = false

			print("Current Question: \(currentQuestion.questionId ?? 0)")
			print("Selected Answer: \(selected)")

			followUpSubview = YesOrNoFollowUpView()

			followUpQuestionStackView.subviews.forEach { $0.removeFromSuperview() }

			followUpSubview.translatesAutoresizingMaskIntoConstraints = false
			followUpQuestionStackView.addArrangedSubview(followUpSubview)

			NSLayoutConstraint.activate([
				followUpSubview.leadingAnchor.constraint(equalTo: followUpQuestionStackView.leadingAnchor),
				followUpSubview.trailingAnchor.constraint(equalTo: followUpQuestionStackView.trailingAnchor)
			])

			followUpSubview.delegate = self

			followUpSubview.setupView(currentQuestion: currentQuestion)

		case TwoOptionsQuestionId.measuringType.id:

			print("Current Question: \(currentQuestion.questionId ?? 0)")
			print("Selected Answer: \(selected)")

				// Clear any existing subviews
			followUpQuestionStackView.subviews.forEach { $0.removeFromSuperview() }

				// Show blood ketone level view (second option)
			let followUpSubview = BloodKetoneLevelView()

			if followUpQuestionStackView.subviews.contains(followUpSubview) {
				return
			} else {
				followUpSubview.translatesAutoresizingMaskIntoConstraints = false
				followUpQuestionStackView.addArrangedSubview(followUpSubview)

				NSLayoutConstraint.activate([
					followUpSubview.leadingAnchor.constraint(equalTo: followUpQuestionStackView.leadingAnchor),
					followUpSubview.trailingAnchor.constraint(equalTo: followUpQuestionStackView.trailingAnchor)
				])

				followUpSubview.delegate = self
			}

		default:
			break
		}
    }
    
    @IBAction func didNextButtonTap(_ sender: UIButton) {
        
        // TODO: Architecture Discussion -> Switch Logic to VC
        
        if selected == 0 { return }
        
        switch currentQuestion.questionId {
        case TwoOptionsQuestionId.testType.id:
				delegate?.didSelectNextAction(currentQuestion: currentQuestion, selectedAnswer: .TestType(TestType(id: selected)), followUpAnswer: .CalculationType(CalculationType(id: followUpAnswer)) )
		case TwoOptionsQuestionId.measuringType.id:
			print("Current Question: \(currentQuestion.questionId ?? 0)")
			print("Selected Answer: \(selected)")
			print("Follow Up Answer: \(followUpAnswer)")

			guard followUpAnswer != 0 else { return }
			
			if selected == 1 {
				// Urine ketones selected
				let answerEnum = UrineKetoneLevel(id: followUpAnswer)
				delegate?.didSelectNextAction(
					currentQuestion: currentQuestion,
					selectedAnswer: .UrineKetoneLevel(answerEnum),
					followUpAnswer: .UrineKetoneLevel(answerEnum)
				)
			} else if selected == 2 {
				// Blood ketones selected
				let answerEnum = BloodKetoneLevel(id: followUpAnswer)
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
