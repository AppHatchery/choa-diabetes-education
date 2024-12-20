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
import FirebaseAnalytics

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let appKey = "eyJhbGciOiJSUzI1NiIsImtpZCI6IiIsInR5cCI6IkpXVCJ9.eyJkYXRhY2VudGVyIjoidXMiLCJrZXkiOiIyZWU3M2U5OGZhZWU0YmE2ZjIzZDllNzZmNTFiYzllMTRiZGZmYTFhNjIwNjcwZmUwNzJlMjkzNWFhNTQ5YzgxNTU2NTE5N2UwOWVmNTU0MzA0ZWY5NmYxZWNiNDkyYzg0ZWNjNDM0ZjVkMDE2NGE1ZTMxZDk4YmQ5ZDVjZjExNi4wNzFjODA5YzhkYTc2OThiZTU0OWU1YjRkOGNmZTBkOS4wYzE2MjA1NjFkODMyOTExNmIwYjJkNmIwNDIwOGE1Zjk3ZmIwOWJlZTYyYjZiNWYyZTUzNTQxOTg5NDIzNGRjIn0.UKO49xBA1FKCsxv3TKrxqGTG2CjF3NbjEZBcIxOK0zE9bNWNPIuQr2aBpUKoUMS-rhbZyFxAUlmG4kkPPgKK1jaY5iooUbLW9_PE6EV4jCrnWjffsC3b1v9TrN5cSLlb8UE_Gf2hZZh3HH11AY5gfMgedKyG0B-MWFWmEAw9kcw"
        PendoManager.shared().setup(appKey)

        // Set up Pendo
        // TODO: Add firebase installation
        // Set visitor as "" to anonymize the entries
        // Set visitor as weekly cohorts
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "mm"
        
         // Could use Cohorts in the future to track patients
        let accountId = "TypeU-Pilot" // TypeU-Beta for testing
        // Use TypeU-Release when the educators give the go and we start bringing in patients
        // Potentially also use Pendo Guides to answer, are you a CHOA patient?

        let key = "visitorId"
        let firstLaunchDateKey = "FirstLaunchDate"

        if UserDefaults.standard.value(forKey: firstLaunchDateKey) == nil {
            UserDefaults.standard.set(Date(), forKey: firstLaunchDateKey)
        }
        
        let targetDateComponents = DateComponents(year: 2023, month: 9, day: 1)
        let calendar = Calendar.current

        // Check if the first launch date is before our target date, to try to collect as many non-Pilot people as possible
        if let firstLaunchDate = UserDefaults.standard.object(forKey: firstLaunchDateKey) as? Date,
           let targetDate = calendar.date(from: targetDateComponents) {
           
            // If first launch is earlier than Sep 1st then it's a Tester
           if firstLaunchDate < targetDate {
               // User opened the app before September 1st
               if UserDefaults.standard.string(forKey: key) == nil {
                   let visitorId = "Tester-May23-\(UUID())"
                   UserDefaults.standard.set(visitorId, forKey: key)
               }
               // If first launch is on or after Sep 1st it's likely to be a pilot
           } else {
               // User opened the app on or after September 1st
               if UserDefaults.standard.string(forKey: key) == nil {
                   let visitorId = "Pilot-Sep23-\(UUID())"
                   UserDefaults.standard.set(visitorId, forKey: key)
               }
           }
        }
        
        // Launch Pendo connection
        if let visitorId = UserDefaults.standard.string(forKey: key) {
            PendoManager.shared().startSession(
                 visitorId,
                 accountId: accountId,
                 visitorData: [:],
                 accountData: [:]
             )
        } else {
            PendoManager.shared().startSession(
                 "",
                 accountId: accountId,
                 visitorData: [:],
                 accountData: [:]
             )
        }
        
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

