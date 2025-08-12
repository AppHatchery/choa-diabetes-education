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

class TwoOptionsView: UIView, TwoOptionsFollowUpQuestionView.TwoOptionsFollowUpDelegate, UrineKetoneLevelView.UrineKetoneLevelDelegate, BloodKetoneLevelView.BloodKetoneLevelDelegate {

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
    @IBOutlet weak var firstButton: RoundedButton!
    @IBOutlet weak var secondButton: RoundedButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var nextButton: PrimaryButton!
	@IBOutlet var followUpQuestionView: UIView!

	private var currentQuestion: Questionnaire!
	private var followUpQuestion: Questionnaire?
    weak var delegate: TwoOptionsViewProtocol?
    
    private var selected = 0
    private var followUpAnswer = 0
    
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
        
        if let answerOptions = currentQuestion.answerOptions {
            firstButton.setTitle(answerOptions[0], for: .normal)
            secondButton.setTitle(answerOptions[1], for: .normal)
        }
    }
    
    @IBAction func didFirstButtonTap(_ sender: UIButton) {
        selected = 1
        secondButton.updateButtonForDeselection()
        firstButton.updateButtonForSelection()
		followUpQuestionView.isHidden = true

		switch currentQuestion.questionId {
		case TwoOptionsQuestionId.testType.id:
			followUpQuestionView.isHidden = true

		case TwoOptionsQuestionId.measuringType.id:
			followUpQuestionView.isHidden = false

			print("Current Question: \(currentQuestion.questionId ?? 0)")
			print("Selected Answer: \(selected)")

			// Clear any existing subviews
			followUpQuestionView.subviews.forEach { $0.removeFromSuperview() }

			// Show urine ketone level view (first option)
			let followUpSubview = UrineKetoneLevelView()
			followUpSubview.translatesAutoresizingMaskIntoConstraints = false
			followUpQuestionView.addSubview(followUpSubview)
			followUpSubview.delegate = self

			NSLayoutConstraint.activate([
				followUpSubview.topAnchor.constraint(equalTo: followUpQuestionView.topAnchor),
				followUpSubview.leadingAnchor.constraint(equalTo: followUpQuestionView.leadingAnchor),
				followUpSubview.trailingAnchor.constraint(equalTo: followUpQuestionView.trailingAnchor),
				followUpSubview.bottomAnchor.constraint(equalTo: followUpQuestionView.bottomAnchor)
			])

		default:
			break
		}
    }
    
    @IBAction func didSecondButtonTap(_ sender: UIButton) {
        selected = 2
        secondButton.updateButtonForSelection()
        firstButton.updateButtonForDeselection()

		switch currentQuestion.questionId {

		case TwoOptionsQuestionId.testType.id:
			followUpQuestionView.isHidden = false

			print("Current Question: \(currentQuestion.questionId ?? 0)")
			print("Selected Answer: \(selected)")
			let followUpSubview = TwoOptionsFollowUpQuestionView()

			followUpSubview.delegate = self

			followUpQuestionView.addSubview(followUpSubview)
			followUpSubview.translatesAutoresizingMaskIntoConstraints = false
			followUpSubview.topAnchor.constraint(equalTo: followUpQuestionView.topAnchor).isActive = true
			followUpSubview.leadingAnchor.constraint(equalTo: followUpQuestionView.leadingAnchor).isActive = true
			followUpSubview.bottomAnchor.constraint(equalTo: followUpQuestionView.bottomAnchor).isActive = true
			followUpSubview.trailingAnchor.constraint(equalTo: followUpQuestionView.trailingAnchor).isActive = true

			followUpSubview.setupView(currentQuestion: currentQuestion)

		case TwoOptionsQuestionId.measuringType.id:
			followUpQuestionView.isHidden = false

			print("Current Question: \(currentQuestion.questionId ?? 0)")
			print("Selected Answer: \(selected)")

			// Clear any existing subviews
			followUpQuestionView.subviews.forEach { $0.removeFromSuperview() }

			// Show blood ketone level view (second option)
			let followUpSubview = BloodKetoneLevelView()
			followUpSubview.translatesAutoresizingMaskIntoConstraints = false
			followUpQuestionView.addSubview(followUpSubview)
			followUpSubview.delegate = self

			NSLayoutConstraint.activate([
				followUpSubview.topAnchor.constraint(equalTo: followUpQuestionView.topAnchor),
				followUpSubview.leadingAnchor.constraint(equalTo: followUpQuestionView.leadingAnchor),
				followUpSubview.trailingAnchor.constraint(equalTo: followUpQuestionView.trailingAnchor),
				followUpSubview.bottomAnchor.constraint(equalTo: followUpQuestionView.bottomAnchor)
			])

		default:
			followUpQuestionView.isHidden = true
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
