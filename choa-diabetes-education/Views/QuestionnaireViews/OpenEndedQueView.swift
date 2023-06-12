//
//  OpenEndedQueView.swift
//  choa-diabetes-education
//

import Foundation
import UIKit

protocol OpenEndedQueViewProtocol: AnyObject {
    func didSelectNextAction(currentQuestion: Questionnaire, bloodSugar: Int, cf: Int)
}

class OpenEndedQueView: UIView {
    static let nibName = "OpenEndedQueView"
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var firstQueContentView: UIView!
    @IBOutlet weak var secondQueContentView: UIView!
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var secondQuestionLabel: UILabel!
    
    @IBOutlet weak var firstInputField: UITextField!
    @IBOutlet weak var secondInputField: UITextField!
    
    @IBOutlet weak var unitLabel: UILabel!
    @IBOutlet weak var nextButton: PrimaryButton!
    
    //    @IBOutlet weak var descriptionLabel: UILabel!
    
    private var currentQuestion: Questionnaire!
    weak var delegate: OpenEndedQueViewProtocol?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        nibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        nibSetup()
    }
    
    private func nibSetup() {
        Bundle.main.loadNibNamed(OpenEndedQueView.nibName, owner: self)
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
        
        secondQuestionLabel.font = .gothamRoundedBold16
        secondQuestionLabel.numberOfLines = 0
        secondQuestionLabel.textColor = .headingGreenColor
        secondQuestionLabel.text = currentQuestion.subQuestion
        secondQuestionLabel.textAlignment = .left
        
        unitLabel.font = .avenirLight14
        unitLabel.textColor = .headingGreenColor
        unitLabel.text = currentQuestion.inputUnit
        unitLabel.textAlignment = .left
    }
    
    @IBAction func didNextButtonTap(_ sender: UIButton) {
        guard let bloodSugar = Int(firstInputField.text ?? ""), let cf = Int(secondInputField.text ?? "") else {
            return
        }
        delegate?.didSelectNextAction(currentQuestion: self.currentQuestion, bloodSugar: bloodSugar, cf: cf)
    }
}
