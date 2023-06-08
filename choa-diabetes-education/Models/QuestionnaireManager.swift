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
    func triggerEmergencyActionFlow(_ currentQuestion: Questionnaire)
    func triggerKetonesResponseActionFlow(_ currentQuestion: Questionnaire)
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
        switch currentQuestion.questionId {
            
        case YesOrNoQuestionId.severeDistress.id:
            showFinalStage(questionId: FinalQuestionId.firstEmergencyScreen.stepId, calculation: nil)
        case YesOrNoQuestionId.ketonesInNext30Mins.id:
            let createQue = createYesOrNoQuestion(questionId: .insulinThreeHours, question: "Calculator.Que9.RapidInsulin.title".localized(), description: "Calculator.Que9.RapidInsulin.description" .localized(), showDescriptionAtBottom: false)
            actionsDelegate?.showNextQuestion(createQue)
        case YesOrNoQuestionId.insulinThreeHours.id:
            if currentTestType == .pump {
                let createTimeQue = createTwoCustomOptionsQuestion(questionId: .lastDose, question: "Calculator.Que11.PumpLastDose.title".localized(), description: nil, answerOptions: [PumpLastDose.lessThan30.description, PumpLastDose.halfHourToTwoHours.description])
                actionsDelegate?.showNextQuestion(createTimeQue)
            } else if currentTestType == .insulinShots {
                let createTimeQue = createTwoCustomOptionsQuestion(questionId: .lastDose, question: "Calculator.Que10.ShotLastDose.title".localized(), description: nil, answerOptions: [ShotLastDose.lessThanHour.description, ShotLastDose.oneToThreeHours.description])
                actionsDelegate?.showNextQuestion(createTimeQue)
            }
            
        default:
            return
        }
        
        
    }
    
    func triggerNoActionFlow(_ currentQuestion: Questionnaire) {
        
        switch currentQuestion.questionId {
            
        case YesOrNoQuestionId.severeDistress.id:
            let createTestTypeQue = createTwoCustomOptionsQuestion(questionId: .testType, question: "Calculator.Que2.TestType.title".localized(), description: nil, answerOptions: [TestType.pump.description, TestType.insulinShots.description])
            actionsDelegate?.showNextQuestion(createTestTypeQue)
        case YesOrNoQuestionId.ketonesInNext30Mins.id:
            showFinalStage(questionId: FinalQuestionId.endocrinologistScreen.stepId, calculation: nil)
        case YesOrNoQuestionId.insulinThreeHours.id:
            return
        default:
            return
        }
        
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
        let createKetonesQue = createMultipleCustomOptionsQuestion(questionId: .ketonesChecked, question: "Calculator.Que4.Ketones.title".localized(), description: "Calculator.Que4.Ketones.description".localized(), answerOptions: [KetonesType.urineKetones.description, KetonesType.bloodKetones.description, KetonesType.noAccess.description])
        actionsDelegate?.showNextQuestion(createKetonesQue)
    }
    
    func triggerUrineKetonesActionFlow(_ currentQuestion: Questionnaire) {
        let createQue = createTwoCustomOptionsQuestion(questionId: TwoOptionsQuestionId.ketonesMeasure, question: "Calculator.Que.KetonesMeasuring.title".localized(), description: "Calculator.Que.KetonesMeasuring.description".localized(), answerOptions: ["Calculator.Que7.UrineKetonesMeasuring.option1".localized(), "Calculator.Que7.UrineKetonesMeasuring.option2".localized()])
        actionsDelegate?.showNextQuestion(createQue)
    }
    
    func triggerBloodKetonesActionFlow(_ currentQuestion: Questionnaire) {
        let createQue = createMultipleCustomOptionsQuestion(questionId: MultipleOptionsDescriptionAtBottomQueId.bloodKetoneMeasurements, question: "Calculator.Que.KetonesMeasuring.title".localized(), description: "Calculator.Que.KetonesMeasuring.description".localized(), answerOptions: ["Calculator.Que8.BloodKetonesMeasuring.option1".localized(), "Calculator.Que8.BloodKetonesMeasuring.option2".localized(), "Calculator.Que8.BloodKetonesMeasuring.option3".localized()])
        actionsDelegate?.showNextQuestion(createQue)
    }
    
    func triggerNoKetonesActionFlow(_ currentQuestion: Questionnaire) {
        let createQue = createYesOrNoQuestion(questionId: .ketonesInNext30Mins, question: "Calculator.Que5.KetonesInNext30Mins.title".localized(), description: "Calculator.Que5.KetonesInNext30Mins.description" .localized(), showDescriptionAtBottom: true)
        actionsDelegate?.showNextQuestion(createQue)
    }
    
    
    func triggerKetonesResponseActionFlow(_ currentQuestion: Questionnaire) {
        let createQue = createYesOrNoQuestion(questionId: .insulinThreeHours, question: "Calculator.Que9.RapidInsulin.title".localized(), description: "Calculator.Que9.RapidInsulin.description" .localized(), showDescriptionAtBottom: false)
        actionsDelegate?.showNextQuestion(createQue)
    }
    
    // TODO: Is the Final Question ID necessary?
    
    func triggerEmergencyActionFlow(_ currentQuestion: Questionnaire) {
        switch currentQuestion.questionId {
        case MultipleOptionsDescriptionAtBottomQueId.bloodKetoneMeasurements.id:
            let calculation = ((bloodSugar - 100)/correctionFactor)
            showFinalStage(questionId: FinalQuestionId.emergencyBloodKetoneScreen.stepId, calculation: calculation)
        default:
            return
            
        }
        
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
    
    func showFinalStage(questionId: Int, calculation: Int?) {
        var str = ""
        if let calculation = calculation {
            str = "\n\n  And consider a dose of \(calculation) units of rapid-acting insulin."
        }
        let finalStepObj = createFinalStage(questionId: FinalQuestionId.firstEmergencyScreen.stepId, title: "Calculator.Que\(questionId).FinalStep.title".localized(), description: "Calculator.Que\(questionId).FinalStep.description".localized() + str)
        actionsDelegate?.showNextQuestion(finalStepObj)
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
