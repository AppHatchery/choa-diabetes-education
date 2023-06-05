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
    
    var id: Int {
        switch self {
        case .testType:
            return 1
        }
    }
    
    init(id: Int) {
        switch id {
        case 1:
            self = .testType
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
    case ketones
    
    var id: Int {
        switch self {
        case .ketones:
            return 1
        }
    }
    
    init(id: Int) {
        switch id {
        case 1:
            self = .ketones
        default:
            self = .ketones
        }
    }
}

enum TwoOptionsDescriptionAtBottomId {
    case ketonesInNext30Mins
    
    var id: Int {
        switch self {
        case .ketonesInNext30Mins:
            return 1
        }
    }
    
    init(id: Int) {
        switch id {
        case 1:
            self = .ketonesInNext30Mins
        default:
            self = .ketonesInNext30Mins
        }
    }
}

enum FinalQuestionId {
    case firstEmergencyScreen
    
    var stepId: Int {
        switch self {
        case .firstEmergencyScreen:
            return 1
        }
    }
    
    init(id: Int) {
        switch id {
        case 1:
            self = .firstEmergencyScreen
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
}