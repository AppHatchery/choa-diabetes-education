//
//  RemoteConfigManager.swift
//  choa-diabetes-education
//
//  Created by Maxwell Kapezi Jr on 19/10/2026.
//

import Foundation
import FirebaseRemoteConfig

extension Notification.Name {
    /// Posted on the main thread whenever the `halloweenTheme` value changes.
    static let halloweenThemeDidChange = Notification.Name("halloweenThemeDidChange")
}

final class RemoteConfigManager {

    static let shared = RemoteConfigManager()

    // Keys for Remote Config and UserDefaults
    private enum Keys {
        static let halloweenTheme = "halloweenTheme"
    }

    private let remoteConfig = RemoteConfig.remoteConfig()
    private var configUpdateListener: ConfigUpdateListenerRegistration?

    /// The last known `halloweenTheme` value, persisted so it's available before the first fetch completes.
    private(set) var isHalloweenThemeEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: Keys.halloweenTheme) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.halloweenTheme) }
    }

    private init() {
        // Fall back to the stored value until Remote Config returns something
        remoteConfig.setDefaults([Keys.halloweenTheme: NSNumber(value: isHalloweenThemeEnabled)])
    }

    /// Fetches the latest values and starts listening for real-time updates.
    /// Call once after `FirebaseApp.configure()`.
    func start() {
        Task {
            do {
                _ = try await remoteConfig.fetchAndActivate()
                updateStoredValues()
            } catch {
                print("Remote Config fetch failed: \(error.localizedDescription)")
            }
        }

        guard configUpdateListener == nil else { return }

        configUpdateListener = remoteConfig.addOnConfigUpdateListener { [weak self] configUpdate, error in
            guard let self else { return }

            if let error {
                print("Remote Config update listener failed: \(error.localizedDescription)")
                return
            }

            guard configUpdate?.updatedKeys.contains(Keys.halloweenTheme) == true else { return }

            self.remoteConfig.activate { _, error in
                if let error {
                    print("Remote Config activate failed: \(error.localizedDescription)")
                    return
                }
                self.updateStoredValues()
            }
        }
    }

    /// Copies the active Remote Config values into UserDefaults and notifies observers of changes.
    private func updateStoredValues() {
        let newValue = remoteConfig.configValue(forKey: Keys.halloweenTheme).boolValue
        guard newValue != isHalloweenThemeEnabled else { return }

        isHalloweenThemeEnabled = newValue

        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .halloweenThemeDidChange, object: nil)
        }
    }
}
