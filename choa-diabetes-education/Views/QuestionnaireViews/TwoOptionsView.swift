//
//  TwoOptionsView.swift
//  choa-diabetes-education
//

import Foundation
import UIKit

protocol TwoOptionsViewProtocol: AnyObject {
    func didSelectNextAction(currentQuestion: Questionnaire, userSelectedTestType: TestType)
    func didSelectNextAction(currentQuestion: Questionnaire, userSelectedMeasuringType: UrineKetonesMeasurements)
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
        secondButton.updateButtonForDeselection()
        firstButton.updateButtonForSelection()
    }
    
    @IBAction func didSecondButtonTap(_ sender: UIButton) {
        secondButton.updateButtonForSelection()
        firstButton.updateButtonForDeselection()
    }
    
    @IBAction func didNextButtonTap(_ sender: UIButton) {
        // TODO: In this case, you already are in the "TwoOptionsView", so do not need to switch case
        // TODO: Discuss architecture 
        switch currentQuestion.questionType {
        case .twoOptions(let id):
            switch id {
            case .testType:
                if firstButton.isSelected {
                    delegate?.didSelectNextAction(currentQuestion: currentQuestion, userSelectedTestType: .pump)
                } else {
                    delegate?.didSelectNextAction(currentQuestion: currentQuestion, userSelectedTestType: .insulinShots)
                }
            case .ketonesMeasure:
                if firstButton.isSelected {
                    delegate?.didSelectNextAction(currentQuestion: currentQuestion, userSelectedMeasuringType: .zeroToSmall)
                } else {
                    delegate?.didSelectNextAction(currentQuestion: currentQuestion, userSelectedMeasuringType: .moderateToLarge)
                }
            }
        default:
            break
        }
    }
}
