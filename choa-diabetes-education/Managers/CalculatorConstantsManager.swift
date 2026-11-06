//
//  CalculatorConstantsManager.swift
//  choa-diabetes-education
//
//  Created by Maxwell Kapezi Jr on 25/09/2025.
//

import Foundation

extension Notification.Name {
    /// Posted on the main thread after the calculator constants or rounding rule are saved or cleared
    static let calculatorConstantsDidChange = Notification.Name("calculatorConstantsDidChange")
}

class CalculatorConstantsManager {
    static let shared = CalculatorConstantsManager()
    
    private init() {}
    
    // Keys for UserDefaults
    private enum Keys {
        static let carbRatio = "calculator_carb_ratio"
        static let targetBloodSugar = "calculator_target_blood_sugar"
        static let correctionFactor = "calculator_correction_factor"
        static let hasStoredConstants = "calculator_has_stored_constants"
        static let hasCompletedOnboarding = "calculator_has_completed_onboarding"
        static let roundingRule = "calculator_rounding_rule"
    }
    
    // Carb Ratio
    var carbRatio: Int {
        get {
            return UserDefaults.standard.integer(forKey: Keys.carbRatio)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.carbRatio)
            UserDefaults.standard.set(true, forKey: Keys.hasStoredConstants)
        }
    }
    
    // Target Blood Sugar
    var targetBloodSugar: Int {
        get {
            return UserDefaults.standard.integer(forKey: Keys.targetBloodSugar)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.targetBloodSugar)
            UserDefaults.standard.set(true, forKey: Keys.hasStoredConstants)
        }
    }
    
    // Correction Factor
    var correctionFactor: Int {
        get {
            return UserDefaults.standard.integer(forKey: Keys.correctionFactor)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.correctionFactor)
            UserDefaults.standard.set(true, forKey: Keys.hasStoredConstants)
        }
    }
    
    // Rounding Rule. Whole unit until one is chosen, which covers skipping calculator onboarding
    // and constants saved before this was added. Not part of `hasStoredConstants`.
    var roundingRule: InsulinRoundingRule {
        get {
            guard let rawValue = UserDefaults.standard.object(forKey: Keys.roundingRule) as? Int else { return .wholeUnit }
            return InsulinRoundingRule(rawValue: rawValue) ?? .wholeUnit
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: Keys.roundingRule)
        }
    }
    
    // Check if any constant is stored. They can be saved one at a time from the edit screen,
    // so callers check the value they need is above 0 before using it.
    var hasStoredConstants: Bool {
        return UserDefaults.standard.bool(forKey: Keys.hasStoredConstants) &&
               (carbRatio > 0 || targetBloodSugar > 0 || correctionFactor > 0)
    }
    
    // Whether the user has been through calculator onboarding, whether they
    // filled it in or skipped it. Tracked separately from the constants so a
    // skipped onboarding isn't offered again on every visit.
    var hasCompletedOnboarding: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.hasCompletedOnboarding)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.hasCompletedOnboarding)
        }
    }
    
    // Save all constants at once
    func saveConstants(carbRatio: Int, targetBloodSugar: Int, correctionFactor: Int, roundingRule: InsulinRoundingRule) {
        self.carbRatio = carbRatio
        self.targetBloodSugar = targetBloodSugar
        self.correctionFactor = correctionFactor
        self.roundingRule = roundingRule
        self.hasCompletedOnboarding = true

        postConstantsDidChange()
    }

    /// Lets calculators already on screen recalculate with the new values and rounding rule
    private func postConstantsDidChange() {
        if Thread.isMainThread {
            NotificationCenter.default.post(name: .calculatorConstantsDidChange, object: self)
        } else {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .calculatorConstantsDidChange, object: self)
            }
        }
    }
    
    // Clear all constants
    func clearConstants() {
        UserDefaults.standard.removeObject(forKey: Keys.carbRatio)
        UserDefaults.standard.removeObject(forKey: Keys.targetBloodSugar)
        UserDefaults.standard.removeObject(forKey: Keys.correctionFactor)
        UserDefaults.standard.removeObject(forKey: Keys.hasStoredConstants)
        UserDefaults.standard.removeObject(forKey: Keys.hasCompletedOnboarding)
        UserDefaults.standard.removeObject(forKey: Keys.roundingRule)

        postConstantsDidChange()
    }
    
    // Get constants as tuple
    func getConstants() -> (carbRatio: Int, targetBloodSugar: Int, correctionFactor: Int) {
        return (carbRatio, targetBloodSugar, correctionFactor)
    }
}
