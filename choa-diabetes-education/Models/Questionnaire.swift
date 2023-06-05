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
}

class FinalStep {
    var title: String!
    var description: String?
}
