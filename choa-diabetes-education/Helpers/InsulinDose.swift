//
//  InsulinDose.swift
//  choa-diabetes-education
//
//  Created by Maxwell Kapezi Jr on 23/10/2026.
//

import Foundation

/// How a calculated insulin dose is rounded, as recommended by the diabetes care team.
/// Rounding happens once, on the final dose: for meals + correction the exact parts are added first.
enum InsulinRoundingRule: Int, CaseIterable {
    case halfUnit = 0
    case wholeUnit = 1

    var title: String {
        switch self {
        case .halfUnit: return "CalculatorOnboarding.RoundingRule.halfUnit".localized()
        case .wholeUnit: return "CalculatorOnboarding.RoundingRule.wholeUnit".localized()
        }
    }

    var subtitle: String {
        switch self {
        case .halfUnit: return "CalculatorOnboarding.RoundingRule.halfUnit.subtitle".localized()
        case .wholeUnit: return "CalculatorOnboarding.RoundingRule.wholeUnit.subtitle".localized()
        }
    }

    /// Steps per unit of insulin
    fileprivate var stepsPerUnit: Int {
        switch self {
        case .halfUnit: return 2
        case .wholeUnit: return 1
        }
    }
}

/// An insulin dose kept as an exact fraction of units, so adding doses together isn't
/// affected by floating-point error before the final dose is rounded.
struct InsulinDose {
    let numerator: Int
    let denominator: Int

    static let zero = InsulinDose(numerator: 0, denominator: 1)

    /// Insulin for food: total carbs ÷ carb ratio
    static func food(totalCarbs: Int, carbRatio: Int) -> InsulinDose {
        guard carbRatio > 0 else { return .zero }
        return InsulinDose(numerator: totalCarbs, denominator: carbRatio)
    }

    /// Insulin for high blood sugar: (blood sugar − target) ÷ correction factor.
    /// None is needed when blood sugar is at or below target.
    static func correction(bloodSugar: Int, targetBloodSugar: Int, correctionFactor: Int) -> InsulinDose {
        guard correctionFactor > 0, bloodSugar > targetBloodSugar else { return .zero }
        return InsulinDose(numerator: bloodSugar - targetBloodSugar, denominator: correctionFactor)
    }

    /// a/b + c/d = (a·d + c·b) / (b·d)
    static func + (lhs: InsulinDose, rhs: InsulinDose) -> InsulinDose {
        InsulinDose(
            numerator: lhs.numerator * rhs.denominator + rhs.numerator * lhs.denominator,
            denominator: lhs.denominator * rhs.denominator
        )
    }

    var exactUnits: Float {
        guard denominator > 0 else { return 0 }
        return Float(numerator) / Float(denominator)
    }

    /// Rounds to the nearest step, halfway rounding up.
    /// Whole unit: .5 and up rounds up. Half unit: up to .24 rounds down, .25–.74 goes to .5, .75 and up rounds up.
    /// Integer math keeps the boundaries exact, so a dose of exactly 10.25 isn't read as 10.2499.
    func roundedUnits(using rule: InsulinRoundingRule) -> Float {
        guard denominator > 0 else { return 0 }
        let steps = (2 * rule.stepsPerUnit * numerator + denominator) / (2 * denominator)
        return Float(steps) / Float(rule.stepsPerUnit)
    }

    /// "2.34 units" for a part that's rounded later as part of a total, otherwise the rounded "2.5 units"
    func displayText(rounded: Bool, using rule: InsulinRoundingRule) -> String {
        let units = rounded ? roundedUnits(using: rule).cleanString : exactUnits.preciseString
        return "\(units) units"
    }
}
