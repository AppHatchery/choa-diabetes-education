//
//  FinalStepView.swift
//  choa-diabetes-education
//

import Foundation
import UIKit

protocol FinalStepViewProtocol: AnyObject {
    func didSelectGotItAction()
}

class FinalStepView: UIView {
    static let nibName = "FinalStepView"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UITextView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var gotItButton: PrimaryButton!
    
    weak var delegate: FinalStepViewProtocol?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        nibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        nibSetup()
    }
    
    private func nibSetup() {
        Bundle.main.loadNibNamed(FinalStepView.nibName, owner: self)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    func setupView(currentQuestion: Questionnaire) {
        titleLabel.font = .gothamRoundedBold16
        titleLabel.numberOfLines = 0
        titleLabel.textColor = .headingGreenColor
        titleLabel.text = currentQuestion.finalStep?.title
        titleLabel.textAlignment = .center
        
        descriptionLabel.font = .avenirLight14
        
        descriptionLabel.textColor = .headingGreenColor
        descriptionLabel.text = currentQuestion.finalStep?.description
        descriptionLabel.textAlignment = .center
        
        gotItButton.setTitle("Got it", for: .normal)
    }
    
    @IBAction func didGotItButtonTap(_ sender: UIButton) {
        delegate?.didSelectGotItAction()
    }
}

