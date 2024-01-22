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
    func triggerKetonesActionFlow(_ currentQuestion: Questionnaire)
    func triggerNoKetonesActionFlow(_ currentQuestion: Questionnaire)
    func triggerTestActionFlow(_ currentQuestion: Questionnaire)
    func triggerBloodSugarActionFlow(_ currentQuestion: Questionnaire)
    func triggerResultsActionFlow(_ currentQuestion: Questionnaire)
    func triggerDisclaimerActionFlow(_ currentQuestion: Questionnaire)
    func saveTestType(_ testType: TestType)
    func saveCGM(_ cgm: Bool)
    func saveData(bloodSugar: Int, correctionFactor: Int)
    func saveKetones(type: KetonesMeasurements)
    func saveCalculationType(_ calculationType: CalculationType)
}

class QuestionnaireManager: QuestionnaireManagerProvider  {
    
    
    static let instance: QuestionnaireManager = QuestionnaireManager()
    var actionsDelegate: QuestionnaireActionsProtocol?
    
    private(set) var currentTestType: TestType = .pump
    private(set) var currentMethod: CalculationType = .formula
    private(set) var cgm: Bool = true
    private(set) var bloodSugar: Int = 0
    private(set) var correctionFactor: Int = 0
    private(set) var ketones: KetonesMeasurements?

    private var calculation: Double {
        
        print("STARTING CALCULATION")
        print(currentTestType)
        print(currentMethod)
        print(ketones)
        
        var calculation = 0.0
        
        if currentTestType == .pump {
            calculation = (Double((bloodSugar - 100)) * 1.5)/Double(correctionFactor)
            print("1")
        } else {
            if currentMethod == .formula {
                print("2")
                if ketones == .zeroToSmall {
                    calculation = (Double((bloodSugar - 100)) * 1.5)/Double(correctionFactor)
                } else if ketones == .moderateToLarge {
                    calculation = Double((bloodSugar - 100))/Double(correctionFactor)
                }
            } else if currentMethod == .scale {
                print("3")
                let factor = (ketones == .zeroToSmall) ? 1 : 1.5
                 
                if bloodSugar >= 200 && bloodSugar < 300 {
                    calculation = 2 * factor
                } else if bloodSugar >= 300 && bloodSugar < 400 {
                    calculation = 4 * factor
                } else if bloodSugar >= 400 {
                    calculation = 6 * factor
                } else {
                    calculation = 0
                }
            }
        }
        return roundToOneDecimal(value: calculation)
    }
}

extension QuestionnaireManager {
    
    func triggerYesActionFlow(_ currentQuestion: Questionnaire) {
        switch currentQuestion.questionId {
            
        case YesOrNoQuestionId.severeDistress.id:
            showFinalStage(stage: FinalQuestionId.firstEmergencyScreen, calculation: nil)
        case YesOrNoQuestionId.continuousGlucoseMonitor.id:
            saveCGM(true)
            triggerBloodSugarCheckActionFlow(currentQuestion)
        case YesOrNoQuestionId.pumpBloodSugarCheck.id:
            triggerBloodSugarActionFlow(currentQuestion)
        case YesOrNoQuestionId.shotBloodSugarCheck.id:
            triggerBloodSugarActionFlow(currentQuestion)
        case YesOrNoQuestionId.shotTwentyFourHours.id:
            triggerFullDoseActionFlow()
        default:
            return
        }
        
        
    }
    
    func triggerNoActionFlow(_ currentQuestion: Questionnaire) {
        
        switch currentQuestion.questionId {
            
        case YesOrNoQuestionId.severeDistress.id:
            let createTestTypeQue = createTwoCustomOptionsQuestion(questionId: .testType, question: "Calculator.Que.TestType.title".localized(), description: nil, answerOptions: [TestType.pump.description, TestType.insulinShots.description])
            actionsDelegate?.showNextQuestion(createTestTypeQue)
        case YesOrNoQuestionId.continuousGlucoseMonitor.id:
            saveCGM(false)
            triggerBloodSugarCheckActionFlow(currentQuestion)
        case YesOrNoQuestionId.pumpBloodSugarCheck.id:
            triggerRecheckActionFlow(currentQuestion)
        case YesOrNoQuestionId.shotBloodSugarCheck.id:
            triggerRecheckActionFlow(currentQuestion)
        case YesOrNoQuestionId.shotTwentyFourHours.id:
            triggerNextDoseActionFlow()
        default:
            return
        }
        
    }
    
