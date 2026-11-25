//
//  AppOnboardingManager.swift
//  choa-diabetes-education
//
//  Created by Maxwell Kapezi Jr on 21/09/2026.
//

import Foundation
import Pendo

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

    // Whether "I'm a school nurse" was picked as the user role
    var isSchoolNurse: Bool {
        answers[.userRole]?.selectedOptionId == 2
    }

    // Whether the user gets care at CHOA, or nil if the question was skipped or never asked (school nurses)
    var isChoaPatient: Bool? {
        guard let id = answers[.isChoaPatient]?.selectedOptionId else { return nil }
        return id == 0
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

    // MARK: - Analytics

    /// Age groups reported to Pendo instead of the exact age, as the youngest age in each group, lowest first.
    /// Each group runs up to the next one's youngest age, and the last has no upper limit, so every age has a group.
    /// Only the report uses these; the stored age the protocols read is untouched.
    static let ageGroups: [(youngestAge: Int, label: String)] = [
        (0, "0-5"),
        (6, "6-12"),
        (13, "13-17"),
        (18, "18+")
    ]

    static func ageGroup(for age: Int) -> String {
        // Ages are whole numbers of 0 or more, so the first group always matches
        (ageGroups.last { age >= $0.youngestAge } ?? ageGroups[0]).label
    }

    /// Sends the onboarding answers to Pendo as one "Onboarding" event. Questions that weren't asked on the
    /// user's path (e.g. school for a parent) are left out rather than sent empty.
    func trackOnboarding() {
        var properties: [String: Any] = [:]

        func optionTitle(_ question: AppOnboardingQuestion) -> String? {
            guard case .singleSelect(let options) = question.type,
                  let id = answers[question]?.selectedOptionId else { return nil }
            return options.first { $0.id == id }?.title
        }

        func textValue(_ question: AppOnboardingQuestion, at index: Int) -> String? {
            guard case .multipleText(let values)? = answers[question], index < values.count else { return nil }
            let value = values[index].trimmingCharacters(in: .whitespacesAndNewlines)
            return value.isEmpty ? nil : value
        }

        properties["userRole"] = optionTitle(.userRole)
        properties["isChoaPatient"] = optionTitle(.isChoaPatient)
        if isChoaPatient == true {
            properties["whichChoa"] = optionTitle(.whichChoa)
        }
        properties["diabetesType"] = optionTitle(.diabetesType)
        properties["diagnosisTime"] = optionTitle(.diagnosisTime)
        properties["ageGroup"] = age.map(Self.ageGroup(for:))

        // whereYouGetCare fields: hospital, county, state. whichSchool fields: name, state, ZIP code.
        properties["whereYouGetCare"] = textValue(.whereYouGetCare, at: 0)
        properties["whichSchool"] = textValue(.whichSchool, at: 0)
        properties["zipCode"] = textValue(.whichSchool, at: 2)
        properties["state"] = textValue(.whereYouGetCare, at: 2) ?? textValue(.whichSchool, at: 1)

        PendoManager.shared().track("Onboarding", properties: properties)
    }

    // Clear all stored onboarding data
    func clear() {
        UserDefaults.standard.removeObject(forKey: Keys.answers)
        UserDefaults.standard.removeObject(forKey: Keys.hasCompletedOnboarding)
    }
}
