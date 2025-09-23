//
//  ReminderManager.swift
//  choa-diabetes-education
//
//  Created by Maxwell Kapezi Jr on 25/08/2025.
//

import Foundation
import UserNotifications
import UIKit

protocol ReminderManagerDelegate: AnyObject {
	func reminderManager(_ manager: ReminderManager, didScheduleReminderWithId id: String)
	func reminderManager(_ manager: ReminderManager, didFailWithError error: Error)
	func reminderManager(_ manager: ReminderManager, permissionDenied: Bool)
	func reminderManager(_ manager: ReminderManager, countdownUpdate seconds: Int, forReminderId id: String)
	func reminderManager(_ manager: ReminderManager, countdownFinishedForReminderId id: String)
}

class ReminderManager: NSObject {

		// MARK: - Properties
	static let shared = ReminderManager()
	weak var delegate: ReminderManagerDelegate?

	private let notificationCenter = UNUserNotificationCenter.current()
	private var countdownTimers: [String: Timer] = [:]
	private var reminderScheduleTimes: [String: Date] = [:]

		// MARK: - Initialization
	private override init() {
		super.init()
		notificationCenter.delegate = self
	}

		// MARK: - Public Methods

		/// Request notification permissions from the user
	func requestPermissions() {
		notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
			DispatchQueue.main.async {
				if let error = error {
					self?.delegate?.reminderManager(self!, didFailWithError: error)
				} else if !granted {
					self?.delegate?.reminderManager(self!, permissionDenied: true)
				}
			}
		}
	}

		/// Schedule a reminder for a specific time interval
		/// - Parameters:
		///   - timeInterval: Time in seconds from now
		///   - title: Notification title
		///   - body: Notification body
		///   - identifier: Optional custom identifier. If nil, a unique one will be generated
		///   - enableCountdown: Whether to start a countdown timer for this reminder
		/// - Returns: The identifier of the scheduled reminder
	@discardableResult
	func scheduleReminder(
		in timeInterval: TimeInterval,
		title: String,
		body: String,
		identifier: String? = nil,
		enableCountdown: Bool = false
	) -> String {

		let reminderIdentifier = identifier ?? "reminder-\(UUID().uuidString)"

			// Check permission first
		notificationCenter.getNotificationSettings { [weak self] settings in
			guard let self = self else { return }

			DispatchQueue.main.async {
				switch settings.authorizationStatus {
				case .authorized, .provisional:
					self.createAndScheduleNotification(
						identifier: reminderIdentifier,
						timeInterval: timeInterval,
						title: title,
						body: body
					)

						// Start countdown if enabled
					if enableCountdown {
						self.startCountdown(for: reminderIdentifier, duration: timeInterval)
					}

				case .denied:
					self.delegate?.reminderManager(self, permissionDenied: true)
				case .notDetermined:
					self.requestPermissions()
				case .ephemeral:
					self.createAndScheduleNotification(
						identifier: reminderIdentifier,
						timeInterval: timeInterval,
						title: title,
						body: body
					)

					if enableCountdown {
						self.startCountdown(for: reminderIdentifier, duration: timeInterval)
					}
				@unknown default:
					let error = NSError(domain: "ReminderManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown authorization status"])
					self.delegate?.reminderManager(self, didFailWithError: error)
				}
			}
		}

		return reminderIdentifier
	}

		/// Schedule a 2-hour reminder (convenience method)
		/// - Parameters:
		///   - title: Notification title
		///   - body: Notification body
		///   - enableCountdown: Whether to start a countdown timer for this reminder
		/// - Returns: The identifier of the scheduled reminder
	@discardableResult
	func scheduleTwoHourReminder(title: String = "Time to check!", body: String = "Time to test your blood sugar and ketones.", enableCountdown: Bool = true) -> String {
		return scheduleReminder(in: 7200, title: title, body: body, enableCountdown: enableCountdown) // 2 hours = 7200 seconds
	}

		/// Schedule a 90-minute reminder (convenience method)
		/// - Parameters:
		///   - title: Notification title
		///   - body: Notification body
		///   - enableCountdown: Whether to start a countdown timer for this reminder
		/// - Returns: The identifier of the scheduled reminder
	@discardableResult
	func schedule90MinuteReminder(title: String = "Time to check!", body: String = "Time to test your blood sugar and ketones.", enableCountdown: Bool = true) -> String {
		return scheduleReminder(in: 5400, title: title, body: body, enableCountdown: enableCountdown) // 90 minutes = 5400 seconds
	}

		/// Schedule a 30-second test reminder (convenience method for testing)
		/// - Parameters:
		///   - title: Notification title
		///   - body: Notification body
		///   - enableCountdown: Whether to start a countdown timer for this reminder
		/// - Returns: The identifier of the scheduled reminder
	@discardableResult
	func scheduleTestReminder(title: String = "Test Reminder", body: String = "Your 30-second test reminder is here!", enableCountdown: Bool = true) -> String {
		return scheduleReminder(in: 30, title: title, body: body, enableCountdown: enableCountdown) // 30 seconds for testing
	}

		/// Cancel a specific reminder
		/// - Parameter identifier: The identifier of the reminder to cancel
	func cancelReminder(withIdentifier identifier: String) {
		notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])

			// Stop and remove countdown timer if it exists
		stopCountdown(for: identifier)
	}

		/// Cancel all pending reminders
	func cancelAllReminders() {
		notificationCenter.removeAllPendingNotificationRequests()

			// Stop all countdown timers
		stopAllCountdowns()
	}

		/// Get reminder info for a specific identifier
		/// - Parameter identifier: The reminder identifier
		/// - Returns: Tuple with scheduled time and time interval, or nil if not found
	func getReminderInfo(for identifier: String) -> (scheduledTime: Date, duration: TimeInterval)? {
		guard let scheduledTime = reminderScheduleTimes[identifier] else { return nil }

			// Calculate original duration from current time to scheduled time
		let currentTime = Date()
		let timeRemaining = scheduledTime.timeIntervalSince(currentTime)

		if timeRemaining > 0 {
			return (scheduledTime, timeRemaining)
		}

		return nil
	}

		/// Check if a reminder is currently active
		/// - Parameter identifier: The reminder identifier
		/// - Returns: True if reminder exists and is still pending
	func isReminderActive(identifier: String) -> Bool {
		return reminderScheduleTimes[identifier] != nil && countdownTimers[identifier] != nil
	}

		/// Resume countdown for an existing reminder (useful when returning to a view)
		/// - Parameter identifier: The reminder identifier to resume
		/// - Returns: True if countdown was resumed, false if reminder not found or expired
	@discardableResult
	func resumeCountdown(for identifier: String) -> Bool {
		guard let scheduledTime = reminderScheduleTimes[identifier] else { return false }

		let currentTime = Date()
		let timeRemaining = scheduledTime.timeIntervalSince(currentTime)

		if timeRemaining > 0 {
				// Restart countdown timer if it's not already running
			if countdownTimers[identifier] == nil {
				startCountdown(for: identifier, duration: timeRemaining)
			}
			return true
		} else {
				// Reminder has expired, clean up
			stopCountdown(for: identifier)
			return false
		}
	}

		// MARK: - Private Methods

	private func startCountdown(for identifier: String, duration: TimeInterval) {
			// Store the schedule time
		reminderScheduleTimes[identifier] = Date().addingTimeInterval(duration)

			// Create and start countdown timer
		let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
			guard let self = self,
				  let scheduleTime = self.reminderScheduleTimes[identifier] else {
				timer.invalidate()
				return
			}

			let currentTime = Date()
			let timeRemaining = scheduleTime.timeIntervalSince(currentTime)

			if timeRemaining <= 0 {
					// Countdown finished
				timer.invalidate()
				self.countdownTimers.removeValue(forKey: identifier)
				self.reminderScheduleTimes.removeValue(forKey: identifier)
				self.delegate?.reminderManager(self, countdownFinishedForReminderId: identifier)
			} else {
					// Update countdown
				let secondsRemaining = Int(ceil(timeRemaining))
				self.delegate?.reminderManager(self, countdownUpdate: secondsRemaining, forReminderId: identifier)
			}
		}

		countdownTimers[identifier] = timer
	}

	private func stopCountdown(for identifier: String) {
		countdownTimers[identifier]?.invalidate()
		countdownTimers.removeValue(forKey: identifier)
		reminderScheduleTimes.removeValue(forKey: identifier)
	}

	private func stopAllCountdowns() {
		countdownTimers.values.forEach { $0.invalidate() }
		countdownTimers.removeAll()
		reminderScheduleTimes.removeAll()
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

	private func createAndScheduleNotification(
		identifier: String,
		timeInterval: TimeInterval,
		title: String,
		body: String
	) {
			// Create notification content
		let content = UNMutableNotificationContent()
		content.title = title
		content.body = body
		content.sound = UNNotificationSound.default
		content.badge = 1

			// Create time interval trigger
		let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)

			// Create notification request
		let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

			// Schedule the notification
		notificationCenter.add(request) { [weak self] error in
			DispatchQueue.main.async {
				guard let self = self else { return }

				if let error = error {
					self.delegate?.reminderManager(self, didFailWithError: error)
				} else {
					self.delegate?.reminderManager(self, didScheduleReminderWithId: identifier)
				}
			}
		}
	}
}

	// MARK: - UNUserNotificationCenterDelegate
