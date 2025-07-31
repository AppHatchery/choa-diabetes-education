//
//  QuestionType.swift
//  choa-diabetes-education
//

import Foundation

enum QuestionType: Equatable {
    case yesOrNo(YesOrNoQuestionId)
    case twoOptions(TwoOptionsQuestionId)
	case fourOptions(FourOptionsQuestionId)
	case fiveOptions(FiveOptionsQuestionId)
    case multipleOptions
    case multipleOptionsDescriptionAtBottom(MultipleOptionsDescriptionAtBottomQueId)
    case openEndedWithMultipleInput(OpenEndedWithMultipleInputQuestionId)
    case finalStep(FinalQuestionId)
}




enum YesOrNoQuestionId {
    case severeDistress
    case continuousGlucoseMonitor
    case pumpBloodSugarCheck
    case shotBloodSugarCheck
    case shotTwentyFourHours
    
    
    var id: Int {
        switch self {
        case .severeDistress:
            return 1
        case .continuousGlucoseMonitor:
            return 2
        case .pumpBloodSugarCheck:
            return 3
        case .shotBloodSugarCheck:
            return 4
        case .shotTwentyFourHours:
            return 5
        }
    }
    
    init(id: Int) {
        switch id {
        case 1:
            self = .severeDistress
        case 2:
            self = .continuousGlucoseMonitor
        case 3:
            self = .pumpBloodSugarCheck
        case 4:
            self = .shotBloodSugarCheck
        case 5:
            self = .shotTwentyFourHours
        default:
            self = .severeDistress
        }
    }
}

enum TwoOptionsQuestionId {
    case testType
    case calculationType
    
    
    var id: Int {
        switch self {
        case .testType:
            return 1
        case .calculationType:
            return 2
        }
    }
    
