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
    func triggerEmergencyActionFlow()
    func triggerKetonesResponseActionFlow(_ currentQuestion: Questionnaire)
    func triggerLastDoseTimeResponseActionFlow(_ currentQuestion: Questionnaire)
    func triggerLastDoseValueResponseActionFlow(_ currentQuestion: Questionnaire)
    func triggerBedtimeResponseActionFlow(_ currentQuestion: Questionnaire)
    func triggerAbdominalFlow(_ currentQuestion: Questionnaire)
    func triggerBreathingFlow(_ currentQuestion: Questionnaire)
    func triggerVomitingFlow(_ currentQuestion: Questionnaire)
    func triggerAnyFollowingFlow(_ currentQuestion: Questionnaire)
    func saveTestType(_ testType: TestType)
    func saveBloodSugarAndCF(_ bloodSugar: Int, _ CF: Int)
    func confirmBloodSugarFlow()
    func confirmForKetones()
    func saveDose(_ dose: Int)
    func saveTBG(_ tbg: Int)
    func saveKetones(_ ketones: Float)
    func saveAbdominalPain(_ pain: Bool)
}

class QuestionnaireManager: QuestionnaireManagerProvider  {
    
    static let instance: QuestionnaireManager = QuestionnaireManager()
    var actionsDelegate: QuestionnaireActionsProtocol?
    
    private(set) var currentTestType: TestType = .pump
    private(set) var bloodSugar: Int = 0
    private(set) var correctionFactor: Int = 0
    private(set) var dose: Int?
    private(set) var tbg: Int?
    private(set) var ketones: Float?
    private(set) var abdominalPain: Bool?
    private var calculation: Float {
        let initial = bloodSugar - (tbg ?? 100)
        let ket = Float(initial) * (ketones ?? 1.0)
        let correction = ket/Float(correctionFactor)
        let calculation = correction - Float((dose ?? 0))
        return calculation
    }
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
        case YesOrNoQuestionId.bedtime.id:
            saveTBG(150)
            triggerBedtimeResponseActionFlow(currentQuestion)
        case YesOrNoQuestionId.dehydrated.id:
            triggerEmergencyActionFlow()
        case YesOrNoQuestionId.abdominal.id:
            saveAbdominalPain(true)
            if let ketones = ketones {
                if ketones == 1.0 {
                    triggerBreathingFlow(currentQuestion)
                } else if ketones == 1.5 {
                    triggerEmergencyActionFlow()
                }
            }
        case YesOrNoQuestionId.breathing.id:
            if let abdominalPain = abdominalPain {
                if abdominalPain {
                    triggerEmergencyActionFlow()
                } else {
                    triggerVomitingFlow(currentQuestion)
                }
            }
        case YesOrNoQuestionId.vomiting.id:
            triggerEmergencyActionFlow()
        case YesOrNoQuestionId.anyFollowing.id:
            triggerEndoActionFlow()
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
            triggerLastDoseValueResponseActionFlow(currentQuestion)
        case YesOrNoQuestionId.bedtime.id:
            saveTBG(100)
            triggerBedtimeResponseActionFlow(currentQuestion)
        case YesOrNoQuestionId.dehydrated.id:
            triggerAbdominalFlow(currentQuestion)
        case YesOrNoQuestionId.abdominal.id:
            saveAbdominalPain(false)
            triggerBreathingFlow(currentQuestion)
        case YesOrNoQuestionId.breathing.id:
            if let abdominalPain = abdominalPain {
                if abdominalPain {
                    triggerEndoActionFlow()
                } else {
                    triggerAnyFollowingFlow(currentQuestion)
                }
            }
            
        case YesOrNoQuestionId.vomiting.id:
            triggerEndoActionFlow()
        case YesOrNoQuestionId.anyFollowing.id:
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
    
    func saveDose(_ dose: Int) {
        self.dose = dose
    }
    
    func saveTBG(_ tbg: Int) {
        self.tbg = tbg
    }
    
    func saveKetones(_ ketones: Float) {
        self.ketones = ketones
    }
    
