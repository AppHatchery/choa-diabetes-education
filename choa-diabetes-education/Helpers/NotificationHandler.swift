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
    
    func handleNotificationTap(identifier: String) {
        DispatchQueue.main.async {
            self.navigateToReminderPage()
        }
    }
    
    private func navigateToReminderPage() {
        print("🧭 Starting navigation to reminder page")
        
        // Get the key window
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) ?? windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            return
        }
                
        // Find the navigation controller
        var navigationController: UINavigationController?
        
        if let tabBarController = rootViewController as? UITabBarController {
            navigationController = tabBarController.selectedViewController as? UINavigationController
        } else if let navController = rootViewController as? UINavigationController {
            navigationController = navController
        }
        
        guard let navController = navigationController else {
            print("❌ Could not find navigation controller")
            return
        }
                
        // Pop to root
        navController.popToRootViewController(animated: false)
        
        // Small delay to ensure pop completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Get the home view controller
            guard navController.viewControllers.first is HomeViewController else {
                return
            }
            
            
            // Create the reminder question
            let manager = QuestionnaireManager.instance
            let reminderQuestion = manager.createRecheckKetoneStage(
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
}
