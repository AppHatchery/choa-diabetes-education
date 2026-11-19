//
//  NotificationHandler.swift
//  choa-diabetes-education
//
//  Created by Maxwell Kapezi Jr on 12/10/2025.
//

import UIKit
import UserNotifications

class NotificationHandler {
    
    static let shared = NotificationHandler()
    
    private init() {}

    /// The iLet reminder page a 90-minute reminder was set from, and the iLet stage and ketone result at the time.
    /// The stage is missing for reminders scheduled before it was recorded.
    struct ILetReminder {
        let questionId: Int
        let iLetStage: ILetStage?
        let ketoneSeverity: KetoneSeverity?
    }

    private struct Tap {
        let isLowBloodSugarRecheck: Bool
        let lowBloodSugarTreatments: Int?
        let iLetReminder: ILetReminder?
    }

    /// A tap that arrived before Home was on screen, as when the notification launches a closed app
    private var pendingTap: Tap?
    
    /// - Parameters:
    ///   - isLowBloodSugarRecheck: Whether the notification was the 15-minute low blood sugar recheck
    ///   - lowBloodSugarTreatments: Treatments given when the recheck was scheduled
    ///   - iLetReminder: Set when the notification was the iLet 90-minute reminder
    ///   - scene: The scene to open the reminder page in; when it isn't connected yet the tap waits for Home
    func handleNotificationTap(identifier: String, isLowBloodSugarRecheck: Bool, lowBloodSugarTreatments: Int? = nil, iLetReminder: ILetReminder? = nil, in scene: UIWindowScene?) {
        let tap = Tap(isLowBloodSugarRecheck: isLowBloodSugarRecheck, lowBloodSugarTreatments: lowBloodSugarTreatments, iLetReminder: iLetReminder)
        DispatchQueue.main.async {
            self.navigateToReminderPage(for: tap, in: scene)
        }
    }

    /// Called once Home appears, to finish a tap that came in while the app was still launching
    func handlePendingTap(in scene: UIWindowScene?) {
        guard let tap = pendingTap else { return }
        pendingTap = nil
        navigateToReminderPage(for: tap, in: scene)
    }

    /// Whether a tap is waiting for Home, so Home doesn't also reopen the reminder page
    var hasPendingTap: Bool {
        pendingTap != nil
    }
    
    private func navigateToReminderPage(for tap: Tap, in scene: UIWindowScene?) {
        print("🧭 Starting navigation to reminder page")
        
        // Get the key window
        guard let windowScene = scene,
              let window = windowScene.keyWindow ?? windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            print("⏳ No window yet, handling the tap once Home appears")
            pendingTap = tap
            return
        }
                
        // Find the navigation controller
        var navigationController: UINavigationController?
        
        if let tabBarController = rootViewController as? UITabBarController {
            navigationController = tabBarController.selectedViewController as? UINavigationController
        } else if let navController = rootViewController as? UINavigationController {
            navigationController = navController
        }
        
        // Home is the root of the navigation stack. Before it's there (still launching, or still onboarding), wait for it.
        guard let navController = navigationController, navController.viewControllers.first is HomeViewController else {
            print("⏳ Home isn't showing yet, handling the tap once it appears")
            pendingTap = tap
            return
        }
                
        // Low blood sugar reminders recheck for vomiting, loss of consciousness and the reading, rather than ketones.
        // The notification says which kind it is, since the treatment screen is gone if the app was relaunched.
        // Reminders scheduled before notifications carried that fall back to looking for the treatment screen.
        let isLowBloodSugarReminder = tap.isLowBloodSugarRecheck || navController.viewControllers.contains { controller in
            guard let questionId = (controller as? GetHelpViewController)?.questionObj.questionId else { return false }
            return FinalQuestionId(id: questionId).isLowBloodSugarTreatment
        }

        // The screens about to be popped hold the visit history the recheck routing depends on
        QuestionnaireManager.instance.carryVisitCountsPastStack()

        // The notification also carries the treatment count, so a relaunch can't start the count over
        // and keep treating instead of escalating
        if isLowBloodSugarReminder, let treatments = tap.lowBloodSugarTreatments {
            QuestionnaireManager.instance.carryLowBloodSugarTreatments(atLeast: treatments)
        }
        // The notification also carries the iLet stage, so the recheck continues from the right steps
        // even if the saved session didn't survive the app being closed
        if !isLowBloodSugarReminder, let iLetReminder = tap.iLetReminder, let stage = iLetReminder.iLetStage {
            QuestionnaireManager.instance.restoreILetSnapshot(
                ILetSnapshot(stage: stage, ketoneSeverity: iLetReminder.ketoneSeverity)
            )
        }

        // The reminder has gone off, so Home shouldn't reopen its page
        ReminderPersistence.clearReminderState()
        
        // Pop to root
        navController.popToRootViewController(animated: false)
        
        // Small delay to ensure pop completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Get the home view controller
            guard navController.viewControllers.first is HomeViewController else {
                return
            }

            // iLet picks the next step from the stage the reminder page was on (after disconnecting the pump it
            // checks blood sugar before ketones), so it goes through the same routing as tapping Start Test there.
            if !isLowBloodSugarReminder, let iLetReminder = tap.iLetReminder {
                self.continueFromILetReminderPage(questionId: iLetReminder.questionId, on: navController)
                return
            }
            
            // Create the reminder question
            let manager = QuestionnaireManager.instance
            let reminderQuestion = isLowBloodSugarReminder
                ? manager.createLowBloodSugarRecheckQuestion()
                : manager.createRecheckKetoneStage(
                    questionId: FinalQuestionId.recheckKetoneLevel.id,
                    title: "GetHelp.Que.CheckChildsKetoneLevel.title".localized()
                )
                        
            // Create GetHelpViewController using the storyboard instantiation method
            let storyboard = UIStoryboard(name: "GetHelp", bundle: nil)
            
            // Instantiate using the custom initializer closure (no cast needed)
            let getHelpVC = storyboard.instantiateViewController(
                identifier: String(describing: GetHelpViewController.self),
                creator: { coder in
                    return GetHelpViewController(
                        navVC: navController,
                        currentQuestion: reminderQuestion,
                        coder: coder
                    )
                }
            )
            
            print("✅ Created GetHelpViewController, pushing...")
            navController.pushViewController(getHelpVC, animated: true)
        }
    }

    /// Puts the iLet reminder page back on the stack and continues from it as if its countdown had
    /// finished and Start Test was tapped, so backing out returns to it just like the Skip path.
    private func continueFromILetReminderPage(questionId: Int, on navController: UINavigationController) {
        let manager = QuestionnaireManager.instance
        let reminderQuestion = manager.createFinalStageWithReminder(
            questionId: questionId,
            title: "You can manage this at home by following these steps:"
        )
        manager.prepareToReshowReminderPage(reminderQuestion)
        // Set now rather than when the page appears: it's covered by the recheck before it ever shows
        reminderQuestion.iLetSnapshot = manager.iLetSnapshot

        let reminderVC = UIStoryboard(name: "GetHelp", bundle: nil).instantiateViewController(
            identifier: String(describing: GetHelpViewController.self),
            creator: { coder in
                GetHelpViewController(navVC: navController, currentQuestion: reminderQuestion, coder: coder)
            }
        )
        navController.pushViewController(reminderVC, animated: false)

        // What the reminder page does when Start Test is tapped after the countdown
        manager.saveYesOver2hours(true)
        manager.actionsDelegate = reminderVC
        reminderVC.didSelectYesOverAction(reminderQuestion)
    }
}
