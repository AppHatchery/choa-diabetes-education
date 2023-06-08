//
//  QuestionType.swift
//  choa-diabetes-education
//

import Foundation

enum QuestionType {
    case yesOrNo(YesOrNoQuestionId)
    case twoOptions(TwoOptionsQuestionId)
    case multipleOptions
    case multipleOptionsDescriptionAtBottom(MultipleOptionsDescriptionAtBottomQueId)
    case openEndedWithSingleInput
    case openEndedWithMultipleInput(OpenEndedWithMultipleInputQuestionId)
    case finalStep(FinalQuestionId)
}

enum YesOrNoQuestionId {
    case severeDistress
    case ketonesInNext30Mins
    
    var id: Int {
        switch self {
        case .severeDistress:
            return 1
        case .ketonesInNext30Mins:
            return 2
        }
    }
    
    init(id: Int) {
        switch id {
        case 1:
            self = .severeDistress
        case 2:
            self = .ketonesInNext30Mins
        default:
            self = .severeDistress
        }
    }
}

enum TwoOptionsQuestionId {
    case testType
    case ketonesMeasure
    
    var id: Int {
        switch self {
        case .testType:
            return 1
        case .ketonesMeasure:
            return 2
        }
    }
    
    init(id: Int) {
        switch id {
        case 1:
            self = .testType
        case 2:
            self = .ketonesMeasure
        default:
            self = .testType
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
    
    var stepId: Int {
        switch self {
        case .firstEmergencyScreen:
            return 1
        case .endocrinologistScreen:
            return 6
        }
    }
    
    init(id: Int) {
        switch id {
        case 1:
            self = .firstEmergencyScreen
        case 6:
            self = .endocrinologistScreen
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
}


enum MultipleOptionsAnswer: Equatable {
    case KetonesType(KetonesType)
    case BloodKetonesMeasurements(BloodKetonesMeasurements)
    
}

enum KetonesType {
    case urineKetones
    case bloodKetones
    case none
    
    var description: String {
        switch self {
        case .urineKetones:
            return "Calculator.Que4.Ketones.option1".localized()
        case .bloodKetones:
            return "Calculator.Que4.Ketones.option2" .localized()
        case .none:
            return "Calculator.Que4.Ketones.option3".localized()
        }
    }
    
    var id: Int {
        switch self {
        case .urineKetones:
            return 1
        case .bloodKetones:
            return 2
        case .none:
            return 3
        }
    }
    
    init(id: Int) {
        switch id {
        case 1:
            self = .urineKetones
        case 2:
            self = .bloodKetones
        case 3:
            self = .none
        default:
            self = .none
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
}
