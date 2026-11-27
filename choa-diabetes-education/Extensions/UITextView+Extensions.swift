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
		// Setting attributedText replaces the storyboard font, so the Nunito fonts have to be set here
		let regularFont = UIFont(name: "Nunito-Regular", size: fontSize) ?? .systemFont(ofSize: fontSize)
		let boldFont = UIFont(name: "Nunito-Bold", size: fontSize) ?? .boldSystemFont(ofSize: fontSize)

		let attributedText = NSMutableAttributedString(string: fullText,
													   attributes: [.font: regularFont])

		for phrase in boldPhrases {
			if let range = fullText.range(of: phrase) {
				let nsRange = NSRange(range, in: fullText)
				attributedText.addAttribute(.font,
											value: boldFont,
											range: nsRange)
			}
		}

		self.attributedText = attributedText
	}
}