    func saveAbdominalPain(_ pain: Bool) {
        self.abdominalPain = pain
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
    
    func triggerLastDoseTimeResponseActionFlow(_ currentQuestion: Questionnaire) {
        let createQue = createOpenEndedSingleInpQuestion(questionId: .lastDoseInsulin, question: "Calculator.Que12.LastDose.title".localized(), inputUnit: "Calculator.Que12.LastDose.unit".localized())
        actionsDelegate?.showNextQuestion(createQue)
    }
    
    func triggerLastDoseValueResponseActionFlow(_ currentQuestion: Questionnaire) {
        let createQue = createYesOrNoQuestion(questionId: .bedtime, question: "Calculator.Que13.Bedtime.title".localized(), description: "Calculator.Que13.Bedtime.description".localized(), showDescriptionAtBottom: false)
        actionsDelegate?.showNextQuestion(createQue)
    }
    
    func triggerBedtimeResponseActionFlow(_ currentQuestion: Questionnaire) {
        let createQue = createYesOrNoQuestion(questionId: .dehydrated, question: "Calculator.Que14.Dehydration.title".localized(), description: "Calculator.Que14.Dehydration.description".localized(), showDescriptionAtBottom: false)
        actionsDelegate?.showNextQuestion(createQue)
    }
    
    func triggerAbdominalFlow(_ currentQuestion: Questionnaire) {
        let createQue = createYesOrNoQuestion(questionId: .abdominal, question: "Calculator.Que15.AbdominalPain.title".localized(), description: "Calculator.Que15.AbdominalPain.description".localized(), showDescriptionAtBottom: false)
        actionsDelegate?.showNextQuestion(createQue)
    }
    
    func triggerBreathingFlow(_ currentQuestion: Questionnaire) {
        let createQue = createYesOrNoQuestion(questionId: .breathing, question: "Calculator.Que16.Breathing.title".localized(), description: nil, showDescriptionAtBottom: false)
        actionsDelegate?.showNextQuestion(createQue)
    }
    
    func triggerVomitingFlow(_ currentQuestion: Questionnaire) {
        let createQue = createYesOrNoQuestion(questionId: .vomiting, question: "Calculator.Que17.Vomiting.title".localized(), description: nil, showDescriptionAtBottom: false)
        actionsDelegate?.showNextQuestion(createQue)
        
    }
    
    func triggerAnyFollowingFlow(_ currentQuestion: Questionnaire) {
        let createQue = createYesOrNoQuestion(questionId: .anyFollowing, question: "Calculator.Que18.AnyFollowing.title".localized(), description: "Calculator.Que18.AnyFollowing.description".localized(), showDescriptionAtBottom: false)
        actionsDelegate?.showNextQuestion(createQue)
        
    }
    
    
    func triggerEmergencyActionFlow() {
        showFinalStage(questionId: FinalQuestionId.generalEmergencyScreen.stepId, calculation: calculation)
    }
    
    func triggerEndoActionFlow() {
        showFinalStage(questionId: FinalQuestionId.endocrinologistScreen.stepId, calculation: calculation)
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
    
    // TODO: Rework Final Stages

    
    func showFinalStage(questionId: Int, calculation: Float?) {
        let stage = FinalQuestionId.init(id: questionId)
        switch stage {
        case .firstEmergencyScreen:
            let finalStepObj = createFinalStage(questionId: questionId, title: "Calculator.First.FinalStep.title".localized(), description: "Calculator.First.FinalStep.description".localized())
            actionsDelegate?.showNextQuestion(finalStepObj)
        case .endocrinologistScreen:
            var str = ""
            if let calculation = calculation {
                str = "Give \(calculation) units of insulin."
            }
            let finalStepObj = createFinalStage(questionId: questionId, title: "Calculator.Endo.FinalStep.title".localized(), description: str)
            actionsDelegate?.showNextQuestion(finalStepObj)
        case .generalEmergencyScreen:
            var str = ""
            if let calculation = calculation {
                let s = "Calculator.General.FinalStep.calculation".localized()
                str = String(format: s, String(round(calculation)))
            }
            let finalStepObj = createFinalStage(questionId: questionId, title: "Calculator.General.FinalStep.title".localized(), description: "Calculator.General.FinalStep.description".localized() + str)
            actionsDelegate?.showNextQuestion(finalStepObj)
        }
        
        
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
    
    func createOpenEndedSingleInpQuestion(questionId: OpenEndedWithSingleInputQuestionId, question: String,  inputUnit: String) -> Questionnaire {
        let quesObj = Questionnaire()
        quesObj.questionId = questionId.id
        quesObj.questionType = .openEndedWithSingleInput(questionId)
        quesObj.question = question
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
