//
//  FinalStepWithReminderView.swift
//  choa-diabetes-education
//
//  Created by Maxwell Kapezi Jr on 23/08/2025.
//

import Foundation
import UIKit

protocol FinalStepWithReminderViewProtocol: AnyObject {
	func didSelectGotItAction(_ currentQuestion: Questionnaire)
}

class FinalStepWithReminderView: UIView {
	static let nibName = "FinalStepWithReminderView"

	@IBOutlet var contentView: UIView!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var reminderButton: UIButton!

	@IBOutlet var iLetStackView: UIStackView!
	@IBOutlet var insulinPumpStackView: UIStackView!

	@IBOutlet var reminderView: UIView!

	@IBOutlet var yesOver2hoursButton: UIButton!

	@IBOutlet var doneButton: UIButton!


	private var currentQuestion: Questionnaire!
	weak var delegate: FinalStepWithReminderViewProtocol?

		// Reference to the parent view controller for showing alerts
	weak var viewController: UIViewController?

	private var currentReminderId: String?

	override init(frame: CGRect) {
		super.init(frame: frame)
		nibSetup()
		setupReminderManager()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		nibSetup()
		setupReminderManager()
	}

	private func nibSetup() {
		Bundle.main.loadNibNamed(FinalStepWithReminderView.nibName, owner: self)
		addSubview(contentView)
		contentView.frame = self.bounds
		contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
	}

	private func setupReminderManager() {
		ReminderManager.shared.delegate = self

		ReminderManager.shared.requestPermissions()
	}

	func setupView(currentQuestion: Questionnaire) {
		self.currentQuestion = currentQuestion
		titleLabel.font = .gothamRoundedBold20
		titleLabel.numberOfLines = 0
		titleLabel.text = currentQuestion.finalStep?.title
		titleLabel.textAlignment = .natural

		reminderView.layer.cornerRadius = 12
		reminderButton.layer.cornerRadius = 12

		doneButton.setTitleWithStyle("Exit", font: .gothamRoundedMedium20)

		yesOver2hoursButton.layer.cornerRadius = 12
		yesOver2hoursButton.layer.borderWidth = 1
		yesOver2hoursButton.layer.borderColor = UIColor.primaryBlue.cgColor

		let yesOverText = QuestionnaireManager.instance.iLetPump ?
		"Yes, Over 90 mins" : "Yes, Over 2hrs"

		yesOver2hoursButton.setTitleWithStyle(yesOverText, font: .gothamRoundedMedium20)

		iLetStackView.isHidden = true
		insulinPumpStackView.isHidden = true

		updateReminderButtonTitle()
	}

	private func updateReminderButtonTitle() {
		if currentReminderId != nil {
			reminderButton.setTitleWithStyle("Test Reminder Set", font: .gothamRoundedMedium20)
			reminderButton.backgroundColor = .systemGray
		} else {
			reminderButton.setTitleWithStyle("Remind Me in (30s)", font: .gothamRoundedMedium20)
			reminderButton.backgroundColor = .primaryBlue
		}
	}

	private func updateReminderButtonTitleWithCountdown(_ seconds: Int) {
		let timeText = formatCountdownTime(seconds)
		reminderButton.setTitleWithStyle("Reminder Set (\(timeText))", font: .gothamRoundedMedium20)
		reminderButton.backgroundColor = .systemOrange
	}

	private func formatCountdownTime(_ seconds: Int) -> String {
		if seconds >= 3600 {
			let hours = seconds / 3600
			let minutes = (seconds % 3600) / 60
			let secs = seconds % 60
			return String(format: "%dh %dm %ds", hours, minutes, secs)
		} else if seconds >= 60 {
			let minutes = seconds / 60
			let secs = seconds % 60
			return String(format: "%dm %ds", minutes, secs)
		} else {
			return String(format: "%ds", seconds)
		}
	}

	private func showAlert(title: String, message: String, showSettings: Bool = false) {
		guard let viewController = viewController else { return }

		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

		if showSettings {
			alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
				if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
					UIApplication.shared.open(settingsUrl)
				}
			})
			alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
		} else {
			alert.addAction(UIAlertAction(title: "OK", style: .default))
		}

		viewController.present(alert, animated: true)
	}

	@IBAction func remindMeButtonTapped(_ sender: UIButton) {
			// If reminder already exists, cancel it
		if let existingId = currentReminderId {
			ReminderManager.shared.cancelReminder(withIdentifier: existingId)
			currentReminderId = nil
			updateReminderButtonTitle()

				// Show cancellation confirmation
			showAlert(title: "Reminder Canceled", message: "Your reminder has been canceled.")
			return
		}

			// Schedule a 30-second reminder for testing with countdown enabled
		currentReminderId = ReminderManager.shared.scheduleTestReminder(
			title: "Test Reminder",
			body: "Your 30-second test reminder is here!",
			enableCountdown: true
		)
	}

	@IBAction func didDoneButtonTap(_ sender: UIButton) {
		delegate?.didSelectGotItAction(currentQuestion)
	}
}

// MARK: - ReminderManagerDelegate
extension FinalStepWithReminderView: ReminderManagerDelegate {

	func reminderManager(_ manager: ReminderManager, didScheduleReminderWithId id: String) {
			// Initial setup - countdown will start updating immediately if enabled
		updateReminderButtonTitle()

			// Show success message
		showAlert(
			title: "Test Reminder Set",
			message: "You'll get a test notification in 30 seconds!"
		)
	}

	func reminderManager(_ manager: ReminderManager, countdownUpdate seconds: Int, forReminderId id: String) {
			// Only update if this is our current reminder
		guard id == currentReminderId else { return }

			// Update button with countdown
		updateReminderButtonTitleWithCountdown(seconds)
	}

	func reminderManager(_ manager: ReminderManager, countdownFinishedForReminderId id: String) {
			// Only update if this is our current reminder
		guard id == currentReminderId else { return }

			// Reset reminder state
		currentReminderId = nil
		updateReminderButtonTitle()
	}

	func reminderManager(_ manager: ReminderManager, didFailWithError error: Error) {
		showAlert(
			title: "Error",
			message: "Failed to set reminder: \(error.localizedDescription)"
		)
	}

	func reminderManager(_ manager: ReminderManager, permissionDenied: Bool) {
		showAlert(
			title: "Permission Required",
			message: "Please enable notifications in Settings to use reminders.",
			showSettings: true
		)
	}
}
