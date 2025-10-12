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
        
        // Store questionnaire manager state
        let testType: String?
        let measuringMethod: String?
        let calculationType: String?
        let bloodSugarOver300: Bool
        let bloodSugarOver300For3Hours: Bool
        let urineKetoneLevel: String?
        let bloodKetoneLevel: String?
        let iLetPump: Bool
        let yesOver2hours: Bool
        let cgm: Bool
        let bloodSugar: Int
        let correctionFactor: Int
    }
    
    /// Save the current reminder and questionnaire state
    static func saveReminderState(
        reminderId: String,
        scheduledTime: Date,
        questionId: Int,
        manager: QuestionnaireManager
    ) {
        let state = ReminderState(
            reminderId: reminderId,
            scheduledTime: scheduledTime,
            questionId: questionId,
            testType: {
                switch manager.currentTestType {
                case .pump: return "pump"
                case .insulinShots: return "insulinShots"
                }
            }(),
            measuringMethod: {
                switch manager.currentMeasuringMethod {
                case .urineKetone: return "urineKetone"
                case .bloodKetone: return "bloodKetone"
                }
            }(),
            calculationType: {
                switch manager.currentMethod {
                case .formula: return "formula"
                case .scale: return "scale"
                }
            }(),
            bloodSugarOver300: manager.bloodSugarOver300,
            bloodSugarOver300For3Hours: manager.bloodSugarOver300For3Hours,
            urineKetoneLevel: {
                guard let level = manager.urineKetones else { return nil }
                switch level {
                case .negative: return "negative"
                case .zeroPointFive: return "zeroPointFive"
                case .onePointFive: return "onePointFive"
                case .four: return "four"
                case .eight: return "eight"
                case .sixteen: return "sixteen"
                }
            }(),
            bloodKetoneLevel: {
                guard let level = manager.bloodKetones else { return nil }
                switch level {
                case .low: return "low"
                case .moderate: return "moderate"
                case .large: return "large"
                }
            }(),
            iLetPump: manager.iLetPump,
            yesOver2hours: manager.yesOver2hours,
            cgm: manager.cgm,
            bloodSugar: manager.bloodSugar,
            correctionFactor: manager.correctionFactor
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
    
    /// Restore questionnaire manager state from saved reminder
    static func restoreQuestionnaireState(manager: QuestionnaireManager, from state: ReminderState) {
        // Restore test type
        if let testTypeStr = state.testType {
            let testType: TestType = testTypeStr == "pump" ? .pump : .insulinShots
            manager.saveTestType(testType)
        }
        
        // Restore measuring method
        if let methodStr = state.measuringMethod {
            let method: MeasuringType = methodStr == "urineKetone" ? .urineKetone : .bloodKetone
            manager.saveMeasuringMethod(method)
        }
        
        // Restore calculation type
        if let calcTypeStr = state.calculationType {
            let calcType: CalculationType = calcTypeStr == "formula" ? .formula : .scale
            manager.saveCalculationType(calcType)
        }
        
        // Restore blood sugar data
        manager.saveBloodSugarOver300(state.bloodSugarOver300)
        manager.saveBloodSugarOver300For3Hours(state.bloodSugarOver300For3Hours)
        manager.saveData(bloodSugar: state.bloodSugar, correctionFactor: state.correctionFactor)
        
        // Restore ketone levels
        if let urineStr = state.urineKetoneLevel {
            let level: UrineKetoneLevel
            switch urineStr {
            case "negative": level = .negative
            case "zeroPointFive": level = .zeroPointFive
            case "onePointFive": level = .onePointFive
            case "four": level = .four
            case "eight": level = .eight
            case "sixteen": level = .sixteen
            default: level = .negative
            }
            manager.saveUrineKetoneLevel(level: level)
        }
        
        if let bloodStr = state.bloodKetoneLevel {
            let level: BloodKetoneLevel
            switch bloodStr {
            case "low": level = .low
            case "moderate": level = .moderate
            case "large": level = .large
            default: level = .low
            }
            manager.saveBloodKetoneLevel(level: level)
        }
        
        // Restore other flags
        manager.saveILetPump(state.iLetPump)
        manager.saveYesOver2hours(state.yesOver2hours)
        manager.saveCGM(state.cgm)
    }
    
    /// Navigate to the FinalStepWithReminder page
    static func navigateToReminderPage(from viewController: UIViewController, state: ReminderState) {
        let manager = QuestionnaireManager.instance
        
        // Restore questionnaire state
        restoreQuestionnaireState(manager: manager, from: state)
        
        // Restore the reminder in ReminderManager
        ReminderManager.shared.restoreReminderFromPersistence()
        
        // Create the questionnaire object for reminder page
        let question = manager.createFinalStageWithReminder(
            questionId: state.questionId,
            title: "You can manage this at home by following these steps:"
        )
        
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
