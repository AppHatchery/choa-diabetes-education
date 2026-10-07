//
//  AppOnboardingManager.swift
//  choa-diabetes-education
//
//  Created by Maxwell Kapezi Jr on 21/09/2026.
//

import Foundation

class AppOnboardingManager {
    static let shared = AppOnboardingManager()

    private init() {}

    // Keys for UserDefaults
    private enum Keys {
        static let answers = "app_onboarding_answers"
        static let hasCompletedOnboarding = "app_onboarding_has_completed_onboarding"
    }

    // Every answer collected so far, keyed by question
    var answers: [AppOnboardingQuestion: AppOnboardingAnswer] {
        get {
            guard let data = UserDefaults.standard.data(forKey: Keys.answers),
                  let decoded = try? JSONDecoder().decode([AppOnboardingQuestion: AppOnboardingAnswer].self, from: data) else {
                return [:]
            }
            return decoded
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            UserDefaults.standard.set(data, forKey: Keys.answers)
        }
    }

    // Age entered during onboarding, or nil if it was skipped or isn't a whole number
    var age: Int? {
        guard case .text(let value) = answers[.age] else { return nil }
        return Int(value.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    // Children 5 and under are treated for low blood sugar below 80 mg/dL, everyone else below 70 mg/dL
    var lowBloodSugarThreshold: Int {
        if let age, age <= 5 {
            return 80
        }
        return 70
    }

    // Whether the user has been through onboarding, whether they filled it in
    // or skipped it, so it isn't offered again on every launch.
    var hasCompletedOnboarding: Bool {
        get {
            UserDefaults.standard.bool(forKey: Keys.hasCompletedOnboarding)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.hasCompletedOnboarding)
        }
    }

    // Save every collected answer and mark onboarding as complete
    func saveAnswers(_ answers: [AppOnboardingQuestion: AppOnboardingAnswer]) {
        self.answers = answers
        hasCompletedOnboarding = true
    }

    // Clear all stored onboarding data
    func clear() {
        UserDefaults.standard.removeObject(forKey: Keys.answers)
        UserDefaults.standard.removeObject(forKey: Keys.hasCompletedOnboarding)
    }
}