extension ReminderManager: UNUserNotificationCenterDelegate {

		/// Called when a notification is about to be presented while the app is in foreground
	func userNotificationCenter(
		_ center: UNUserNotificationCenter,
		willPresent notification: UNNotification,
		withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
	) {
			// Show notification even when app is in foreground
		completionHandler([.banner, .sound, .badge])
	}

		/// Called when user interacts with a notification
	func userNotificationCenter(
		_ center: UNUserNotificationCenter,
		didReceive response: UNNotificationResponse,
		withCompletionHandler completionHandler: @escaping () -> Void
	) {
		let identifier = response.notification.request.identifier

			// Handle notification tap - you can customize this behavior
		print("User tapped on reminder with ID: \(identifier)")

		UIApplication.shared.applicationIconBadgeNumber = 0

		completionHandler()
	}

		/// Computed property to check if there's an active reminder
	var hasActiveReminder: Bool {
		return !countdownTimers.isEmpty
	}

		/// Get the current active reminder ID (since we only allow one)
	var currentReminderId: String? {
		return countdownTimers.keys.first
	}

		/// Get remaining time for the current active reminder
	var currentReminderRemainingTime: TimeInterval? {
		guard let reminderId = currentReminderId,
			  let scheduledTime = reminderScheduleTimes[reminderId] else {
			return nil
		}

		let timeRemaining = scheduledTime.timeIntervalSince(Date())
		return timeRemaining > 0 ? timeRemaining : nil
	}

		/// Get complete info about the current active reminder
	var currentReminderInfo: (id: String, remainingTime: TimeInterval)? {
		guard let id = currentReminderId,
			  let remainingTime = currentReminderRemainingTime else {
			return nil
		}
		return (id: id, remainingTime: remainingTime)
	}

		/// Cancel the current active reminder (convenience method)
	func cancelCurrentReminder() {
		if let reminderId = currentReminderId {
			cancelReminder(withIdentifier: reminderId)
		}
	}

		/// Get formatted time string for current reminder
	var currentReminderTimeString: String? {
		guard let remainingTime = currentReminderRemainingTime else {
			return nil
		}
		return formatCountdownTime(Int(remainingTime))
	}
}
