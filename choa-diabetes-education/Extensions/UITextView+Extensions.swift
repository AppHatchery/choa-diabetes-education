//
//  UITextView+Extensions.swift
//  choa-diabetes-education
//
//  Created by Maxwell Kapezi Jr on 24/08/2025.
//

import Foundation
import UIKit

extension UITextView {
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
