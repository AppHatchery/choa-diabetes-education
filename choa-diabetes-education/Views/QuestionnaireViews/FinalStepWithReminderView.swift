//
//  FinalStepWithReminderView.swift
//  choa-diabetes-education
//
//  Created by Maxwell Kapezi Jr on 23/08/2025.
//

import Foundation
import UIKit

protocol FinalStepWithReminderViewProtocol: AnyObject {
	func didSelectExitAction()

	func didSelectYesOverAction(_ currentQuestion: Questionnaire)
}

class FinalStepWithReminderView: UIView {
	static let nibName = "FinalStepWithReminderView"

	@IBOutlet var contentView: UIView!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var reminderButton: UIButton!

	@IBOutlet var confirmChangeDisconnectStackView: UIStackView!

	@IBOutlet var confirmChangeDisconnectImage: UIImageView!
	@IBOutlet var confirmChangeDisconnectLabel: UILabel!

	@IBOutlet var giveRecommendedDoseStackView: UIStackView!
	@IBOutlet var giveRecommendedDoseLabel: UILabel!

	@IBOutlet var hopeImage: UIImageView!

	@IBOutlet var hydrationInfoStackView: UIStackView!
	@IBOutlet var rearrangeableStackView: UIStackView!

	@IBOutlet var reminderContainerView: UIView!
	@IBOutlet var reminderView: UIView!
	@IBOutlet var reminderNextCheckLabel: UILabel!
	@IBOutlet var reminderNextCheckDescriptionLabel: UILabel!
	@IBOutlet var reminderTimeCheckLabel: UILabel!

	@IBOutlet var yesOver2hoursButton: UIButton!

	@IBOutlet var doneButton: UIButton!


	private var currentQuestion: Questionnaire!

	private let questionnaireManagerInstance: QuestionnaireManager = QuestionnaireManager.instance

	weak var delegate: FinalStepWithReminderViewProtocol?

		// Reference to the parent view controller for showing alerts
	weak var viewController: UIViewController?

	private var currentReminderId: String?

	private var countdownTimer: Timer?

	override func didMoveToWindow() {
		super.didMoveToWindow()
		if window != nil {
				// View is being added to hierarchy - restore state
			restoreReminderState()
		} else {
				// View is being removed - clean up
			countdownTimer?.invalidate()
			countdownTimer = nil
		}
	}

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

