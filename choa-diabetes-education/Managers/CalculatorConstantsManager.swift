//
//  CalculatorConstantsManager.swift
//  choa-diabetes-education
//
//  Created by Maxwell Kapezi Jr on 25/09/2025.
//

import Foundation

class CalculatorConstantsManager {
    static let shared = CalculatorConstantsManager()
    
    private init() {}
    
    // Keys for UserDefaults
    private enum Keys {
        static let carbRatio = "calculator_carb_ratio"
        static let targetBloodSugar = "calculator_target_blood_sugar"
        static let correctionFactor = "calculator_correction_factor"
        static let hasStoredConstants = "calculator_has_stored_constants"
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
    
    // Check if constants are stored
    var hasStoredConstants: Bool {
        return UserDefaults.standard.bool(forKey: Keys.hasStoredConstants) && 
               carbRatio > 0 && targetBloodSugar > 0 && correctionFactor > 0
    }
    
    // Save all constants at once
    func saveConstants(carbRatio: Int, targetBloodSugar: Int, correctionFactor: Int) {
        self.carbRatio = carbRatio
        self.targetBloodSugar = targetBloodSugar
        self.correctionFactor = correctionFactor
    }
    
    // Clear all constants
    func clearConstants() {
        UserDefaults.standard.removeObject(forKey: Keys.carbRatio)
        UserDefaults.standard.removeObject(forKey: Keys.targetBloodSugar)
        UserDefaults.standard.removeObject(forKey: Keys.correctionFactor)
        UserDefaults.standard.removeObject(forKey: Keys.hasStoredConstants)
    }
    
    // Get constants as tuple
    func getConstants() -> (carbRatio: Int, targetBloodSugar: Int, correctionFactor: Int) {
        return (carbRatio, targetBloodSugar, correctionFactor)
    }
}
