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
    @IBOutlet weak var textFieldView: UIView!
    @IBOutlet weak var followUpQuestionView: UIView!
    
    @IBOutlet weak var questionLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
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
    

    
    
    func setupView(currentQuestion: Questionnaire, multiple: Bool) {
        
        self.currentQuestion = currentQuestion
        questionLabel.font = .nunitoBold16
        questionLabel.numberOfLines = 0
        questionLabel.textColor = .headingGreenColor
        questionLabel.text = currentQuestion.question
        questionLabel.textAlignment = .left
        
        guard let description = currentQuestion.description, description != "" else {
            
            descriptionLabel.isHidden = true
            
            return
        }
        
        
        descriptionLabel.isHidden = false
        descriptionLabel.font = .arial14
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textColor = .headingGreenColor
        descriptionLabel.text = description
        descriptionLabel.textAlignment = .left
    
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.viewTapped(_:)))
        contentView.addGestureRecognizer(tap)
        contentView.isUserInteractionEnabled = true
    }
    
    
    @objc func viewTapped(_ sender: UITapGestureRecognizer?) {
        contentView.endEditing(true)
    }
  
    
    @IBAction func didNextButtonTap(_ sender: UIButton) {
        
        // TODO: Move logic to VC
 
        switch self.currentQuestion.questionType {
        case .openEndedWithMultipleInput(let id):
            switch  id {
            case .bloodSugar:
//                guard let bloodSugar = Int(firstInputField.text ?? ""), let cf = Int(secondInputField.text ?? "") else { return }
                delegate?.didSelectNextAction(currentQuestion: self.currentQuestion, bloodSugar: bloodSugar, cf: cf)
            }
        default:
            return

        }
        
        
        
    }
}


