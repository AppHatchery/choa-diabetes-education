//
//  QuizAnswerTableViewCell.swift
//  choa-diabetes-education
//
//  Created by Yago Arconada on 8/25/22.
//

import UIKit

class QuizAnswerTableViewCell: UITableViewCell {
    
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var answerBackground: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
        self.backgroundColor = .clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        if selected {
            answerBackground.backgroundColor = UIColor(named: "answerSelectionColor")
            answerBackground.layer.borderWidth = 2.0
            answerBackground.layer.borderColor = UIColor(named: "choaGreenColor")?.cgColor
        } else {
            answerBackground.backgroundColor = UIColor.white
            answerBackground.layer.borderWidth = 0
        }
    }
}
