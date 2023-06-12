//
//  TwoOptionsView.swift
//  choa-diabetes-education
//

import Foundation
import UIKit

protocol TwoOptionsViewProtocol: AnyObject {
    func didSelectNextAction(currentQuestion: Questionnaire, selectedAnswer: TwoOptionsAnswer)
}

class TwoOptionsView: UIView {
    static let nibName = "TwoOptionsView"
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var firstButton: RoundedButton!
    @IBOutlet weak var secondButton: RoundedButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var nextButton: PrimaryButton!
    
    @IBOutlet weak var descriptionLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonTopConstraint: NSLayoutConstraint!
    private var currentQuestion: Questionnaire!
    weak var delegate: TwoOptionsViewProtocol?
    
    private var selected = 0
    
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
        questionLabel.font = .gothamRoundedBold16
        questionLabel.numberOfLines = 0
        questionLabel.textColor = .headingGreenColor
        questionLabel.text = currentQuestion.question
        questionLabel.textAlignment = .left
        
        if let answerOptions = currentQuestion.answerOptions {
            firstButton.setTitle(answerOptions[0], for: .normal)
            secondButton.setTitle(answerOptions[1], for: .normal)
        }
        
        guard let description = currentQuestion.description, description != "" else {
            descriptionLabelTopConstraint.constant = 0
            descriptionLabel.isHidden = true
            buttonTopConstraint.constant = 0
            return
        }
        descriptionLabelTopConstraint.constant = 10
        buttonTopConstraint.constant = 30
        descriptionLabel.isHidden = false
        descriptionLabel.font = .avenirLight14
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textColor = .headingGreenColor
        descriptionLabel.text = description
        descriptionLabel.textAlignment = .left
    }
    
    @IBAction func didFirstButtonTap(_ sender: UIButton) {
        selected = 1
        secondButton.updateButtonForDeselection()
        firstButton.updateButtonForSelection()
    }
    
    @IBAction func didSecondButtonTap(_ sender: UIButton) {
        selected = 2
        secondButton.updateButtonForSelection()
        firstButton.updateButtonForDeselection()
    }
    
    @IBAction func didNextButtonTap(_ sender: UIButton) {
        
        // TODO: Architecture Discussion -> Switch Logic to VC
        
        if selected == 0 { return }
        
        switch currentQuestion.questionId {
        case TwoOptionsQuestionId.testType.id:
            delegate?.didSelectNextAction(currentQuestion: currentQuestion, selectedAnswer: .TestType(TestType(id: selected)))
        case TwoOptionsQuestionId.ketonesMeasure.id:
            delegate?.didSelectNextAction(currentQuestion: currentQuestion, selectedAnswer: .UrineKetonesMeasurements(UrineKetonesMeasurements(id: selected)))
        case TwoOptionsQuestionId.lastDose.id:
            if QuestionnaireManager.instance.currentTestType == .pump {
                delegate?.didSelectNextAction(currentQuestion: currentQuestion, selectedAnswer: .PumpLastDose(PumpLastDose(id: selected)))
            } else if QuestionnaireManager.instance.currentTestType == .insulinShots {
                delegate?.didSelectNextAction(currentQuestion: currentQuestion, selectedAnswer: .ShotLastDose(ShotLastDose(id: selected)))
            }
        
        default:
            break
        
        }
        
    }
}
