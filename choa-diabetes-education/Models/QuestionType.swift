//
//  QuestionType.swift
//  choa-diabetes-education
//

import Foundation

enum QuestionType: Equatable {
    case yesOrNo(YesOrNoQuestionId)
    case twoOptions(TwoOptionsQuestionId)
    case multipleOptions
    case fourOptions(FourOptionsQueID)
    case multipleOptionsDescriptionAtBottom(MultipleOptionsDescriptionAtBottomQueId)
    case openEndedWithSingleInput(OpenEndedWithSingleInputQuestionId)
    case openEndedWithMultipleInput(OpenEndedWithMultipleInputQuestionId)
    case finalStep(FinalQuestionId)
}

enum YesOrNoQuestionId {
    case severeDistress
    case ketonesInNext30Mins
    case insulinThreeHours
    case bedtime
    case dehydrated
    case abdominal
    case breathing
    case vomiting
    case anyFollowing
    case moreThanFourHours
    
    
    var id: Int {
        switch self {
        case .severeDistress:
            return 1
        case .ketonesInNext30Mins:
            return 2
        case .insulinThreeHours:
            return 3
        case .bedtime:
            return 4
        case .dehydrated:
            return 5
        case .abdominal:
            return 6
        case .breathing:
            return 7
        case .vomiting:
            return 8
        case .anyFollowing:
            return 9
        case .moreThanFourHours:
            return 10
            
        }
    }
    
    init(id: Int) {
        switch id {
        case 1:
            self = .severeDistress
        case 2:
            self = .ketonesInNext30Mins
        case 3:
            self = .insulinThreeHours
        case 4:
            self = .bedtime
        case 5:
            self = .dehydrated
        case 6:
            self = .abdominal
        case 7:
            self = .breathing
        case 8:
            self = .vomiting
        case 9:
            self = .anyFollowing
        case 10:
            self = .moreThanFourHours
        default:
            self = .severeDistress
        }
    }
}

enum TwoOptionsQuestionId {
    case testType
    case ketonesMeasure
    case lastDose
    
    
    var id: Int {
        switch self {
        case .testType:
            return 1
        case .ketonesMeasure:
            return 2
        case .lastDose:
            return 3
        }
    }
    
    init(id: Int) {
        switch id {
        case 1:
            self = .testType
        case 2:
            self = .ketonesMeasure
        case 3:
            self = .lastDose
        default:
            self = .testType
        }
    }
}

enum OpenEndedWithSingleInputQuestionId {
    case lastDoseInsulin
    
    var id: Int {
        switch self {
        case .lastDoseInsulin:
            return 1
        }
    }
    
    init(id: Int) {
        switch id {
        case 1:
            self = .lastDoseInsulin
        default:
            self = .lastDoseInsulin
        }
    }
}

enum OpenEndedWithMultipleInputQuestionId {
    case bloodSugar
    
    var id: Int {
        switch self {
        case .bloodSugar:
            return 1
        }
    }
    
    init(id: Int) {
        switch id {
        case 1:
            self = .bloodSugar
        default:
            self = .bloodSugar
        }
    }
}

enum MultipleOptionsDescriptionAtBottomQueId {
    case ketonesChecked
    case bloodKetoneMeasurements
    
    
    var id: Int {
        switch self {
        case .ketonesChecked:
            return 1
        case .bloodKetoneMeasurements:
            return 8
        }
    }
    
    
    
    init(id: Int) {
        switch id {
        case 1:
            self = .ketonesChecked
        case 8:
            self = .bloodKetoneMeasurements
        default:
            self = .ketonesChecked
        }
    }
}

enum FourOptionsQueID {
    case lastBasalInjection
    var id: Int {
        switch self {
        case .lastBasalInjection:
            return 1
        }
    }
    init(id: Int) {
        switch id {
        case 1:
            self = .lastBasalInjection
        default:
            self = .lastBasalInjection
        }
    }
}

enum TwoOptionsDescriptionAtBottomId {
    case ketonesInNext30Mins
    case urineKetoneMeasurements
    
    var id: Int {
        switch self {
        case .ketonesInNext30Mins:
            return 1
        case .urineKetoneMeasurements:
            return 7
        }
    }
    
    init(id: Int) {
        switch id {
        case 1:
            self = .ketonesInNext30Mins
        case 7:
            self = .urineKetoneMeasurements
        default:
            self = .ketonesInNext30Mins
        }
    }
}




enum FinalQuestionId {
    case firstEmergencyScreen
    case endocrinologistScreen
    case endocrinologistNoDoseScreen
    case generalEmergencyScreen
    case endingScreen
    
    var stepId: Int {
        switch self {
        case .firstEmergencyScreen:
            return 1
        case .endocrinologistScreen:
            return 2
        case .endocrinologistNoDoseScreen:
            return 3
        case .generalEmergencyScreen:
            return 4
        case .endingScreen:
            return 5
        }
        
    }
    
    init(id: Int) {
        switch id {
        case 1:
            self = .firstEmergencyScreen
        case 2:
            self = .endocrinologistScreen
        case 3:
            self = .endocrinologistNoDoseScreen
        case 4:
            self = .generalEmergencyScreen
        case 5:
            self = .endingScreen
        default:
            self = .firstEmergencyScreen
        }
    }
}

enum YesOrNo {
    case yes
    case no
    
    var description: String {
        switch self {
        case .yes:
            return "Yes".localized()
        case .no:
            return "No".localized()
        }
    }
}






