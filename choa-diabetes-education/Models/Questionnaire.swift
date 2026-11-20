//
//  Questionnaire.swift
//  choa-diabetes-education
//

import Foundation

class Questionnaire {
    var questionId: Int!
    var questionType: QuestionType!
    var question: String!
    var answerOptions: [String]?
    var description: String?
    var showDescriptionAtBottom: Bool = false
    var subQuestion: String?
    var inputUnit: String?
    var isFinalSep: Bool = false
    var finalStep: FinalStep?
    /// iLet protocol state when this screen was shown, restored when the user navigates back to it
    var iLetSnapshot: ILetSnapshot?
}

/// Which home-care steps the iLet protocol has the family on. Every iLet decision after the first ketone check is made from this.
enum ILetStage: String, Codable {
    /// First ketone check not done yet, or it was positive and we're waiting on the blood sugar reading
    case none
    /// First ketones negative/low: confirm the pump is secure, recheck in 90 minutes
    case secureSteps
    /// Moderate ketones with blood sugar over 180: change the iLet pump site, recheck in 90 minutes
    case changeSite
    /// High ketones with blood sugar over 180 (or moderate ketones that didn't clear): disconnect, give a pen correction, recheck in 90 minutes
    case disconnect
}

/// Ketone result grouped the way the iLet protocol branches on it
enum KetoneSeverity: String, Codable {
    case low       // Urine negative, blood low
    case moderate  // Urine 0.5 / 1.5 / 4.0, blood moderate
    case high      // Urine 8.0 / 16.0, blood large

    init(urine: UrineKetoneLevel) {
        switch urine {
        case .negative: self = .low
        case .zeroPointFive, .onePointFive, .four: self = .moderate
        case .eight, .sixteen: self = .high
        }
    }

    init(blood: BloodKetoneLevel) {
        switch blood {
        case .low: self = .low
        case .moderate: self = .moderate
        case .large: self = .high
        }
    }
}

struct ILetSnapshot {
    let stage: ILetStage
    let ketoneSeverity: KetoneSeverity?
}

class FinalStep {
    var title: String!
    var description: String?
	var imageName: String?
}