    func saveTestType(_ testType: TestType) {
        currentTestType = testType
    }
    
    func saveCalculationType(_ calculationType: CalculationType) {
        currentMethod = calculationType
        print(currentMethod)
    }
    
    
    func saveCGM(_ cgm: Bool) {
        self.cgm = cgm
    }
    
    func saveData(bloodSugar: Int, correctionFactor: Int) {
        self.bloodSugar = bloodSugar
        self.correctionFactor = correctionFactor
    }
    
    func saveKetones(type: KetonesMeasurements) {
        self.ketones = type
    }
    
    
    
    
    
    func triggerTestActionFlow(_ currentQuestion: Questionnaire) {
        if currentTestType == .pump {
            let createQue = createYesOrNoQuestion(questionId: .continuousGlucoseMonitor, question: "Calculator.Que.CGM.title".localized(), description: "Calculator.Que.CGM.description".localized(), showDescriptionAtBottom: true)
            actionsDelegate?.showNextQuestion(createQue)
            
        } else if currentTestType == .insulinShots {
            let createQue = createTwoCustomOptionsQuestion(questionId: .calculationType, question: "Calculator.Que.Method.title".localized(), description: "Calculator.Que.Method.description".localized(), answerOptions: ["Calculator.Que.Method.option1".localized(), "Calculator.Que.Method.option2".localized()])
            actionsDelegate?.showNextQuestion(createQue)
        }

    }
    
    

    
    func triggerKetonesActionFlow(_ currentQuestion: Questionnaire) {
        let createQue = createMultipleCustomOptionsQuestion(questionId: MultipleOptionsDescriptionAtBottomQueId.urineKetones, question: "Calculator.Que.KetonesMeasuring.title".localized(), description: "Calculator.Que.KetonesMeasuring.description".localized(), answerOptions: ["Calculator.Que.KetonesMeasuring.option1".localized(), "Calculator.Que.KetonesMeasuring.option2".localized(), "Calculator.Que.KetonesMeasuring.option3".localized()])
        actionsDelegate?.showNextQuestion(createQue)
    }
    
    
    
    
    func triggerNoKetonesActionFlow(_ currentQuestion: Questionnaire) {
        showFinalStage(stage: .endo, calculation: nil)
    }
    
    
    func triggerBloodSugarCheckActionFlow(_ currentQuestion: Questionnaire) {
        if currentTestType == .pump {
            let createQue = createYesOrNoQuestion(questionId: .pumpBloodSugarCheck, question: "Calculator.Que.PumpBloodSugarCheck.title".localized(), description: "Calculator.Que.PumpBloodSugarCheck.description".localized(), showDescriptionAtBottom: true)
            actionsDelegate?.showNextQuestion(createQue)
            
        } else if currentTestType == .insulinShots {
            let createQue = createYesOrNoQuestion(questionId: .shotBloodSugarCheck, question: "Calculator.Que.ShotBloodSugarCheck.title".localized(), description: "Calculator.Que.ShotBloodSugarCheck.description".localized(), showDescriptionAtBottom: false)
            actionsDelegate?.showNextQuestion(createQue)
        }
    }
    
    func triggerBloodSugarActionFlow(_ currentQuestion: Questionnaire) {
        let createQue = createOpenEndedMultipleInpQuestion(questionId: .bloodSugar, question: "Calculator.Que.BloodSugar.title".localized(), subQuestion: "Calculator.Que.BloodSugar.subQue".localized(), inputUnit: "Calculator.Que.BloodSugar.unit".localized(), description: "Calculator.Que.BloodSugar.description".localized(), showDescriptionAtBottom: true)
        actionsDelegate?.showNextQuestion(createQue)
    }
    
    
    
    func triggerRecheckActionFlow(_ currentQuestion: Questionnaire) {
        showFinalStage(stage: .recheckScreen, calculation: nil)
    }
    
    func triggerNextDoseActionFlow() {
        showFinalStage(stage: .nextDose, calculation: nil)
    }
    
