//
//  AppDelegate.swift
//  choa-diabetes-education
//
//  Created by Yago Arconada on 8/4/22.
//

import UIKit
import CoreData
import Pendo
import FirebaseCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func applicationDidBecomeActive(_ application: UIApplication) {
        func handleReminderRestoration() {
            // Reset the check flag so HomeViewController checks again
            UNUserNotificationCenter.current().delegate = ReminderManager.shared
            HomeViewController.resetReminderCheck()
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        UNUserNotificationCenter.current().delegate = ReminderManager.shared
        print("✅ AppDelegate: Set UNUserNotificationCenter delegate to ReminderManager")
		
//		let appearance = UINavigationBarAppearance()
//		appearance.backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
//		appearance.backButtonAppearance.highlighted.titleTextAttributes = [.foregroundColor: UIColor.clear]
//		UINavigationBar.appearance().standardAppearance = appearance
//		UINavigationBar.appearance().scrollEdgeAppearance = appearance

        // Override point for customization after application launch.
        let appKey = "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJkYXRhY2VudGVyIjoidXMiLCJrZXkiOiJiMDlhYTE4MjM0MjQ3NWEwYWQzOGQwZGEzYmU2MmQzYWQyNDg3ZGM4MTFmYjUyNTJiOTIxMmM0MDZlODU4ZWMzM2RmYWQyN2U0YjliNzMxYTgyNjk2Yjc0NGIxMmY0M2FkOWQ1M2M0YmE4ZjA5YzI2OWRhM2YwMjExYWQ0YzZkMjgwNjAwNzk2NDNhZThkY2ZlY2IxZWE2ODVhYTUxMTM5YTE1ZmFmZGNiYWE1Y2UyN2Q5ZmYwMDg5MjRjNjhhZWY5MGEyZDNiZDZkMWYzY2E2MmE3YzU3MmQ2OTNiNDNkYjcyMzVmNDU1MTFlOGRhODA5YzAyNmFkMTgxMzFhY2MwYmZjMmQ2YjQ2N2JiOTc3MjIzODU1YjVjMTcwZGY3MGIuOWU5MDNkMDEzOTkzYWRhOWE1OTk4NWUzMGYyMDI0N2MuYWJlYzQ5NTgzNjE2OTA2M2M4OGIwMGI1NWM4MWQ3ODQ4ZjZkYWYzZThhYzRiMTdmOWExYzhhNmJiMjJhZDFjNiJ9.FjISu5oGApqJSll8TUdQV5PLg3jceYnC74VAWvhOXSO3DfvViriua6sMoygOF8vRYornQ_f-cTxLTAf3M7EhanqBhVrYUAOIsd83nDPrYTxIc0TLzzpfb634WTSVNomhgXqc2IUyx3AnlLTJ-TYRH3h5_ilDZ0Ns_w85zv_ymeI"
        PendoManager.shared().setup(appKey)

        // Set up Pendo
        let accountId = "TypeU-Test"
        let visitorIdKey = "visitorId"
        
        // Get or create visitor ID
        // Existing users keep their past ID, new users get tagged with current month/year
        let visitorId: String
        if let existingId = UserDefaults.standard.string(forKey: visitorIdKey) {
            visitorId = existingId
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMyy" // e.g., "Feb26"
            let dateTag = dateFormatter.string(from: Date())
            visitorId = "Pilot-\(dateTag)-\(UUID())"
            UserDefaults.standard.set(visitorId, forKey: visitorIdKey)
        }
        
        // Launch Pendo session
        PendoManager.shared().startSession(
            visitorId,
            accountId: accountId,
            visitorData: [:],
            accountData: [:]
        )
        
        // Save app version on file for future update changes
        let appVersionKey = "PreviousAppVersion"
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String

        UserDefaults.standard.set(currentVersion, forKey: appVersionKey)
        
        FirebaseApp.configure()

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        
        UNUserNotificationCenter.current().delegate = ReminderManager.shared
        print("✅ Set UNUserNotificationCenter delegate (scene)")

        
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "choa_diabetes_education")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

