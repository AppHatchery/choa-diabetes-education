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

	private let questionnaireManager: QuestionnaireManager = QuestionnaireManager.instance

	weak var delegate: FinalStepWithReminderViewProtocol?

		// Reference to the parent view controller for showing alerts
	weak var viewController: UIViewController?

	private var currentReminderId: String?

	private var countdownTimer: Timer?

	private var reminderIsActive = ReminderManager.shared.hasActiveReminder

	private var countdownFinished: Bool = false
    
    private var isObservingNotifications = false

	override func didMoveToWindow() {
		super.didMoveToWindow()
		if window != nil {
            if !isObservingNotifications {
                NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(handleReminderNotificationTapped),
                    name: NSNotification.Name("ReminderNotificationTapped"),
                    object: nil
                )
                isObservingNotifications = true
            }
				// View is being added to hierarchy - restore state
			restoreReminderState()
		} else {
				// View is being removed - clean up
			countdownTimer?.invalidate()
			countdownTimer = nil
		}
	}
    
    @objc private func handleReminderNotificationTapped(_ notification: Notification) {
        guard let reminderId = notification.object as? String,
              reminderId == currentReminderId else {
            return
        }
        
        print("🔔 Notification tapped while on reminder page")
        
        // Update UI to show "Time to Check" state
        countdownFinished = true
        updateViewsWhenCountdownFinished()
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
        if isObservingNotifications {
            NotificationCenter.default.removeObserver(self)
        }
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
        setupCommonUI(currentQuestion: currentQuestion)

        switch questionnaireManager.currentTestType {
        case .insulinShots:
            setupForInsulinShots()
        case .pump:
            if questionnaireManager.iLetPump {
                setupForPumpWithIlet()
            } else {
                setupForPump()
            }
        }

        // IMPORTANT: Restore reminder state AFTER UI setup
        // but check if we need to restore or use current state
        print("🔍 Checking for reminder state...")
            
        if let persistedState = ReminderPersistence.loadReminderState() {
            let remainingTime = persistedState.scheduledTime.timeIntervalSince(Date())
            print("📱 Found persisted state, remaining: \(Int(remainingTime))s")
            if remainingTime > 0 {
                // Restore from persisted state
                if !isObservingNotifications {
                    NotificationCenter.default.addObserver(
                        self,
                        selector: #selector(handleReminderNotificationTapped),
                        name: NSNotification.Name("ReminderNotificationTapped"),
                        object: nil
                    )
                    isObservingNotifications = true
                }
                
                restoreReminderState()
            } else {
                // Expired, clean up and show default
                ReminderPersistence.clearReminderState()
                updateReminderButtonTitle()
            }
        } else if ReminderManager.shared.hasActiveReminder {
            // Has active reminder in memory (user navigated back)
            print("💾 Found active reminder in memory")
            restoreReminderState()
        } else {
            // No active reminder at all
            print("🆕 No active reminder, showing default state")
            updateReminderButtonTitle()
        }
    }

    // MARK: - Common UI Setup
    private func setupCommonUI(currentQuestion: Questionnaire) {
        titleLabel.font = .gothamRoundedBold20
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .natural

        titleLabel.text = questionnaireManager.currentTestType == .insulinShots
            ? "Calculator.Final.ContinueRegularCare.title".localized().capitalizedFirstLetter
            : currentQuestion.finalStep?.title

        reminderView.layer.cornerRadius = 12
        reminderButton.layer.cornerRadius = 12
        doneButton.setTitleWithStyle("Exit", font: .gothamRoundedMedium20)

        yesOver2hoursButton.layer.cornerRadius = 12
        yesOver2hoursButton.layer.borderWidth = 0
        yesOver2hoursButton.layer.borderColor = UIColor.primaryBlue.cgColor

        let yesOverText = questionnaireManager.iLetPump
            ? "Yes, Over 90 mins"
            : "Yes, Over 2hrs"
        yesOver2hoursButton.setTitleWithStyle(yesOverText, font: .gothamRoundedMedium20)

        giveRecommendedDoseLabel.setText(
            "Final.GiveRecommendedDose.text".localized(),
            boldPhrases: ["correction dose through", "pump site"]
        )

        hydrationExampleInfoTextView.setText(
            "Final.HydrationExampleInfo.text".localized(),
            boldPhrases: ["blood sugar is 150 or lower", "blood sugar is over 150"]
        )
    }

    // MARK: - Insulin Shots
    private func setupForInsulinShots() {
        confirmChangeDisconnectStackView.isHidden = true
        giveRecommendedDoseStackView.isHidden = true

        reminderNextCheckLabel.text = "Final.ReminderNextCheck.text".localized()
        reminderNextCheckDescriptionLabel.setText(
            "Final.ReminderNextCheckDescription.text".localized(),
            boldPhrases: ["blood sugar", "ketones", "2 hours"]
        )
        reminderTimeCheckLabel.setText(
            "Final.ReminderTimeCheck.text".localized(),
            boldPhrases: ["2 hours"]
        )
    }

    // MARK: - Pump (Non-iLet)
    private func setupForPump() {
        confirmChangeDisconnectLabel.setText(
            "Final.ConfirmPumpIsSecure.text".localized(),
            boldPhrases: ["pump site is securely connected"]
        )
        hopeImage.isHidden = true

        reminderNextCheckLabel.text = "Final.ReminderNextCheck.text".localized()
        reminderNextCheckDescriptionLabel.setText(
            "Final.ReminderNextCheckDescription.text".localized(),
            boldPhrases: ["blood sugar", "ketones", "2 hours"]
        )
        reminderTimeCheckLabel.setText(
            "Final.ReminderTimeCheck.text".localized(),
            boldPhrases: ["2 hours"]
        )

    //    flipHydrationAndReminder()
    }

    // MARK: - Pump + iLet
    private func setupForPumpWithIlet() {
        let visitCount = questionnaireManager.getReminderPageVisitCount()
        let skippedFirst = questionnaireManager.skipFirstReminder
        
        print("🏥 Setting up iLet pump view")
        print("   - Visit count: \(visitCount)")
        print("   - Skipped first reminder: \(skippedFirst)")
        print("   - Blood ketones: \(String(describing: questionnaireManager.bloodKetones))")
        print("   - Urine ketones: \(String(describing: questionnaireManager.urineKetones))")
        
        confirmChangeDisconnectImage.image = UIImage(named: "ilet_pump")
        
        // Ketone level checks
        let hasModerateUrineKetones = questionnaireManager.urineKetones == .zeroPointFive ||
        questionnaireManager.urineKetones == .onePointFive ||
        questionnaireManager.urineKetones == .four
        
        let hasHighUrineKetones = questionnaireManager.urineKetones == .eight ||
        questionnaireManager.urineKetones == .sixteen
        
        let hasModerateBloodKetones = questionnaireManager.bloodKetones == .moderate
        let hasHighBloodKetones = questionnaireManager.bloodKetones == .large
        
        let hasAnyElevatedKetones = hasModerateUrineKetones || hasHighUrineKetones ||
                                    hasModerateBloodKetones || hasHighBloodKetones
        
        // Decision tree for what action to show
        var shouldDisconnect = false
        var shouldChangeSite = false
        
        // CRITICAL: Check more specific conditions FIRST (higher visit counts before lower)
        
        if !skippedFirst && visitCount >= 2 && hasAnyElevatedKetones {
            shouldDisconnect = true
            shouldChangeSite = false
            print("   → Path 1: DISCONNECT (didn't skip + visit ≥2 + elevated ketones)")
        } else if skippedFirst && (hasHighUrineKetones || hasHighBloodKetones) {
            shouldDisconnect = true
            shouldChangeSite = false
            print("   → Path 2: DISCONNECT (skipped first + high ketones)")
        } else if skippedFirst && visitCount >= 1 && (
            hasModerateUrineKetones || hasModerateBloodKetones
        ) {
            shouldDisconnect = true
            shouldChangeSite = false
        } else if skippedFirst && (hasModerateUrineKetones || hasModerateBloodKetones) {
            shouldDisconnect = false
            shouldChangeSite = true
            print("   → Path 3: CHANGE SITE (skipped first + moderate ketones)")
        } else if !skippedFirst && visitCount >= 1 && (hasHighUrineKetones || hasHighBloodKetones) {
            shouldDisconnect = true
            shouldChangeSite = false
            print("   → Path 4: DISCONNECT (visit ≥1 + high ketones)")
        } else if !skippedFirst && visitCount >= 1 && (hasModerateUrineKetones || hasModerateBloodKetones) {
            shouldDisconnect = false
            shouldChangeSite = true
            print("   → Path 5: CHANGE SITE (visit ≥1 + moderate ketones)")
        } else {
            shouldDisconnect = false
            shouldChangeSite = false
            print("   → Path 6: CONFIRM SECURE (default/negative ketones)")
        }
        
        // Apply the decision
        if shouldDisconnect {
            confirmChangeDisconnectLabel.setText(
                "Final.DisconnectIletPump.text".localized(),
                boldPhrases: ["Disconnect", "pump"]
            )
            giveRecommendedDoseStackView.isHidden = false
            
            giveRecommendedDoseLabel.setText(
                "Final.CalculateAndGiveCorrectionDose.text".localized(),
                boldPhrases: ["correction dose", "rapid-acting", "insulin pen", "syringe"]
            )
            print("   ✅ Action: DISCONNECT PUMP")
        } else if shouldChangeSite {
            confirmChangeDisconnectLabel.setText(
                "Final.ChangeIletPumpSite.text".localized(),
                boldPhrases: ["Change", "pump site"]
            )
            giveRecommendedDoseStackView.isHidden = true
            print("   ✅ Action: CHANGE PUMP SITE")
        } else {
            // Default: confirm pump is secure (low/negative ketones)
            confirmChangeDisconnectLabel.setText(
                "Final.ConfirmPumpIsSecure.text".localized(),
                boldPhrases: ["pump site is securely connected"]
            )
            giveRecommendedDoseStackView.isHidden = false
            print("   ✅ Action: CONFIRM PUMP SECURE")
        }
        
        // Set reminder text
        reminderNextCheckLabel.text = "Final.ReminderNextCheckForIlet.text".localized()
        reminderNextCheckDescriptionLabel.setText(
            "Final.ReminderNextCheckDescriptionForIlet.text".localized(),
            boldPhrases: ["blood sugar", "ketones", "90 mins"]
        )
        reminderTimeCheckLabel.setText(
            "Final.ReminderTimeCheckForIlet.text".localized(),
            boldPhrases: ["90 minutes"]
        )
        hopeImage.isHidden = true
    }
    
    func refreshUIForVisitCount() {
        guard questionnaireManager.iLetPump else { return }
        
        let visitCount = questionnaireManager.getReminderPageVisitCount()
        print("🔄 Refreshing UI for visit count: \(visitCount)")
        
        setupForPumpWithIlet()
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
			if questionnaireManager.iLetPump {
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
        // First check if we have a persisted reminder state
        if let persistedState = ReminderPersistence.loadReminderState() {
            // Calculate remaining time
            let remainingTime = persistedState.scheduledTime.timeIntervalSince(Date())
            
            if remainingTime > 0 {
                // Set the current reminder ID
                currentReminderId = persistedState.reminderId
                reminderIsActive = true
                
                // Make sure ReminderManager has this reminder
                let resumed = ReminderManager.shared.resumeCountdown(for: persistedState.reminderId)
                
                if resumed {
                    // Start the local countdown timer with the remaining time
                    startCountdownTimer(with: Int(remainingTime))
                    
                    print("✅ Restored reminder: \(persistedState.reminderId), remaining: \(Int(remainingTime))s")
                } else {
                    // Reminder expired during restore
                    print("⚠️ Failed to resume reminder: \(persistedState.reminderId)")
                    currentReminderId = nil
                    reminderIsActive = false
                    updateReminderButtonTitle()
                    ReminderPersistence.clearReminderState()
                }
                
                return
            } else {
                // Reminder has expired, clean up
                print("⏰ Reminder expired")
                ReminderPersistence.clearReminderState()
            }
        }
        
        // Fallback: check ReminderManager directly (in case user just navigated back)
        guard ReminderManager.shared.hasActiveReminder,
              let reminderId = ReminderManager.shared.currentReminderId,
              let remainingTime = ReminderManager.shared.currentReminderRemainingTime else {
            print("ℹ️ No active reminder found")
            currentReminderId = nil
            reminderIsActive = false
            updateReminderButtonTitle()
            return
        }

        print("✅ Found active reminder in memory: \(reminderId)")
        currentReminderId = reminderId
        reminderIsActive = true
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
				questionnaireManager.clearActiveReminder()
			} else {
				self.updateReminderViewsWithCountdown(remainingSeconds)
			}
		}
	}

	@IBAction func remindMeButtonTapped(_ sender: UIButton) {
			// If reminder already exists, cancel it
		if let existingId = currentReminderId {
			questionnaireManager.saveYesOver2hours(true)
			delegate?.didSelectYesOverAction(
				currentQuestion)

			ReminderManager.shared.cancelReminder(withIdentifier: existingId)
			currentReminderId = nil
			updateReminderButtonTitle()
			countdownTimer?.invalidate()
			countdownTimer = nil
			questionnaireManager.clearActiveReminder()
			ReminderManager.shared.cancelAllReminders()
            
            ReminderPersistence.clearReminderState()

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

			if questionnaireManager.iLetPump {
				reminderNextCheckDescriptionLabel.setText("Final.ReminderNextCheckDescriptionForIlet.text".localized(), boldPhrases: ["blood sugar", "ketones", "90 mins"])
			} else {
				reminderNextCheckDescriptionLabel.setText("Final.ReminderNextCheckDescription.text".localized(), boldPhrases: ["blood sugar", "ketones", "2 hours"])
			}

			questionnaireManager.saveYesOver2hours(true)
			delegate?.didSelectYesOverAction(
				currentQuestion)
            
            ReminderPersistence.clearReminderState()
		} else {
			let duration: TimeInterval = questionnaireManager.iLetPump ? 5400 : 7200

			let scheduledTime = Date().addingTimeInterval(duration)

            let newReminderId = questionnaireManager.iLetPump ? ReminderManager.shared.schedule90MinuteReminder() :ReminderManager.shared.scheduleTwoHourReminder()

			currentReminderId = newReminderId

			questionnaireManager.saveActiveReminder(id: newReminderId, scheduledTime: scheduledTime)
            
            // Save reminder state to persist across app restarts
            ReminderPersistence.saveReminderState(
                reminderId: newReminderId,
                scheduledTime: scheduledTime,
                questionId: currentQuestion.questionId,
                manager: questionnaireManager
            )

			startCountdownTimer(with: Int(duration))
		}
	}


	@IBAction func yesOverButtonTapped(_ sender: Any) {
		questionnaireManager.saveYesOver2hours(true)
        ReminderPersistence.clearReminderState()
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
//			message: questionnaireManager.iLetPump ? "You'll get a notification in 90 minutes to recheck your blood sugar and ketones." : "You'll get a notification in 2 hours to recheck your blood sugar and ketones."
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
		questionnaireManager.clearActiveReminder()
		reminderIsActive = false
	}

	func reminderManager(_ manager: ReminderManager, didFailWithError error: Error) {
			// Clean up on error
		currentReminderId = nil
		updateReminderButtonTitle()
		countdownTimer?.invalidate()
		countdownTimer = nil
		questionnaireManager.clearActiveReminder()
        ReminderPersistence.clearReminderState()

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
		questionnaireManager.clearActiveReminder()
        ReminderPersistence.clearReminderState()

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