    init(id: Int) {
        switch id {
        case 1:
            self = .testType
        case 2:
            self = .calculationType
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
    case urineKetones
    
    var id: Int {
        switch self {
        case .urineKetones:
            return 1
        }
    }
    
    
    init(id: Int) {
        switch id {
        case 1:
            self = .urineKetones
        default:
            self = .urineKetones
        }
    }
}


enum TwoOptionsDescriptionAtBottomId {
    case calculationType
    
    var id: Int {
        switch self {
        case .calculationType:
            return 1
        }
    }
    
    init(id: Int) {
        switch id {
        case 1:
            self = .calculationType
        default:
            self = .calculationType
        }
    }
}




enum FinalQuestionId {
    case firstEmergencyScreen
    case recheckScreen
    case endo
    case small
    case large1
    case large2
    case shot
    case nextDose
    case fullDose
    
    var id: Int {
        switch self {
        case .firstEmergencyScreen:
            return 1
        case .recheckScreen:
            return 2
        case .endo:
            return 3
        case .small:
            return 4
        case .large1:
            return 5
        case .large2:
            return 6
        case .shot:
            return 7
        case .nextDose:
            return 8
        case .fullDose:
            return 9
        }
    }
    
    init(id: Int) {
        switch id {
        case 1:
            self = .firstEmergencyScreen
        case 2:
            self = .recheckScreen
        case 3:
            self = .endo
        case 4:
            self = .large1
        case 5:
            self = .large2
        case 6:
            self = .shot
        case 7:
            self = .nextDose
        case 8:
            self = .fullDose
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
    case CalculationType(CalculationType)
    
}

enum TestType {
    case pump
    case insulinShots
    
    var description: String {
        switch self {
		case .insulinShots:
            return "Calculator.Que.TestType.option1".localized()
		case .pump:
            return "Calculator.Que.TestType.option2".localized()
        }
    }
    
    init(id: Int) {
        switch id {
        case 1:
			self = .insulinShots
        case 2:
			self = .pump
        default:
			self = .insulinShots
        }
    }
}

enum FourOptionsAnswer: Equatable {
	case DKAIssue(ChildIssue)
	case HighBloodSugar(ChildIssue)
	case LowBloodSugar(ChildIssue)
	case NotSure(ChildIssue)

}

enum ChildIssue {
	case diabeticKetoacidosis
	case highBloodSugar
	case lowBloodSugar
	case notSure

	var description: String {
		switch self {
		case .diabeticKetoacidosis:
			return "GetHelp.Que.ChildIssue.option1".localized()
		case .highBloodSugar:
			return "GetHelp.Que.ChildIssue.option2".localized()
		case .lowBloodSugar:
			return "GetHelp.Que.ChildIssue.option3".localized()
		case .notSure:
			return "GetHelp.Que.ChildIssue.option4".localized()
		}
	}

	init(id: Int) {
		switch id {
		case 1:
			self = .diabeticKetoacidosis
		case 2:
			self = .highBloodSugar
		case 3:
			self = .lowBloodSugar
		case 4:
			self = .notSure
		default:
			self = .diabeticKetoacidosis
		}
	}
}

enum FiveOptionsAnswer: Equatable {
	case troubleBreathing(ChildSymptom)
	case confused(ChildSymptom)
	case veryTired(ChildSymptom)
	case vomitedMoreThanOnce(ChildSymptom)
	case noneOfTheAbove(ChildSymptom)
}

enum ChildSymptom {
	case troubleBreathing
	case confused
	case veryTired
	case vomitedMoreThanOnce
	case noneOfTheAbove

	var description: String {
		switch self {
			case .troubleBreathing:
				return "GetHelp.Que.ChildSymptoms.option1".localized()
			case .confused:
				return "GetHelp.Que.ChildSymptoms.option2".localized()
			case .veryTired:
				return "GetHelp.Que.ChildSymptoms.option3".localized()
			case .vomitedMoreThanOnce:
				return "GetHelp.Que.ChildSymptoms.option4".localized()
			case .noneOfTheAbove:
				return "GetHelp.Que.ChildSymptoms.option5".localized()
		}
	}

	init(id: Int) {
		switch id {
		case 1:
			self = .troubleBreathing
		case 2:
			self = .confused
		case 3:
			self = .veryTired
		case 4:
			self = .vomitedMoreThanOnce
		case 5:
			self = .noneOfTheAbove
		default:
			self = .troubleBreathing
		}
	}
}

enum FourOptionsQuestionId {
	case childIssue

	var id: Int {
		switch self {
		case .childIssue:
			return 1
		}
	}

	init(id: Int) {
		switch id {
		case 1:
			self = .childIssue
		default:
			self = .childIssue
		}
	}
}

enum FiveOptionsQuestionId {
	case childHasAnySymptoms

	var id: Int {
		switch self {
		case .childHasAnySymptoms:
			return 1
		}
	}

	init(id: Int) {
		switch id {
		case 1:
			self = .childHasAnySymptoms
		default:
			self = .childHasAnySymptoms
		}
	}
}

enum CalculationType {
    case scale
    case formula
    
    var description: String {
        switch self {
        case .formula:
            return "Calculator.Que.Method.option1".localized()
        case .scale:
            return "Calculator.Que.Method.option2".localized()
        }
    }
    
    init(id: Int) {
        switch id {
        case 1:
            self = .scale
        case 2:
            self = .formula
        default:
            self = .formula
        }
    }
}




// MARK: Multiple (3) Options

enum MultipleOptionsAnswer: Equatable {
    case KetonesMeasurements(KetonesMeasurements)
    
}

enum KetonesMeasurements {
    case zeroToSmall
    case moderateToLarge
    case unknown
    
    var description: String {
        switch self {
        case .zeroToSmall:
            return "Calculator.Que.KetonesMeasuring.option1".localized()
        case .moderateToLarge:
            return "Calculator.Que.KetonesMeasuring.option2".localized()
        case .unknown:
            return "Calculator.Que.KetonesMeasuring.option3".localized()
            
        }
    }
    
    init(id: Int) {
        switch id {
        case 1:
            self = .zeroToSmall
        case 2:
            self = .moderateToLarge
        case 3:
            self = .unknown
        default:
            self = .zeroToSmall
        }
    }
}