// MARK: Two Options


enum TwoOptionsAnswer: Equatable {
    case TestType(TestType)
    case UrineKetonesMeasurements(UrineKetonesMeasurements)
    case PumpLastDose(PumpLastDose)
    case ShotLastDose(ShotLastDose)
    
}

enum TestType {
    case pump
    case insulinShots
    
    var description: String {
        switch self {
        case .pump:
            return "Calculator.Que2.TestType.option1".localized()
        case .insulinShots:
            return "Calculator.Que2.TestType.option2".localized()
        }
    }
    
    init(id: Int) {
        switch id {
        case 1:
            self = .pump
        case 2:
            self = .insulinShots
        default:
            self = .pump
        }
    }
}



enum UrineKetonesMeasurements {
    case zeroToSmall
    case moderateToLarge
    
    var description: String {
        switch self {
        case .zeroToSmall:
            return "Calculator.Que7.KetonesMeasuring.option1".localized()
        case .moderateToLarge:
            return "Calculator.Que7.KetonesMeasuring.option2".localized()
        }
    }
    
    init(id: Int) {
        switch id {
        case 1:
            self = .zeroToSmall
        case 2:
            self = .moderateToLarge
        default:
            self = .zeroToSmall
        }
    }
}

enum PumpLastDose {
    case lessThan30
    case halfHourToTwoHours
    
    var description: String {
        switch self {
        case .lessThan30:
            return "Calculator.Que11.PumpLastDose.option1".localized()
        case .halfHourToTwoHours:
            return "Calculator.Que11.PumpLastDose.option2".localized()
        }
    }
    
    init(id: Int) {
        switch id {
        case 1:
            self = .lessThan30
        case 2:
            self = .halfHourToTwoHours
        default:
            self = .lessThan30
        }
    }
}

enum ShotLastDose {
    case lessThanHour
    case oneToThreeHours
    
    var description: String {
        switch self {
        case .lessThanHour:
            return "Calculator.Que10.ShotLastDose.option1" .localized()
        case .oneToThreeHours:
            return "Calculator.Que10.ShotLastDose.option2".localized()
        }
    }
    
    init(id: Int) {
        switch id {
        case 1:
            self = .lessThanHour
        case 2:
            self = .oneToThreeHours
        default:
            self = .lessThanHour
        }
    }
}

// MARK: Four Options

enum FourOptionsAnswer: Equatable {
    case ScheduledTime(ScheduledTime)
}
enum ScheduledTime {
    case yes
    case fourHoursLate
    case moreThanFourHours
    case notGiven
    
    var description: String {
        switch self {
        case .yes:
            return "Calculator.Que19.ShotOnTime.option1".localized()
        case .fourHoursLate:
            return "Calculator.Que19.ShotOnTime.option2".localized()
        case .moreThanFourHours:
            return "Calculator.Que19.ShotOnTime.option3".localized()
        case .notGiven:
           return  "Calculator.Que19.ShotOnTime.option4".localized()
        }
    }
    
    var id: Int {
        switch self {
        case .yes:
            return 1
        case .fourHoursLate:
            return 2
        case .moreThanFourHours:
            return 3
        case .notGiven:
            return 4
        }
    }
    
    init(id: Int) {
        switch id {
        case 1:
            self = .yes
        case 2:
            self = .fourHoursLate
        case 3:
            self = .moreThanFourHours
        case 4:
            self = .notGiven
        default:
            self = .yes
        }
    }
    
}



// MARK: Multiple (3) Options

enum MultipleOptionsAnswer: Equatable {
    case KetonesType(KetonesType)
    case BloodKetonesMeasurements(BloodKetonesMeasurements)
    
}

enum KetonesType {
    case none
    case urineKetones
    case bloodKetones
    case noAccess
    
    var description: String {
        switch self {
        case .none:
            return ""
        case .urineKetones:
            return "Calculator.Que4.Ketones.option1".localized()
        case .bloodKetones:
            return "Calculator.Que4.Ketones.option2" .localized()
        case .noAccess:
            return "Calculator.Que4.Ketones.option3".localized()
        }
    }
    
    var id: Int {
        switch self {
        case .none:
            return 0
        case .urineKetones:
            return 1
        case .bloodKetones:
            return 2
        case .noAccess:
            return 3
        }
    }
    
    init(id: Int) {
        switch id {
        case 0:
            self = .none
        case 1:
            self = .urineKetones
        case 2:
            self = .bloodKetones
        case 3:
            self = .noAccess
        default:
            self = .noAccess
        }
    }
    
}

enum BloodKetonesMeasurements {
    case lessThanOne
    case oneToThree
    case greaterThanThree
    
    var description: String {
        switch self {
        case .lessThanOne:
            return "Calculator.Que8.BloodKetonesMeasuring.option1".localized()
        case .oneToThree:
            return "Calculator.Que8.BloodKetonesMeasuring.option2".localized()
        case .greaterThanThree:
            return "Calculator.Que8.BloodKetonesMeasuring.option3".localized()
            
        }
    }
    
    var id: Int {
        switch self {
        case .lessThanOne:
            return 1
        case .oneToThree:
            return 2
        case .greaterThanThree:
            return 3
        }
    }
    
    init(id: Int) {
        switch id {
        case 1:
            self = .lessThanOne
        case 2:
            self = .oneToThree
        case 3:
            self = .greaterThanThree
        default:
            self = .lessThanOne
        }
    }
}




