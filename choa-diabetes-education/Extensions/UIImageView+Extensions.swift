//
//  UIImageView+Extensions.swift
//  choa-diabetes-education
//
//  Created by Maxwell Kapezi Jr on 25/08/2025.
//

import Foundation
import UIKit

extension UIImageView {
	func updateImageForSelection() {
		self.backgroundColor = .highlightedBlueColor
	}

	func updateImageForDeselection() {
		self.backgroundColor = .white
	}
}
