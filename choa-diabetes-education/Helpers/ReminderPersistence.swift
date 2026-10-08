//
//  ReminderPersistence.swift
//  choa-diabetes-education
//
//  Created by Maxwell Kapezi Jr on 12/10/2025.
//


import Foundation
import UIKit

class ReminderPersistence {
    
    private static let reminderStateKey = "activeReminderState"
    
    struct ReminderState: Codable {
        let reminderId: String
        let scheduledTime: Date
        let questionId: Int
        
        // The whole Get Help session as it was when the reminder was set
        let session: GetHelpSession
    }
    
    /// Save the current reminder and questionnaire state
    static func saveReminderState(
        reminderId: String,
        scheduledTime: Date,
        questionId: Int,
        manager: QuestionnaireManager,
    ) {
        let state = ReminderState(
            reminderId: reminderId,
            scheduledTime: scheduledTime,
            questionId: questionId,
            session: manager.session
        )
        
        if let encoded = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(encoded, forKey: reminderStateKey)
        }
    }
    
    /// Retrieve the saved reminder state
    static func loadReminderState() -> ReminderState? {
        guard let data = UserDefaults.standard.data(forKey: reminderStateKey),
              let state = try? JSONDecoder().decode(ReminderState.self, from: data) else {
            return nil
        }
        
        // Check if reminder is still valid (not expired)
        if state.scheduledTime > Date() {
            return state
        } else {
            // Clean up expired reminder
            clearReminderState()
            return nil
        }
    }
    
    /// Clear the saved reminder state
    static func clearReminderState() {
        UserDefaults.standard.removeObject(forKey: reminderStateKey)
    }
    
    /// Check if there's an active reminder
    static func hasActiveReminder() -> Bool {
        return loadReminderState() != nil
    }
    
    /// Navigate to the FinalStepWithReminder page
    static func navigateToReminderPage(from viewController: UIViewController, state: ReminderState) {
        let manager = QuestionnaireManager.instance
        
        // Create the questionnaire object for reminder page
        let question = manager.createFinalStageWithReminder(
            questionId: state.questionId,
            title: "You can manage this at home by following these steps:"
        )
        
        // Restore questionnaire state
        manager.restoreSession(state.session, reshowing: question)
        
        // Restore the reminder in ReminderManager
        ReminderManager.shared.restoreReminderFromPersistence()
        
        // Get the navigation controller
        guard let navigationController = viewController.navigationController else { return }
        
        // Create GetHelpViewController
        let getHelpVC = UIStoryboard(name: "GetHelp", bundle: nil)
            .instantiateViewController(identifier: String(describing: GetHelpViewController.self)) { creator in
                GetHelpViewController(
                    navVC: navigationController,
                    currentQuestion: question,
                    coder: creator
                )
            }
        
        // Push to the view controller
        navigationController.pushViewController(getHelpVC, animated: true)
    }
}
