//
//  AppOnboardingQuestion.swift
//  choa-diabetes-education
//
//  Created by Maxwell Kapezi Jr on 21/09/2026.
//

import Foundation

enum AppOnboardingQuestionType: Equatable {
    case singleSelect([AppOnboardingOption])
    case openEndedInput(placeholder: String)
    case openEndedMultipleInput([AppOnboardingInputField])
}

struct AppOnboardingOption: Equatable {
    let id: Int
    let title: String
    let imageName: String?
}

struct AppOnboardingInputField: Equatable {
    let label: String
    let placeholder: String
}

enum AppOnboardingAnswer: Equatable {
    case selection(Int)
    case text(String)
    case multipleText([String])

    var selectedOptionId: Int? {
        if case .selection(let id) = self { return id }
        return nil
    }
}

enum AppOnboardingQuestion: CaseIterable {
    case userRole
    case isChoaPatient
    case whichChoa
    case whereYouGetCare
    case whichSchool
    case diabetesType
    case age
    case diagnosisTime

    var title: String {
        switch self {
        case .userRole:
            return "AppOnboarding.UserRole.title".localized()
        case .isChoaPatient:
            return "AppOnboarding.IsChoaPatient.title".localized()
        case .whichChoa:
            return "AppOnboarding.WhichChoa.title".localized()
        case .whereYouGetCare:
            return "AppOnboarding.WhereYouGetCare.title".localized()
        case .whichSchool:
            return "AppOnboarding.WhichSchool.title".localized()
        case .diabetesType:
            return "AppOnboarding.DiabetesType.title".localized()
        case .age:
            return "AppOnboarding.Age.title".localized()
        case .diagnosisTime:
            return "AppOnboarding.DiagnosisTime.title".localized()
        }
    }

    var subtitle: String? {
        switch self {
        case .userRole:
            return "AppOnboarding.UserRole.subtitle".localized()
        default:
            return nil
        }
    }

    var type: AppOnboardingQuestionType {
        switch self {
        case .userRole:
            return .singleSelect([
                AppOnboardingOption(id: 0, title: "AppOnboarding.UserRole.option1".localized(), imageName: "onboarding_user_diabetes"),
                AppOnboardingOption(id: 1, title: "AppOnboarding.UserRole.option2".localized(), imageName: "onboarding_user_caregiver"),
                AppOnboardingOption(id: 2, title: "AppOnboarding.UserRole.option3".localized(), imageName: "onboarding_user_nurse")
            ])
        case .isChoaPatient:
            return .singleSelect([
                AppOnboardingOption(id: 0, title: "AppOnboarding.IsChoaPatient.option1".localized(), imageName: nil),
                AppOnboardingOption(id: 1, title: "AppOnboarding.IsChoaPatient.option2".localized(), imageName: nil)
            ])
        case .whichChoa:
            return .singleSelect([
                AppOnboardingOption(id: 0, title: "AppOnboarding.WhichChoa.option1".localized(), imageName: nil),
                AppOnboardingOption(id: 1, title: "AppOnboarding.WhichChoa.option2".localized(), imageName: nil),
                AppOnboardingOption(id: 2, title: "AppOnboarding.WhichChoa.option3".localized(), imageName: nil)
            ])
        case .whereYouGetCare:
            return .openEndedMultipleInput([
                AppOnboardingInputField(label: "AppOnboarding.WhereYouGetCare.hospitalLabel".localized(), placeholder: "AppOnboarding.WhereYouGetCare.hospitalPlaceholder".localized()),
                AppOnboardingInputField(label: "AppOnboarding.WhereYouGetCare.countyLabel".localized(), placeholder: "AppOnboarding.WhereYouGetCare.countyPlaceholder".localized()),
                AppOnboardingInputField(label: "AppOnboarding.WhereYouGetCare.stateLabel".localized(), placeholder: "AppOnboarding.WhereYouGetCare.statePlaceholder".localized())
            ])
        case .whichSchool:
            return .openEndedMultipleInput([
                AppOnboardingInputField(label: "AppOnboarding.WhichSchool.nameLabel".localized(), placeholder: "AppOnboarding.WhichSchool.namePlaceholder".localized()),
                AppOnboardingInputField(label: "AppOnboarding.WhichSchool.stateLabel".localized(), placeholder: "AppOnboarding.WhichSchool.statePlaceholder".localized()),
                AppOnboardingInputField(label: "AppOnboarding.WhichSchool.zipLabel".localized(), placeholder: "AppOnboarding.WhichSchool.zipPlaceholder".localized())
            ])
        case .diabetesType:
            return .singleSelect([
                AppOnboardingOption(id: 0, title: "AppOnboarding.DiabetesType.option1".localized(), imageName: nil),
                AppOnboardingOption(id: 1, title: "AppOnboarding.DiabetesType.option2".localized(), imageName: nil),
                AppOnboardingOption(id: 2, title: "AppOnboarding.DiabetesType.option3".localized(), imageName: nil)
            ])
        case .age:
            return .openEndedInput(placeholder: "AppOnboarding.Age.placeholder".localized())
        case .diagnosisTime:
            return .singleSelect([
                AppOnboardingOption(id: 0, title: "AppOnboarding.DiagnosisTime.option1".localized(), imageName: nil),
                AppOnboardingOption(id: 1, title: "AppOnboarding.DiagnosisTime.option2".localized(), imageName: nil),
                AppOnboardingOption(id: 2, title: "AppOnboarding.DiagnosisTime.option3".localized(), imageName: nil),
                AppOnboardingOption(id: 3, title: "AppOnboarding.DiagnosisTime.option4".localized(), imageName: nil),
                AppOnboardingOption(id: 4, title: "AppOnboarding.DiagnosisTime.option5".localized(), imageName: nil),
                AppOnboardingOption(id: 5, title: "AppOnboarding.DiagnosisTime.option6".localized(), imageName: nil),
                AppOnboardingOption(id: 6, title: "AppOnboarding.DiagnosisTime.option7".localized(), imageName: nil)
            ])
        }
    }

    /// Determines the next question, branching on the option the user selected
    /// (ignored for questions that only have one path forward).
    func next(selectedOptionId: Int?) -> AppOnboardingQuestion? {
        switch self {
        case .userRole:
            switch selectedOptionId {
            case 2:
                return .whichSchool
            default:
                return .isChoaPatient
            }
        case .isChoaPatient:
            switch selectedOptionId {
            case 1:
                return .whereYouGetCare
            default:
                return .whichChoa
            }
        case .whichChoa:
            return .diabetesType
        case .whereYouGetCare:
            return .diabetesType
        case .whichSchool:
            return nil
        case .diabetesType:
            return .age
        case .age:
            return .diagnosisTime
        case .diagnosisTime:
            return nil
        }
    }

    /// Determines the previous question, branching on the option the user selected
    /// on that prior question.
    func previous(previousSelectedOptionId: Int?) -> AppOnboardingQuestion? {
        switch self {
        case .userRole:
            return nil
        case .isChoaPatient:
            return .userRole
        case .whichChoa:
            return .isChoaPatient
        case .whereYouGetCare:
            return .isChoaPatient
        case .whichSchool:
            return .userRole
        case .diabetesType:
            switch previousSelectedOptionId {
            case 1:
                return .whereYouGetCare
            default:
                return .whichChoa
            }
        case .age:
            return .diabetesType
        case .diagnosisTime:
            return .age
        }
    }
}
