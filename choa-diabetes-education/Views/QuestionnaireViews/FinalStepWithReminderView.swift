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

	@IBOutlet var hydrationExampleInfoTextView: UITextView!

	@IBOutlet var doneButton: UIButton!


	private var currentQuestion: Questionnaire!

	private let questionnaireManagerInstance: QuestionnaireManager = QuestionnaireManager.instance

	weak var delegate: FinalStepWithReminderViewProtocol?

		// Reference to the parent view controller for showing alerts
	weak var viewController: UIViewController?

	private var currentReminderId: String?

	private var countdownTimer: Timer?

	private var reminderIsActive = ReminderManager.shared.hasActiveReminder

	private var countdownFinished: Bool = false

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

		hydrationExampleInfoTextView.setText("Final.HydrationExampleInfo.text".localized(), boldPhrases: ["blood sugar is 150 or lower", "blood sugar is over 150"])

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
		reminderButton
			.setTitleWithStyle(
				"Remind Me",
				font: .gothamRoundedMedium20,
				color: .white,
				image: UIImage(named: "ic_alarm"),
				imagePlacement: .left
			)

		reminderButton.backgroundColor = .primaryBlue
		reminderButton.layer.borderWidth = 0
		reminderButton.tintColor = .white
		reminderButton.titleLabel?.textColor = .white

		if reminderIsActive {
			reminderNextCheckDescriptionLabel.text = "Final.ReminderNextCheckDescription.text".localized()
			reminderNextCheckDescriptionLabel.textColor = .black
			reminderNextCheckDescriptionLabel.font = .gothamRoundedMedium20
		} else {
			if questionnaireManagerInstance.iLetPump {
				reminderNextCheckDescriptionLabel.setText("Final.ReminderNextCheckDescriptionForIlet.text".localized(), boldPhrases: ["blood sugar", "ketones", "90 mins"])

				reminderNextCheckDescriptionLabel.textColor = .black
			} else {
				reminderNextCheckDescriptionLabel.setText("Final.ReminderNextCheckDescription.text".localized(), boldPhrases: ["blood sugar", "ketones", "2 hours"])

				reminderNextCheckDescriptionLabel.textColor = .black
			}
		}
	}

	private func updateReminderViewsWithCountdown(_ seconds: Int) {
		let timeText = formatCountdownTime(seconds)

		reminderView.backgroundColor = .veryLightGreen

		reminderButton.setTitleWithStyle("Skip This Reminder", font: .gothamRoundedMedium20, color: .primaryBlue)
		reminderButton.backgroundColor = .clear
		reminderButton.tintColor = .primaryBlue
		reminderButton.layer.borderWidth = 1
		reminderButton.layer.borderColor = UIColor.primaryBlue.cgColor

		reminderNextCheckLabel.text = "Final.ReminderNextCheckIn.text".localized()

		reminderNextCheckDescriptionLabel.text = timeText
		reminderNextCheckDescriptionLabel.textColor = .choaGreenColor
		reminderNextCheckDescriptionLabel.font = .gothamRoundedBold32
	}

	private func updateViewsWhenCountdownFinished() {
		reminderView.backgroundColor = .veryLightGreen
		reminderNextCheckLabel.isHidden = true
		reminderNextCheckDescriptionLabel.text = "Final.ReminderTimeToCheck.text".localized()
		reminderNextCheckDescriptionLabel.textColor = .choaGreenColor
		reminderNextCheckDescriptionLabel.font = .gothamRoundedBold32

		reminderButton
			.setTitleWithStyle(
				"Start Test",
				font: .gothamRoundedMedium20,
				color: .whiteColor,
				image: UIImage(named: "leftArrow"),
				imagePlacement: .right
			)
		reminderButton.backgroundColor = .choaGreenColor
		reminderButton.tintColor = .white
		reminderButton.layer.borderWidth = 1
		reminderButton.layer.borderColor = UIColor.choaGreenColor.cgColor
	}

	private func formatCountdownTime(_ seconds: Int) -> String {
		if seconds >= 3600 {
			let hours = seconds / 3600
			let minutes = (seconds % 3600) / 60
			let secs = seconds % 60
//			return String(format: "%dh %dm %ds", hours, minutes, secs)
			return String(format: "%dh %dm", hours, minutes)
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
		guard ReminderManager.shared.hasActiveReminder,
			  let reminderId = ReminderManager.shared.currentReminderId,
			  let remainingTime = ReminderManager.shared.currentReminderRemainingTime else {
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
		updateReminderViewsWithCountdown(remainingSeconds)

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
				self.updateViewsWhenCountdownFinished()
				self.countdownFinished = true
				questionnaireManagerInstance.clearActiveReminder()
			} else {
				self.updateReminderViewsWithCountdown(remainingSeconds)
			}
		}
	}

	@IBAction func remindMeButtonTapped(_ sender: UIButton) {
			// If reminder already exists, cancel it
		if let existingId = currentReminderId {
			questionnaireManagerInstance.saveYesOver2hours(true)
			delegate?.didSelectYesOverAction(
				currentQuestion)

			ReminderManager.shared.cancelReminder(withIdentifier: existingId)
			currentReminderId = nil
			updateReminderButtonTitle()
			countdownTimer?.invalidate()
			countdownTimer = nil
			questionnaireManagerInstance.clearActiveReminder()
			ReminderManager.shared.cancelAllReminders()

			reminderView.backgroundColor = .veryLightBlue
			return
		}

		if countdownFinished {
			countdownFinished = false

			reminderView.backgroundColor = .veryLightBlue
			reminderNextCheckLabel.text = "Final.ReminderNextCheck.text".localized()
			reminderNextCheckLabel.isHidden = false

			reminderNextCheckDescriptionLabel.font = .systemFont(ofSize: 14)
			reminderNextCheckDescriptionLabel.textColor = .black

			if questionnaireManagerInstance.iLetPump {
				reminderNextCheckDescriptionLabel.setText("Final.ReminderNextCheckDescriptionForIlet.text".localized(), boldPhrases: ["blood sugar", "ketones", "90 mins"])
			} else {
				reminderNextCheckDescriptionLabel.setText("Final.ReminderNextCheckDescription.text".localized(), boldPhrases: ["blood sugar", "ketones", "2 hours"])
			}

			questionnaireManagerInstance.saveYesOver2hours(true)
			delegate?.didSelectYesOverAction(
				currentQuestion)
		} else {
			let duration: TimeInterval = questionnaireManagerInstance.iLetPump ? 5400 : 7200

			let scheduledTime = Date().addingTimeInterval(duration)

			let newReminderId = questionnaireManagerInstance.iLetPump ? ReminderManager.shared.schedule90MinuteReminder() :ReminderManager.shared.scheduleTwoHourReminder()

			currentReminderId = newReminderId

			questionnaireManagerInstance.saveActiveReminder(id: newReminderId, scheduledTime: scheduledTime)

			startCountdownTimer(with: Int(duration))
		}
	}


	@IBAction func yesOverButtonTapped(_ sender: Any) {
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

//		showAlert(
//			title: "Reminder Set",
//			message: questionnaireManagerInstance.iLetPump ? "You'll get a notification in 90 minutes to recheck your blood sugar and ketones." : "You'll get a notification in 2 hours to recheck your blood sugar and ketones."
//		)
	}

	func reminderManager(_ manager: ReminderManager, countdownUpdate seconds: Int, forReminderId id: String) {
		guard id == currentReminderId else { return }

		updateReminderViewsWithCountdown(seconds)
	}

	func reminderManager(_ manager: ReminderManager, countdownFinishedForReminderId id: String) {
		guard id == currentReminderId else { return }
		currentReminderId = nil
		updateReminderButtonTitle()
		countdownTimer?.invalidate()
		countdownTimer = nil
		questionnaireManagerInstance.clearActiveReminder()
		reminderIsActive = false
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