	deinit {
		cleanup()
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

		titleLabel.text = questionnaireManagerInstance.currentTestType == .insulinShots ? "Calculator.Final.ContinueRegularCare.title"
			.localized().capitalizedFirstLetter : currentQuestion.finalStep?.title

		titleLabel.textAlignment = .natural

		reminderView.layer.cornerRadius = 12
		reminderButton.layer.cornerRadius = 12

		doneButton.setTitleWithStyle("Exit", font: .gothamRoundedMedium20)

		yesOver2hoursButton.layer.cornerRadius = 12
		yesOver2hoursButton.layer.borderWidth = 0
		yesOver2hoursButton.layer.borderColor = UIColor.primaryBlue.cgColor

		let yesOverText = questionnaireManagerInstance.iLetPump ?
		"Yes, Over 90 mins" : "Yes, Over 2hrs"

		giveRecommendedDoseLabel.setText(
			"Final.GiveRecommendedDose.text".localized(),
			boldPhrases: ["correction dose through", "pump site"]
		)

		if questionnaireManagerInstance.currentTestType == .pump {

			confirmChangeDisconnectLabel
				.setText("Final.ConfirmPumpIsSecure.text".localized(), boldPhrases: ["pump site is securely connected"])
			hopeImage.isHidden = true

			flipHydrationAndReminder()
		}

		// iLet Pump View Conditions
		if questionnaireManagerInstance.iLetPump {
			confirmChangeDisconnectImage.image = UIImage(named: "ilet_pump")

			if questionnaireManagerInstance.bloodKetones ==
				.moderate || (
					questionnaireManagerInstance.urineKetones == .onePointFive || questionnaireManagerInstance.urineKetones == .four
				) {
				confirmChangeDisconnectLabel.setText("Final.ChangeIletPumpSite.text".localized(), boldPhrases: ["Change", "pump site"])
				giveRecommendedDoseStackView.isHidden = true
			} else if questionnaireManagerInstance.bloodKetones ==
				.moderate || (
					questionnaireManagerInstance.urineKetones == .onePointFive || questionnaireManagerInstance.urineKetones == .four
				) {
				confirmChangeDisconnectLabel.setText("Final.DisconnectIletPump.text".localized(), boldPhrases: ["Disconnect", "pump"])

				giveRecommendedDoseStackView.isHidden = false

				giveRecommendedDoseLabel.setText(
					"Final.CalculateAndGiveCorrectionDose.text".localized(),
					boldPhrases: ["correction dose", "rapid-acting", "insulin pen", "syringe"]
				)
			}

			reminderNextCheckLabel.text = "Final.ReminderNextCheckForIlet.text".localized()
			reminderNextCheckDescriptionLabel.setText("Final.ReminderNextCheckDescriptionForIlet.text".localized(), boldPhrases: ["blood sugar", "ketones", "90 mins"])
			reminderTimeCheckLabel.setText("Final.ReminderTimeCheckForIlet.text".localized(), boldPhrases: ["90 minutes"])

			hopeImage.isHidden = true

			flipHydrationAndReminder()
		} else {
			reminderNextCheckLabel.text = "Final.ReminderNextCheck.text".localized()

			reminderNextCheckDescriptionLabel.setText("Final.ReminderNextCheckDescription.text".localized(), boldPhrases: ["blood sugar", "ketones", "2 hours"])
			reminderTimeCheckLabel.setText("Final.ReminderTimeCheck.text".localized(), boldPhrases: ["2 hours"])
		}

		if questionnaireManagerInstance.currentTestType == .insulinShots {
			confirmChangeDisconnectStackView.isHidden = true
			giveRecommendedDoseStackView.isHidden = true
		}

		yesOver2hoursButton.setTitleWithStyle(yesOverText, font: .gothamRoundedMedium20)

		updateReminderButtonTitle()
	}

	func flipHydrationAndReminder() {
		rearrangeableStackView.removeArrangedSubview(hydrationInfoStackView)
		rearrangeableStackView.removeArrangedSubview(reminderContainerView)

		rearrangeableStackView.addArrangedSubview(reminderContainerView)
		rearrangeableStackView.addArrangedSubview(hydrationInfoStackView)
	}

	private func updateReminderButtonTitle() {
		if currentReminderId != nil {
			reminderButton.setTitleWithStyle("Test Reminder Set", font: .gothamRoundedMedium20)
			reminderButton.backgroundColor = .systemGray
		} else {
			reminderButton.setTitleWithStyle("Remind Me", font: .gothamRoundedMedium20)
			reminderButton.backgroundColor = .primaryBlue
		}
	}

	private func updateReminderButtonTitleWithCountdown(_ seconds: Int) {
		let timeText = formatCountdownTime(seconds)
		reminderButton.setTitleWithStyle("Reminder Set (\(timeText))", font: .gothamRoundedMedium20)
		reminderButton.backgroundColor = .secondaryRedColor
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

	private func restoreReminderState() {
		guard questionnaireManagerInstance.hasActiveReminder(),
			  let reminderId = questionnaireManagerInstance.getActiveReminderId(),
			  let remainingTime = questionnaireManagerInstance.getRemainingTime() else {
			currentReminderId = nil
			updateReminderButtonTitle()
			return
		}

		currentReminderId = reminderId
		startCountdownTimer(with: Int(remainingTime))
	}

	private func startCountdownTimer(with seconds: Int) {
			// Invalidate any existing timer
		countdownTimer?.invalidate()

		var remainingSeconds = seconds

			// Update immediately
		updateReminderButtonTitleWithCountdown(remainingSeconds)

			// Start timer for countdown updates
		countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
			guard let self = self else {
				timer.invalidate()
				return
			}

			remainingSeconds -= 1

			if remainingSeconds <= 0 {
				timer.invalidate()
				self.currentReminderId = nil
				self.updateReminderButtonTitle()
				questionnaireManagerInstance.clearActiveReminder()
			} else {
				self.updateReminderButtonTitleWithCountdown(remainingSeconds)
			}
		}
	}

