//
//  UILabel+Extensions.swift
//  choa-diabetes-education
//
//  Created by Yago Arconada on 8/16/22.
//

import UIKit

extension UILabel
{
    public var requiredHeight: CGFloat {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width, height: CGFloat.greatestFiniteMagnitude))
        
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        label.attributedText = attributedText
        label.sizeToFit()
        
        return label.frame.height
    }

	func updateLabelForSelection() {
		self.textColor = .white
	}

	func updateLabelForDeselection() {
		self.textColor = .primaryBlue
	}

	func setText(_ fullText: String, boldPhrases: [String], fontSize: CGFloat = 16) {
		let attributedText = NSMutableAttributedString(string: fullText,
													   attributes: [.font: UIFont.systemFont(ofSize: fontSize)])

		for phrase in boldPhrases {
			if let range = fullText.range(of: phrase) {
				let nsRange = NSRange(range, in: fullText)
				attributedText.addAttribute(.font,
											value: UIFont.boldSystemFont(ofSize: fontSize),
											range: nsRange)
			}
		}

		self.attributedText = attributedText
	}
}