    func triggerFullDoseActionFlow() {
        showFinalStage(stage: .fullDose, calculation: nil)
    }
    
    func triggerResultsActionFlow(_ currentQuestion: Questionnaire) {
        
        if currentTestType == .pump {
            if let ketones = ketones {
                if ketones == .zeroToSmall {
                    showFinalStage(stage: .small, calculation: nil)
                } else if ketones == .moderateToLarge {
                    if cgm {
                        showFinalStage(stage: .large1, calculation: Float(calculation))
                    } else {
                        showFinalStage(stage: .large2, calculation: Float(calculation))
                    }
                }
            }
        } else {
            showFinalStage(stage: .shot, calculation: Float(calculation))
        }
        
    }
    
    func triggerDisclaimerActionFlow(_ currentQuestion: Questionnaire) {
        let createQue = createYesOrNoQuestion(questionId: .shotTwentyFourHours, question: "Calculator.Que.ShotTwentyFourHours.title".localized(), description: "Calculator.Que.ShotTwentyFourHours.description".localized(), showDescriptionAtBottom: false)
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
    
    // TODO: Rework Final Stages

    
    func showFinalStage(stage: FinalQuestionId, calculation: Float?) {
        switch stage {
        case .firstEmergencyScreen:
            let finalStepObj = createFinalStage(questionId: stage.id, title: "Calculator.Final.Emergency.title".localized(), description: "Calculator.Final.Emergency.description".localized())
            actionsDelegate?.showNextQuestion(finalStepObj)
        case .recheckScreen:
            let finalStepObj = createFinalStage(questionId: stage.id, title: "Calculator.Final.Recheck.title".localized(), description: "Calculator.Final.Recheck.description".localized())
            actionsDelegate?.showNextQuestion(finalStepObj)
        case .endo:
            let finalStepObj = createFinalStage(questionId: stage.id, title: "Calculator.Final.Endo.title".localized(), description: "Calculator.Final.Endo.description".localized())
            actionsDelegate?.showNextQuestion(finalStepObj)
        case .small:
            let finalStepObj = createFinalStage(questionId: stage.id, title: "Calculator.Final.Small.title".localized(), description: "Calculator.Final.Small.description".localized())
            actionsDelegate?.showNextQuestion(finalStepObj)
        case .large1:
            let finalStepObj = createFinalStage(questionId: stage.id, title: String(format: "Calculator.Final.Large1.title".localized(), "\(self.calculation)"), description: "Calculator.Final.Large1.description".localized())
            actionsDelegate?.showNextQuestion(finalStepObj)
        case .large2:
            let finalStepObj = createFinalStage(questionId: stage.id, title: String(format: "Calculator.Final.Large2.title".localized(), "\(self.calculation)"), description: "Calculator.Final.Large2.description".localized())
            actionsDelegate?.showNextQuestion(finalStepObj)
        case .shot:
            let finalStepObj = createFinalStage(questionId: stage.id, title: String(format: "Calculator.Final.Shot.title".localized(), "\(self.calculation)"), description: "Calculator.Final.Shot.description".localized())
            actionsDelegate?.showNextQuestion(finalStepObj)
        case .nextDose:
            let finalStepObj = createFinalStage(questionId: stage.id, title: "Calculator.Final.NextDose.title".localized(), description: "Calculator.Final.NextDose.description".localized())
            actionsDelegate?.showNextQuestion(finalStepObj)
        case .fullDose:
            let finalStepObj = createFinalStage(questionId: stage.id, title: "Calculator.Final.FullDose.title".localized(), description: "Calculator.Final.FullDose.description".localized())
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
    
    func createOpenEndedMultipleInpQuestion(questionId: OpenEndedWithMultipleInputQuestionId, question: String, subQuestion: String, inputUnit: String, description: String?, showDescriptionAtBottom: Bool) -> Questionnaire {
        let quesObj = Questionnaire()
        quesObj.questionId = questionId.id
        quesObj.questionType = .openEndedWithMultipleInput(questionId)
        quesObj.question = question
        quesObj.showDescriptionAtBottom = showDescriptionAtBottom
        quesObj.description = description
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
    
    
    func roundToOneDecimal(value: Double)-> Double {
        return (round(value*10)/10.0)
    }
    
}