	@IBAction func remindMeButtonTapped(_ sender: UIButton) {
			// If reminder already exists, cancel it
		if let existingId = currentReminderId {
			ReminderManager.shared.cancelReminder(withIdentifier: existingId)
			currentReminderId = nil
			updateReminderButtonTitle()
			countdownTimer?.invalidate()
			countdownTimer = nil
			questionnaireManagerInstance.clearActiveReminder()

				// Show cancellation confirmation
			showAlert(title: "Reminder Canceled", message: "Your reminder has been canceled.")
			return
		}

			// Schedule a 30-second reminder
		let scheduledTime = Date().addingTimeInterval(30)
		let newReminderId = ReminderManager.shared.scheduleTestReminder(
			title: "Test Reminder",
			body: "Your 30-second test reminder is here!",
			enableCountdown: true
		)

			// Store the reminder ID immediately
		currentReminderId = newReminderId
		
		questionnaireManagerInstance.saveActiveReminder(id: newReminderId, scheduledTime: scheduledTime)
		startCountdownTimer(with: 30)
	}


	@IBAction func yesOverButtonTapped(_ sender: Any) {
		print("yesOverButtonTapped")
		questionnaireManagerInstance.saveYesOver2hours(true)
		delegate?.didSelectYesOverAction(
			currentQuestion)
	}

	@IBAction func didTapExitButton(_ sender: UIButton) {
		delegate?.didSelectExitAction()
	}
}

// MARK: - ReminderManagerDelegate
extension FinalStepWithReminderView: ReminderManagerDelegate {
	func reminderManager(_ manager: ReminderManager, didScheduleReminderWithId id: String) {

		showAlert(
			title: "Test Reminder Set",
			message: "You'll get a test notification in 30 seconds!"
		)
	}

	func reminderManager(_ manager: ReminderManager, countdownUpdate seconds: Int, forReminderId id: String) {
		guard id == currentReminderId else { return }
			// updateReminderButtonTitleWithCountdown(seconds)
	}

	func reminderManager(_ manager: ReminderManager, countdownFinishedForReminderId id: String) {
		guard id == currentReminderId else { return }
		currentReminderId = nil
		updateReminderButtonTitle()
		countdownTimer?.invalidate()
		countdownTimer = nil
		questionnaireManagerInstance.clearActiveReminder()
	}

	func reminderManager(_ manager: ReminderManager, didFailWithError error: Error) {
			// Clean up on error
		currentReminderId = nil
		updateReminderButtonTitle()
		countdownTimer?.invalidate()
		countdownTimer = nil
		questionnaireManagerInstance.clearActiveReminder()

		showAlert(
			title: "Error",
			message: "Failed to set reminder: \(error.localizedDescription)"
		)
	}

	func reminderManager(_ manager: ReminderManager, permissionDenied: Bool) {
			// Clean up if permission was denied
		currentReminderId = nil
		updateReminderButtonTitle()
		countdownTimer?.invalidate()
		countdownTimer = nil
		questionnaireManagerInstance.clearActiveReminder()

		showAlert(
			title: "Permission Required",
			message: "Please enable notifications in Settings to use reminders.",
			showSettings: true
		)
	}

	func cleanup() {
		countdownTimer?.invalidate()
		countdownTimer = nil
	}
}
