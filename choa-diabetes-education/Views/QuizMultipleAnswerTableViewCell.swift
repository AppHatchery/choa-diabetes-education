//
//  QuizMultipleAnswerTableViewCell.swift
//  choa-diabetes-education
//
//  Created by Yago Arconada on 1/23/23.
//

import UIKit

class QuizMultipleAnswerTableViewCell: UITableViewCell {
    
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var answerBackground: UIView!
    @IBOutlet weak var answerCheckbox: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
        self.backgroundColor = .clear
        self.answerCheckbox.layer.borderColor = UIColor.choaGreenColor.cgColor
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
        if selected {
            answerBackground.backgroundColor = UIColor.answerSelectionColor
            answerBackground.layer.borderWidth = 2.0
            answerBackground.layer.borderColor = UIColor.choaGreenColor.cgColor
            answerCheckbox.layer.borderColor = UIColor.choaGreenColor.cgColor
            answerCheckbox.backgroundColor = UIColor.choaGreenColor
        } else {
            answerBackground.backgroundColor = UIColor.white
            answerBackground.layer.borderWidth = 0
            answerCheckbox.backgroundColor = UIColor.white
            answerCheckbox.layer.borderColor = UIColor.choaGreenColor.cgColor
        }
    }
}
