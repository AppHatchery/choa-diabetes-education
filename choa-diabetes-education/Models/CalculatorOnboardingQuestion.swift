//
//  CalculatorOnboardingQuestion.swift
//  choa-diabetes-education
//
//  Created by Maxwell Kapezi Jr on 28/10/2025.
//

enum CalculatorOnboardingQuestion: Int {
    case carbRatio = 0
    case targetBloodSugar = 1
    case correctionFactor = 2
    
    var title: String {
        switch self {
        case .carbRatio:
            return "CalculatorOnboarding.CarbRatio.title".localized()
        case .targetBloodSugar:
            return "CalculatorOnboarding.TargetBloodSugar.title".localized()
        case .correctionFactor:
            return "CalculatorOnboarding.CorrectionFactor.title".localized()
        }
    }
    
    var unit: String {
        switch self {
        case .carbRatio:
            return "g/unit"
        case .targetBloodSugar:
            return "mg/dL"
        case .correctionFactor:
            return ""
        }
    }
    
    var imageName: String {
        switch self {
        case .carbRatio:
            return "will_carb_ratio_question"
        case .targetBloodSugar:
            return "will_target_blood_sugar_question"
        case .correctionFactor:
            return "will_correction_factor_question"
        }
    }
    
    var next: CalculatorOnboardingQuestion? {
        return CalculatorOnboardingQuestion(rawValue: self.rawValue + 1)
    }
}
