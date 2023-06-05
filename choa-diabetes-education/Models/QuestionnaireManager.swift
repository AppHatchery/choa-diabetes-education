//
//  QuestionnaireManager.swift
//  choa-diabetes-education
//

import Foundation

protocol QuestionnaireActionsProtocol: AnyObject {
    func showNextQuestion(_ nextQue: Questionnaire)
}

protocol QuestionnaireManagerProvider: AnyObject {
    var actionsDelegate: QuestionnaireActionsProtocol? { get set }
    func triggerYesActionFlow(_ currentQuestion: Questionnaire)
    func triggerNoActionFlow(_ currentQuestion: Questionnaire)
    func triggerUrineKetonesActionFlow(_ currentQuestion: Questionnaire)
    func triggerBloodKetonesActionFlow(_ currentQuestion: Questionnaire)
    func triggerNoKetonesActionFlow(_ currentQuestion: Questionnaire)
    func saveTestType(_ testType: TestType)
    func saveBloodSugarAndCF(_ bloodSugar: Int, _ CF: Int)
    func confirmBloodSugarFlow()
    func confirmForKetones()
}

class QuestionnaireManager: QuestionnaireManagerProvider  {
    static let instance: QuestionnaireManager = QuestionnaireManager()
    var actionsDelegate: QuestionnaireActionsProtocol?
    
    private(set) var currentTestType: TestType = .pump
    private(set) var bloodSugar: Int = 0
    private(set) var correctionFactor: Int = 0
}

extension QuestionnaireManager {
    func triggerYesActionFlow(_ currentQuestion: Questionnaire) {
        let finalStepObj = createFinalStage(questionId: FinalQuestionId.firstEmergencyScreen.stepId, title: "Calculator.Que1.FinalStep.title".localized(), description: "Calculator.Que1.FinalStep.description".localized())
        actionsDelegate?.showNextQuestion(finalStepObj)
    }
    
    func triggerNoActionFlow(_ currentQuestion: Questionnaire) {
        let createTestTypeQue = createTwoCustomOptionsQuestion(questionId: .testType, question: "Calculator.Que2.TestType.title".localized(), description: nil, answerOptions: [TestType.pump.description, TestType.insulinShots.description])
        actionsDelegate?.showNextQuestion(createTestTypeQue)
    }
    
    func saveTestType(_ testType: TestType) {
        currentTestType = testType
    }
    
    func saveBloodSugarAndCF(_ bloodSugar: Int, _ CF: Int) {
        self.bloodSugar = bloodSugar
        self.correctionFactor = CF
    }
    
    func confirmBloodSugarFlow() {
        let createBloodSugarQue = createOpenEndedMultipleInpQuestion(questionId: .bloodSugar, question: "Calculator.Que3.BloodSugar.title".localized(), subQuestion: "Calculator.Que3.BloodSugar.subQue".localized(), inputUnit: "Calculator.Que3.BloodSugar.unit".localized())
        actionsDelegate?.showNextQuestion(createBloodSugarQue)
    }
    
    func confirmForKetones() {
        let createKetonesQue = createMultipleCustomOptionsQuestion(questionId: .ketones, question: "Calculator.Que4.Ketones.title".localized(), description: "Calculator.Que4.Ketones.description".localized(), answerOptions: [KetonesType.urineKetones.description, KetonesType.bloodKetones.description, KetonesType.none.description])
        actionsDelegate?.showNextQuestion(createKetonesQue)
    }
    
    func triggerUrineKetonesActionFlow(_ currentQuestion: Questionnaire) {
        
    }
    
    func triggerBloodKetonesActionFlow(_ currentQuestion: Questionnaire) {
        
    }
    
    func triggerNoKetonesActionFlow(_ currentQuestion: Questionnaire) {
        let createQue = createYesOrNoQuestion(questionId: .ketonesInNext30Mins, question: "Calculator.Que5.KetonesInNext30Mins.title".localized(), description: "Calculator.Que5.KetonesInNext30Mins.description" .localized(), showDescriptionAtBottom: true)
        actionsDelegate?.showNextQuestion(createQue)
    }
}

extension QuestionnaireManager {
    func createFinalStage(questionId: Int, title: String, description: String?) -> Questionnaire {
        let finalStepObj = FinalStep()
        finalStepObj.title = title
        finalStepObj.description = description
        
        let quesObj = Questionnaire()
        quesObj.questionId = questionId
        quesObj.questionType = .finalStep(FinalQuestionId(id: questionId))
        quesObj.finalStep = finalStepObj
        return quesObj
    }
    
    func createYesOrNoQuestion(questionId: YesOrNoQuestionId, question: String, description: String?, showDescriptionAtBottom: Bool) -> Questionnaire {
        let quesObj = Questionnaire()
        quesObj.questionId = questionId.id
        quesObj.questionType = .yesOrNo(questionId)
        quesObj.question = question
        quesObj.description = description
        quesObj.showDescriptionAtBottom = showDescriptionAtBottom
        quesObj.answerOptions = [YesOrNo.yes.description, YesOrNo.no.description]
        return quesObj
    }
    
    func createTwoCustomOptionsQuestion(questionId: TwoOptionsQuestionId, question: String, description: String?, answerOptions: [String]) -> Questionnaire {
        let quesObj = Questionnaire()
        quesObj.questionId = questionId.id
        quesObj.questionType = .twoOptions(questionId)
        quesObj.question = question
        quesObj.description = description
        quesObj.answerOptions = answerOptions
        return quesObj
    }
    
    func createOpenEndedMultipleInpQuestion(questionId: OpenEndedWithMultipleInputQuestionId, question: String, subQuestion: String, inputUnit: String) -> Questionnaire {
        let quesObj = Questionnaire()
        quesObj.questionId = questionId.id
        quesObj.questionType = .openEndedWithMultipleInput(questionId)
        quesObj.question = question
        quesObj.subQuestion = subQuestion
        quesObj.inputUnit = inputUnit
        return quesObj
    }
    
    func createMultipleCustomOptionsQuestion(questionId: MultipleOptionsDescriptionAtBottomQueId, question: String, description: String?, answerOptions: [String]) -> Questionnaire {
        let quesObj = Questionnaire()
        quesObj.questionId = questionId.id
        quesObj.questionType = .multipleOptionsDescriptionAtBottom(questionId)
        quesObj.question = question
        quesObj.description = description
        quesObj.answerOptions = answerOptions
        return quesObj
    }
}
