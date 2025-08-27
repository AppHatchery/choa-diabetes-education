//
//  AboutKetoneMeasurementsViewController.swift
//  choa-diabetes-education
//
//  Created by Maxwell Kapezi Jr on 20/08/2025.
//

import Foundation
import UIKit

class AboutKetoneMeasurementsViewController: UIViewController {

	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var urineMeasurementTitle: UILabel!
	@IBOutlet var urineMeasurementDescription: UITextView!

	@IBOutlet var bloodMeasurementDescription: UITextView!
	@IBOutlet var bloodMeasurementTitle: UILabel!

	@IBOutlet var measurementTitles: [UILabel]!
	@IBOutlet var measurementDescriptions: [UITextView]!

	@IBOutlet var closeButton: PrimaryButton!

	override func viewDidLoad() {
		super.viewDidLoad()

		titleLabel.text = "About.KetoneMeasurements.title".localized()
		titleLabel.textColor = .choaGreenColor
		titleLabel.numberOfLines = 0

		closeButton.setTitleWithStyle("Close", font: .gothamRoundedMedium20)


		measurementTitles.enumerated().forEach { index, label in
			label.textColor = .choaGreenColor
			label.numberOfLines = 0
		}
		
		measurementDescriptions.enumerated().forEach { index, description in
			description.textColor = .black
			description.font = .systemFont(ofSize: 16, weight: .regular)
		}

		urineMeasurementTitle.text = "About.KetoneMeasurements.Urine.title".localized()
		urineMeasurementDescription.text = "About.KetoneMeasurements.Urine.description".localized()
		
		bloodMeasurementTitle.text = "About.KetoneMeasurements.Blood.title".localized()
		bloodMeasurementDescription.text = "About.KetoneMeasurements.Blood.description".localized()
	}

	@IBAction func closeButtonTapped(_ sender: PrimaryButton) {
		dismiss(animated: true)
	}
}
