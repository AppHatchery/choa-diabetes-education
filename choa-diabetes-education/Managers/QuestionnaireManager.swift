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
	func triggerDKAWorkFlow(_ currentQuestion: Questionnaire, childIssue: ChildIssue)
    func triggerHypoglycemiaFlow(_ currentQuestio: Questionnaire)
    func triggerBloodSugarCheckMethodActionFlow(_ currentQuestion: Questionnaire, method: BloodSugarCheckMethod)
    func triggerLowBloodSugarReadingActionFlow(_ currentQuestion: Questionnaire)
    func triggerLowBloodSugarReadingResultActionFlow(_ currentQuestion: Questionnaire, bloodSugar: Int)
    func triggerLowBloodSugarSymptomsActionFlow(_ currentQuestion: Questionnaire, hasSymptoms: Bool)
    func triggerLowBloodSugarTestTypeActionFlow(_ currentQuestion: Questionnaire, testType: TestType, pumpShowsCGM: Bool?)
	func triggerOtherSymptomsActionFlow(_ currentQuestion: Questionnaire)
	func triggerKetoneMeasuringTypeActionFlow(_ currentQuestion: Questionnaire)
	func triggerRecheckKetonesActionFlow(_ currentQuestion: Questionnaire)
    func triggerYesActionFlow(_ currentQuestion: Questionnaire)
    func triggerNoActionFlow(_ currentQuestion: Questionnaire)
    func triggerKetonesActionFlow(_ currentQuestion: Questionnaire)
    func triggerNoKetonesActionFlow(_ currentQuestion: Questionnaire)
    func triggerTestActionFlow(_ currentQuestion: Questionnaire)
    func triggerBloodSugarActionFlow(_ currentQuestion: Questionnaire)
    func triggerBloodSugarCheckActionFlow(_ currentQuestion: Questionnaire)
    func triggerBloodSugarRecheckActionFlow(_ currentQuestion: Questionnaire)
    func triggerBloodSugarRecheckReadingActionFlow(_ currentQuestion: Questionnaire, bloodSugar: Int)
    func triggerResultsActionFlow(_ currentQuestion: Questionnaire)
    func triggerDisclaimerActionFlow(_ currentQuestion: Questionnaire)
	func triggerCallChoaActionFlow(_ currentQuestion: Questionnaire)
    func saveTestType(_ testType: TestType)
	func saveMeasuringMethod(_ method: MeasuringType)
    func saveCGM(_ cgm: Bool)
	func saveILetPump(_ iLetPump: Bool)
	func saveBloodSugarOver300(_ over300: Bool)
	func saveBloodSugarOver300For3Hours(_ over300: Bool)
	var iLetPump: Bool { get }
	var currentTestType: TestType { get }
    func saveData(bloodSugar: Int, correctionFactor: Int)
    func saveKetones(type: KetonesMeasurements)
	func saveUrineKetoneLevel(level: UrineKetoneLevel)
    func saveBloodKetoneLevel(level: BloodKetoneLevel)
    func saveCalculationType(_ calculationType: CalculationType)
	func saveYesOver2hours(_ over2hours: Bool)
    var skipFirstReminder: Bool { get }
    var currentMethod: CalculationType { get set }
	func triggerNoSymptomsActionFlow(_ currentQuestion: Questionnaire, childSymptom: ChildSymptom)
	func triggerUrineKetoneLevelActionFlow(_ currentQuestion: Questionnaire, level: UrineKetoneLevel)
    func triggerUrineKetoneForILetActionFlow(_ currentQuestion: Questionnaire, level: UrineKetoneLevel)
    
	func triggerBloodKetoneLevelActionFlow(_ currentQuestion: Questionnaire, level: BloodKetoneLevel)
    func triggerBloodKetoneForILetActionFlow(_ currentQuestion: Questionnaire, level: BloodKetoneLevel)
	func triggerFirstEmergencyActionFlow(_ currentQuestion: Questionnaire)
	func triggerContinueActionFlow(_ currentQuestion: Questionnaire)
    func triggerContinueWithDescriptionActionFlow(_ currentQuestion: Questionnaire)
	func triggerRecheckUrineKetoneActionFlow(_ currentQuestion: Questionnaire, urineLevel: UrineKetoneLevel)
    func triggerRecheckUrineKetoneForILetActionFlow(_ currentQuestion: Questionnaire, urineLevel: UrineKetoneLevel)
	func triggerRecheckBloodKetoneActionFlow(_ currentQuestion: Questionnaire, bloodLevel: BloodKetoneLevel)
    func triggerRecheckBloodKetoneForILetActionFlow(_ currentQuestion: Questionnaire, bloodLevel: BloodKetoneLevel)

		// Reminder management
	func saveActiveReminder(id: String, scheduledTime: Date)
	func clearActiveReminder()
	func hasActiveReminder() -> Bool
	func getRemainingTime() -> TimeInterval?
	func getActiveReminderId() -> String?
    
        // Visit counts, derived from the questions on the navigation stack
    func getReminderPageVisitCount() -> Int
    func getKetoneVisitCount() -> Int
    func updateVisitCounts(for path: [Questionnaire])
}

/// How many times the user has reached the screens the ketone routing branches on.
struct VisitCounts: Codable {
    /// iLet Pump reminder pages (other flows don't branch on reminder visits)
    var reminderPages = 0
    /// Ketone measurements: the first one on the measuring type question, plus each recheck
    var ketoneChecks = 0

    static func + (lhs: VisitCounts, rhs: VisitCounts) -> VisitCounts {
        VisitCounts(reminderPages: lhs.reminderPages + rhs.reminderPages,
                    ketoneChecks: lhs.ketoneChecks + rhs.ketoneChecks)
    }

    static func - (lhs: VisitCounts, rhs: VisitCounts) -> VisitCounts {
        VisitCounts(reminderPages: max(lhs.reminderPages - rhs.reminderPages, 0),
                    ketoneChecks: max(lhs.ketoneChecks - rhs.ketoneChecks, 0))
    }
}

/// Everything recorded during one Get Help session. Saved as a single value on every change,
/// and copied into a pending reminder, so the flow can pick up where it left off after a relaunch.
struct GetHelpSession: Codable {
    var testType: TestType = .pump
    var measuringMethod: MeasuringType = .urineKetone
    var childIssue: ChildIssue = .diabeticKetoacidosis
    var calculationType: CalculationType = .formula
    var cgm = true
    var iLetPump = false
    var bloodSugarOver300 = false
    var bloodSugarOver300For3Hours = false
    var bloodSugar = 0
    var correctionFactor = 0
    var ketones: KetonesMeasurements?
    var urineKetones: UrineKetoneLevel?
    var bloodKetones: BloodKetoneLevel?
    var firstUrineKetoneValue: UrineKetoneLevel?
    var firstBloodKetoneValue: BloodKetoneLevel?
    var secondUrineKetoneValue: UrineKetoneLevel?
    var secondBloodKetoneValue: BloodKetoneLevel?
    var yesOver2hours = false
    var skipFirstReminder = false
    var activeReminderId: String?
    var reminderScheduledTime: Date?

    /// Counts as of the last Get Help screen shown
    var visitCounts = VisitCounts()
    /// Counts from screens that are no longer on the navigation stack, because the flow was
    /// reopened from a reminder onto a fresh stack. Added to whatever the stack holds.
    var visitCountsBeforeStack = VisitCounts()
}

class QuestionnaireManager: QuestionnaireManagerProvider  {
    
    
	static let instance = QuestionnaireManager()
    weak var actionsDelegate: QuestionnaireActionsProtocol?
    
    private static let sessionKey = "getHelpSession"

    private(set) var session: GetHelpSession {
        didSet { saveSession() }
    }

    private init() {
        session = Self.loadSession() ?? GetHelpSession()
        Self.removeLegacyKeys()
    }

    // Accessors kept so the routing code can keep reading and writing the fields directly
    private(set) var currentTestType: TestType { get { session.testType } set { session.testType = newValue } }
	private(set) var currentMeasuringMethod: MeasuringType { get { session.measuringMethod } set { session.measuringMethod = newValue } }
	private(set) var currentChildIssue: ChildIssue { get { session.childIssue } set { session.childIssue = newValue } }
    var currentMethod: CalculationType { get { session.calculationType } set { session.calculationType = newValue } }
    private(set) var cgm: Bool { get { session.cgm } set { session.cgm = newValue } }
	private(set) var iLetPump: Bool { get { session.iLetPump } set { session.iLetPump = newValue } }
	private(set) var bloodSugarOver300: Bool { get { session.bloodSugarOver300 } set { session.bloodSugarOver300 = newValue } }
	private(set) var bloodSugarOver300For3Hours: Bool { get { session.bloodSugarOver300For3Hours } set { session.bloodSugarOver300For3Hours = newValue } }
    private(set) var bloodSugar: Int { get { session.bloodSugar } set { session.bloodSugar = newValue } }
    private(set) var correctionFactor: Int { get { session.correctionFactor } set { session.correctionFactor = newValue } }
    private(set) var ketones: KetonesMeasurements? { get { session.ketones } set { session.ketones = newValue } }
	private(set) var urineKetones: UrineKetoneLevel? { get { session.urineKetones } set { session.urineKetones = newValue } }
	private(set) var bloodKetones: BloodKetoneLevel? { get { session.bloodKetones } set { session.bloodKetones = newValue } }
    private(set) var firstUrineKetoneValue: UrineKetoneLevel? { get { session.firstUrineKetoneValue } set { session.firstUrineKetoneValue = newValue } }
    private(set) var firstBloodKetoneValue: BloodKetoneLevel? { get { session.firstBloodKetoneValue } set { session.firstBloodKetoneValue = newValue } }
    private(set) var secondUrineKetoneValue: UrineKetoneLevel? { get { session.secondUrineKetoneValue } set { session.secondUrineKetoneValue = newValue } }
    private(set) var secondBloodKetoneValue: BloodKetoneLevel? { get { session.secondBloodKetoneValue } set { session.secondBloodKetoneValue = newValue } }
	private(set) var yesOver2hours: Bool { get { session.yesOver2hours } set { session.yesOver2hours = newValue } }
    private(set) var skipFirstReminder: Bool { get { session.skipFirstReminder } set { session.skipFirstReminder = newValue } }

	private(set) var activeReminderId: String? { get { session.activeReminderId } set { session.activeReminderId = newValue } }
	private(set) var reminderScheduledTime: Date? { get { session.reminderScheduledTime } set { session.reminderScheduledTime = newValue } }

    private var calculation: Double {
        
        var calculation = 0.0
        
        if currentTestType == .pump {
            calculation = (Double((bloodSugar - 100)) * 1.5)/Double(correctionFactor)
            print("1")
        } else {
            if currentMethod == .formula {
                print("2")
                if ketones == .zeroToSmall {
                    calculation = Double((bloodSugar - 100))/Double(correctionFactor)
                } else if ketones == .moderateToLarge {
                    calculation = (Double((bloodSugar - 100)) * 1.5)/Double(correctionFactor)
                }
            } else if currentMethod == .scale {
                print("3")
                let factor = (ketones == .zeroToSmall) ? 1 : 1.5
                 
                calculation = Double(correctionFactor) * factor
            }
        }
        return roundToOneDecimal(value: calculation)
    }
}

extension QuestionnaireManager {

	func triggerDKAWorkFlow(_ currentQuestion: Questionnaire, childIssue: ChildIssue) {
		switch currentQuestion.questionId {
			case FourOptionsQuestionId.childIssue.id:
			let createFiveOptionsQuestion = createFiveCustomOptionsQuestion(
				questionId: FiveOptionsQuestionId.childHasAnySymptoms,
				question: "GetHelp.Que.ChildHasAnySymptoms.title".localized(),
				description: nil,
				answerOptions: [
					"GetHelp.Que.ChildHasAnySymptoms.option1".localized(),
					"GetHelp.Que.ChildHasAnySymptoms.option2".localized(),
					"GetHelp.Que.ChildHasAnySymptoms.option3".localized(),
					"GetHelp.Que.ChildHasAnySymptoms.option4".localized(),
					"GetHelp.Que.ChildHasAnySymptoms.option5".localized(),
				]
			)
			actionsDelegate?.showNextQuestion(createFiveOptionsQuestion)
		default:
			return
		}
	}
    
    func triggerHypoglycemiaFlow(_ currentQuestion: Questionnaire) {
        switch currentQuestion.questionId {
        case FourOptionsQuestionId.childIssue.id:
            let createTwoOptionQuestion = createTwoCustomOptionsQuestion(
                questionId: TwoOptionsQuestionId.bloodSugarCheckMethod,
                question: "GetHelp.Que.BloodSugarCheckMethod.title".localized(),
                description: nil,
                answerOptions: [
                    "Calculator.Que.TestType.option3",
                    "Calculator.Que.TestType.option4"
                ]
            )
            actionsDelegate?.showNextQuestion(createTwoOptionQuestion)
        default:
            return
        }
    }

    /// Glucose meter readings go straight to the reading. CGM readings are confirmed with a finger stick first.
    func triggerBloodSugarCheckMethodActionFlow(_ currentQuestion: Questionnaire, method: BloodSugarCheckMethod) {
        switch method {
        case .glucoseMeter:
            saveCGM(false)
            triggerLowBloodSugarReadingActionFlow(currentQuestion)
        case .cgm:
            saveCGM(true)
            showFinalStage(stage: .performFingerStickTest, calculation: nil)
        }
    }

    /// Asks for the blood sugar reading in the hypoglycemia flow. There is no duration follow-up or low reading alert.
    func triggerLowBloodSugarReadingActionFlow(_ currentQuestion: Questionnaire) {
        let quesObj = Questionnaire()
        quesObj.questionId = OpenEndedWithMultipleInputQuestionId.lowBloodSugarCheck.id
        quesObj.questionType = .openEndedWithMultipleInput(.lowBloodSugarCheck)
        quesObj.question = "Calculator.Que.BloodSugarReading.title".localized()
        quesObj.inputUnit = "Calculator.Que.BloodSugar.unit".localized()
        actionsDelegate?.showNextQuestion(quesObj)
    }

    /// Routes the hypoglycemia blood sugar reading. The threshold is 80 mg/dL for children 5 and under, otherwise 70 mg/dL.
    /// Readings at or above it (including over 300) go to the low symptoms question, readings below it ask how insulin is taken.
    func triggerLowBloodSugarReadingResultActionFlow(_ currentQuestion: Questionnaire, bloodSugar: Int) {
        self.bloodSugar = bloodSugar

        if bloodSugar >= AppOnboardingManager.shared.lowBloodSugarThreshold {
            let quesObj = Questionnaire()
            // questionId is read on every screen, so it must be set even though this question has only one id
            quesObj.questionId = 1
            quesObj.questionType = .lowBloodSugarSymptoms
            quesObj.question = "GetHelp.Que.LowBloodSugarSymptoms.title".localized()
            actionsDelegate?.showNextQuestion(quesObj)
        } else {
            let createTestTypeQue = createTwoCustomOptionsQuestion(
                questionId: .lowBloodSugarTestType,
                question: "Calculator.Que.TestType.title".localized(),
                description: nil,
                answerOptions: [TestType.insulinShots.description, TestType.pump.description]
            )
            actionsDelegate?.showNextQuestion(createTestTypeQue)
        }
    }

    /// How insulin is taken when blood sugar is low. Pump users also say whether the pump shows CGM readings.
    func triggerLowBloodSugarTestTypeActionFlow(_ currentQuestion: Questionnaire, testType: TestType, pumpShowsCGM: Bool?) {
        saveTestType(testType)
        if let pumpShowsCGM {
            saveCGM(pumpShowsCGM)
        }

        // Pumps showing CGM readings are already cutting back insulin, so they only need 8g unless blood sugar is 50 mg/dL or lower
        let needsSmallerTreatment = testType == .pump && pumpShowsCGM == true && bloodSugar > 50
        print("Low blood sugar test type: \(testType), pump shows CGM: \(String(describing: pumpShowsCGM)), 8g treatment: \(needsSmallerTreatment)")

        showFinalStage(stage: needsSmallerTreatment ? .treatLowBloodSugar8g : .treatLowBloodSugar15g, calculation: nil)
    }

    /// Low symptoms with a reading over 70 mg/dL need a call to CHOA, otherwise continue the DMMP.
    func triggerLowBloodSugarSymptomsActionFlow(_ currentQuestion: Questionnaire, hasSymptoms: Bool) {
        if hasSymptoms {
            triggerCallChoaEmergencyActionFlow(currentQuestion)
        } else {
            showFinalStage(stage: .continueDMMP, calculation: nil)
        }
    }

	func triggerOtherSymptomsActionFlow(_ currentQuestion: Questionnaire) {
		switch currentQuestion.questionType {
		case .yesOrNo(.bloodSugarCheck), .openEndedWithMultipleInput(.bloodSugarCheck):
			let createTestTypeQue = createFourCustomOptionsQuestion(
				questionId: FourOptionsQuestionId.otherSymptom,
				question: "GetHelp.Que.OtherSymptoms.title".localized(),
				description: nil,
				answerOptions: [
					"GetHelp.Que.OtherSymptoms.option1".localized(),
					"GetHelp.Que.OtherSymptoms.option2".localized(),
					"GetHelp.Que.OtherSymptoms.option3".localized(),
					"GetHelp.Que.OtherSymptoms.option4".localized(),
				]
			)
			actionsDelegate?.showNextQuestion(createTestTypeQue)
			default:
				return
		}
	}

	func triggerNoSymptomsActionFlow(_ currentQuestion: Questionnaire, childSymptom: ChildSymptom) {
		switch currentQuestion.questionId {
			case FiveOptionsQuestionId.childHasAnySymptoms.id:
			let createTestTypeQue = createTwoCustomOptionsQuestion(questionId: .testType, question: "Calculator.Que.TestType.title".localized(), description: nil, answerOptions: [
				TestType.insulinShots.description, TestType.pump.description])
			actionsDelegate?.showNextQuestion(createTestTypeQue)
			default:
				return
		}
	}

    func triggerYesActionFlow(_ currentQuestion: Questionnaire) {
        switch currentQuestion.questionId {
            
        case YesOrNoQuestionId.severeDistress.id:
            showFinalStage(stage: FinalQuestionId.firstEmergencyScreen, calculation: nil)
        case YesOrNoQuestionId.continuousGlucoseMonitor.id:
            saveCGM(true)
            triggerBloodSugarCheckActionFlow(currentQuestion)
        case YesOrNoQuestionId.pumpBloodSugarCheck.id:
            triggerBloodSugarActionFlow(currentQuestion)
        case YesOrNoQuestionId.bloodSugarCheck.id:
            if bloodSugarOver300For3Hours == false {
                triggerOtherSymptomsActionFlow(currentQuestion)
            } else if bloodSugarOver300For3Hours == true {
                triggerKetoneMeasuringTypeActionFlow(currentQuestion)
            }
		case YesOrNoQuestionId.bloodSugarRecheck.id:
            triggerBloodSugarRecheckAboveActionFlow(currentQuestion)
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
        case YesOrNoQuestionId.bloodSugarCheck.id:
            if bloodSugarOver300 == false || bloodSugarOver300For3Hours == false {
                triggerOtherSymptomsActionFlow(currentQuestion)
            }
		case YesOrNoQuestionId.bloodSugarRecheck.id:
            triggerBloodSugarRecheckBelowActionFlow(currentQuestion)
            
        case YesOrNoQuestionId.shotTwentyFourHours.id:
            triggerNextDoseActionFlow()
            
        default:
            return
        }
    }
    
    /// Blood sugar recheck answered above the threshold (180 mg/dL for iLet Pump, otherwise 150 mg/dL,
    /// or "300 mg/dL or higher" for the pump yes/no question).
    private func triggerBloodSugarRecheckAboveActionFlow(_ currentQuestion: Questionnaire) {
        if iLetPump {
            let visitCount = getReminderPageVisitCount()
            let ketoneCheckVisitCount = getKetoneVisitCount()
            let skippedFirst = skipFirstReminder
            
            let hasHighSecondKetone = (secondUrineKetoneValue == .eight || secondUrineKetoneValue == .sixteen) ||
            (secondBloodKetoneValue == .large)
            
            let hasModerateFirstKetones = (firstUrineKetoneValue == .zeroPointFive || firstUrineKetoneValue == .onePointFive || firstUrineKetoneValue == .four) ||
            (firstBloodKetoneValue == .moderate)
            
            print("🔍 Blood sugar recheck - Yes (≥180)")
            print("   - Reminder page visit count: \(visitCount)")
            print("   - Ketone check visit count: \(ketoneCheckVisitCount)")
            print("   - Skipped first: \(skippedFirst)")
            
            if skippedFirst == false {
                if visitCount == 1 && ketoneCheckVisitCount == 2 {
                    showFinalStage(stage: .reminder, calculation: nil)
                } else if visitCount == 2 && ketoneCheckVisitCount == 3 {
                    triggerCallChoaEmergencyActionFlow(currentQuestion)
                } else if visitCount == 3 && ketoneCheckVisitCount == 3 {
                    triggerRecheckKetonesActionFlow(currentQuestion)
                }
            } else {
                if visitCount == 0 && ketoneCheckVisitCount == 1 {
                    showFinalStage(stage: .reminder, calculation: nil)
                } else if visitCount == 1 && ketoneCheckVisitCount == 1 {
                    triggerRecheckKetonesActionFlow(currentQuestion)
                }  else if visitCount == 1 && ketoneCheckVisitCount == 2 {
                    triggerCallChoaEmergencyActionFlow(currentQuestion)
                } else if visitCount == 2 && ketoneCheckVisitCount == 2 {
                    triggerRecheckKetonesActionFlow(currentQuestion)
                }
            }
        } else {
            triggerCallChoaActionFlow(currentQuestion)
        }
    }

    /// Blood sugar recheck answered below the threshold.
    private func triggerBloodSugarRecheckBelowActionFlow(_ currentQuestion: Questionnaire) {
        if iLetPump {
            let visitCount = getReminderPageVisitCount()
            let ketoneCheckVisitCount = getKetoneVisitCount()
            let skippedFirst = skipFirstReminder
            
            let hasHighFirstKetone = (firstUrineKetoneValue == .eight || firstUrineKetoneValue == .sixteen) ||
            (firstBloodKetoneValue == .large)
            
            let hasHighSecondKetone = (secondUrineKetoneValue == .eight || secondUrineKetoneValue == .sixteen) ||
            (secondBloodKetoneValue == .large)
            
            print("🔍 Blood sugar recheck - NO (≤180)")
            print("   - Reminder page visit count: \(visitCount)")
            print("   - Ketone check visit count: \(ketoneCheckVisitCount)")
            print("   - Skipped first: \(skippedFirst)")
            
            if skippedFirst == false {
                if visitCount == 1 && ketoneCheckVisitCount == 2 {
                    triggerContinueActionFlow(currentQuestion)
                } else if visitCount == 2 && ketoneCheckVisitCount == 3 {
                    if urineKetones == .negative || bloodKetones == .low {
                        if hasHighSecondKetone {
                            triggerContinueWithDescriptionActionFlow(currentQuestion)
                        } else {
                            triggerContinueActionFlow(currentQuestion)
                        }
                    } else {
                        triggerCallChoaEmergencyActionFlow(currentQuestion)
                    }
                } else if visitCount == 3 && ketoneCheckVisitCount == 3 {
                    triggerCallChoaEmergencyActionFlow(currentQuestion)
                }
            } else {
                if visitCount == 0 && ketoneCheckVisitCount == 1 {
                    triggerCallChoaEmergencyActionFlow(currentQuestion)
                } else if visitCount == 1 && ketoneCheckVisitCount == 1 {
                    triggerCallChoaEmergencyActionFlow(currentQuestion)
                } else if visitCount == 1 && ketoneCheckVisitCount == 2 {
                    if urineKetones == .negative || bloodKetones == .low {
                        if hasHighFirstKetone {
                            triggerContinueWithDescriptionActionFlow(currentQuestion)
                        } else {
                            triggerContinueActionFlow(currentQuestion)
                        }
                    } else {
                        triggerCallChoaEmergencyActionFlow(currentQuestion)
                    }
                } else if visitCount == 2 && ketoneCheckVisitCount == 2 {
                    triggerCallChoaEmergencyActionFlow(currentQuestion)
                }
            }
        } else if currentTestType == .pump && yesOver2hours && (
            urineKetones == .negative || urineKetones == .zeroPointFive || bloodKetones == .low) {
            triggerContinueActionFlow(currentQuestion)
        } else {
            triggerCallChoaEmergencyActionFlow(currentQuestion)
        }
    }

    /// Blood sugar recheck entered as a reading. iLet Pump users compare against 180 mg/dL, everyone else 150 mg/dL.
    /// At or over the threshold follows the old "Yes" path, under it follows the old "No" path.
    func triggerBloodSugarRecheckReadingActionFlow(_ currentQuestion: Questionnaire, bloodSugar: Int) {
        let threshold = iLetPump ? 180 : 150

        if bloodSugar > threshold {
            triggerBloodSugarRecheckAboveActionFlow(currentQuestion)
        } else {
            triggerBloodSugarRecheckBelowActionFlow(currentQuestion)
        }
    }

    func saveTestType(_ testType: TestType) {
        currentTestType = testType
    }

    func saveMeasuringMethod(_ method: MeasuringType) {
        let previousMethod = currentMeasuringMethod
        currentMeasuringMethod = method
        
        // Clear ketones when switching methods
        if previousMethod != method {
            if method == .urineKetone {
                // Switching to urine - clear blood ketones
                clearBloodKetoneLevel()
                print("🔄 Switched to urine ketone measurement")
            } else if method == .bloodKetone {
                // Switching to blood - clear urine ketones
                clearUrineKetoneLevel()
                print("🔄 Switched to blood ketone measurement")
            }
        }
    }

    func saveCalculationType(_ calculationType: CalculationType) {
        currentMethod = calculationType
        print(currentMethod)
    }
    
    
    func saveCGM(_ cgm: Bool) {
        self.cgm = cgm
    }

	func saveILetPump(_ iLetPump: Bool) {
		self.iLetPump = iLetPump
	}

	func saveBloodSugarOver300(_ over300: Bool) {
		self.bloodSugarOver300 = over300
	}

	func saveBloodSugarOver300For3Hours(_ over300: Bool) {
		self.bloodSugarOver300For3Hours = over300
	}

	func saveYesOver2hours(_ over2hours: Bool) {
		self.yesOver2hours = over2hours
	}
    
    func skipFirstReminder(_ skipFirstReminder: Bool) {
        self.skipFirstReminder = skipFirstReminder
    }

    func saveData(bloodSugar: Int, correctionFactor: Int) {
        self.bloodSugar = bloodSugar
        self.correctionFactor = correctionFactor
    }
    
    func saveKetones(type: KetonesMeasurements) {
        self.ketones = type
    }
    
    // MARK: - Urine Ketones

    func saveUrineKetoneLevel(level: UrineKetoneLevel) {
        self.urineKetones = level
        // Clear blood ketones when saving urine ketones
        clearBloodKetoneLevel()
        print("💾 Saved urine ketone level: \(level) (id: \(level.id))")
        print("🗑️ Cleared blood ketones (switched to urine)")
    }
    
    // Save first urine ketone value
    func saveFirstUrineKetoneValue(_ level: UrineKetoneLevel) {
        self.firstUrineKetoneValue = level
        print("💾 Saved FIRST urine ketone value: \(level) (id: \(level.id))")
    }

    // Save first blood ketone value
    func saveFirstBloodKetoneValue(_ level: BloodKetoneLevel) {
        self.firstBloodKetoneValue = level
        print("💾 Saved FIRST blood ketone value: \(level) (id: \(level.id))")
    }
    
    // Save second urine ketone value
    func saveSecondUrineKetoneValue(_ level: UrineKetoneLevel) {
        self.secondUrineKetoneValue = level
        print("💾 Saved SECOND urine ketone value: \(level) (id: \(level.id))")
    }

    // Save first blood ketone value
    func saveSecondBloodKetoneValue(_ level: BloodKetoneLevel) {
        self.secondBloodKetoneValue = level
        print("💾 Saved SECOND blood ketone value: \(level) (id: \(level.id))")
    }
    
    func clearUrineKetoneLevel() {
        self.urineKetones = nil
        print("🗑️ Cleared urine ketone level")
    }
    
    // MARK: - Blood Ketones
    
    func saveBloodKetoneLevel(level: BloodKetoneLevel) {
        self.bloodKetones = level
        print("💾 Saved blood ketone level: \(level) (id: \(level.id))")
    }
    
    func clearBloodKetoneLevel() {
        self.bloodKetones = nil
        print("🗑️ Cleared blood ketone level")
    }
    
    // MARK: Check/Get First Ketone Value If High or Moderate
    
    func hasHighFirstUrineKetones() -> Bool {
        guard let level = firstUrineKetoneValue else { return false }
        switch level {
        case .eight, .sixteen:
            return true
        case .zeroPointFive, .onePointFive, .four, .negative:
            return false
        }
    }
    
    // Check if we have moderate/high first urine ketones (0.5, 1.5, 4.0, 8.0, 16.0)
    func hasModerateFirstUrineKetones() -> Bool {
        guard let level = firstUrineKetoneValue else { return false }
        switch level {
        case .zeroPointFive, .onePointFive, .four, .negative:
            return true
        case .eight, .sixteen:
            return false
        }
    }
    
    // Check if we have moderate/high first urine ketones (0.5, 1.5, 4.0, 8.0, 16.0)
    func hasModerateOrHighFirstUrineKetones() -> Bool {
        guard let level = firstUrineKetoneValue else { return false }
        switch level {
        case .zeroPointFive, .onePointFive, .four, .eight, .sixteen:
            return true
        case .negative:
            return false
        }
    }
    
    func hasHighFirstBloodKetones() -> Bool {
        guard let level = firstBloodKetoneValue else { return false }
        switch level {
        case .large:
            return true
        case .low, .moderate:
            return false
        }
    }
    
    func hasModerateFirstBloodKetones() -> Bool {
        guard let level = firstBloodKetoneValue else { return false }
        switch level {
        case .moderate:
            return true
        case .low, .large:
            return false
        }
    }

    // Check if we have moderate/high first blood ketones (moderate, large)
    func hasModerateOrHighFirstBloodKetones() -> Bool {
        guard let level = firstBloodKetoneValue else { return false }
        switch level {
        case .moderate, .large:
            return true
        case .low:
            return false
        }
    }
    
    
    // MARK: - Helper to check which ketone type is active
        
    func hasUrineKetones() -> Bool {
        return urineKetones != nil
    }
    
    func hasBloodKetones() -> Bool {
        return bloodKetones != nil
    }
    
    func getActiveKetoneType() -> MeasuringType? {
        if urineKetones != nil {
            return .urineKetone
        } else if bloodKetones != nil {
            return .bloodKetone
        }
        return nil
    }
    
    func printCurrentKetoneState() {
        let activeType = getActiveKetoneType()
        print("""
        📊 Current Ketone State:
           - Active Method: \(currentMeasuringMethod)
           - Active Ketone Type: \(activeType?.description ?? "None")
           - Urine Ketones: \(String(describing: urineKetones))
           - Blood Ketones: \(String(describing: bloodKetones))
           - First Urine Ketone: \(String(describing: firstUrineKetoneValue))
           - First Blood Ketone: \(String(describing: firstBloodKetoneValue))
           - Second Urine Ketone: \(String(describing: secondUrineKetoneValue))
           - Second Blood Ketone: \(String(describing: secondBloodKetoneValue))
           - iLetPump: \(iLetPump)
           - skipFirstReminder: \(skipFirstReminder)
           - Reminder Visit Count: \(getReminderPageVisitCount())
           - Ketone Visit Count: \(getKetoneVisitCount())
        """)
    }

		//	Reminder Functions
	func saveActiveReminder(id: String, scheduledTime: Date) {
		self.activeReminderId = id
		self.reminderScheduledTime = scheduledTime
	}

	func clearActiveReminder() {
		self.activeReminderId = nil
		self.reminderScheduledTime = nil
	}

	func hasActiveReminder() -> Bool {
		guard let scheduledTime = reminderScheduledTime else { return false }
			// Check if reminder is still valid (not expired)
		return scheduledTime > Date()
	}

	func getRemainingTime() -> TimeInterval? {
		guard let scheduledTime = reminderScheduledTime else { return nil }
		let timeRemaining = scheduledTime.timeIntervalSince(Date())
		return timeRemaining > 0 ? timeRemaining : nil
	}

	func getActiveReminderId() -> String? {
		return activeReminderId
	}
    
    func triggerBloodSugarRecheckActionFlow(
        _ currentQuestion: Questionnaire,
    ) {
        let createQue = createBloodSugarRecheckQuestion()
        
        actionsDelegate?.showNextQuestion(createQue)
    }

	func triggerRecheckUrineKetoneActionFlow(
		_ currentQuestion: Questionnaire,
		urineLevel: UrineKetoneLevel,
	) {
		switch urineLevel {
				// Negative/Trace
		case .negative, .zeroPointFive:
			if bloodSugarOver300 && currentTestType == .pump {
                
                let createQue = iLetPump ? createBloodSugarRecheckQuestion() : createYesOrNoQuestion(
                    questionId: .bloodSugarRecheck,
                    question: "Calculator.Que.BloodSugarRecheckPump.title".localized(),
                    description: nil,
                    showDescriptionAtBottom: false
                )
                
                actionsDelegate?.showNextQuestion(createQue)
			}	else {
				showFinalStage(stage: .continueRegularCare, calculation: nil)
			}

				// Moderate risk (urine 1.5 or 4) OR blood moderate
        case .onePointFive, .four, .eight, .sixteen:
            if bloodSugarOver300 && yesOver2hours {
                let createQue = createBloodSugarRecheckQuestion()

                actionsDelegate?.showNextQuestion(createQue)

            } else if bloodSugarOver300 {
                triggerCallChoaActionFlow(currentQuestion)
            } else {
                let createQue = createBloodSugarRecheckQuestion()

                actionsDelegate?.showNextQuestion(createQue)
            }
		}
	}
    
    func triggerRecheckUrineKetoneForILetActionFlow(
        _ currentQuestion: Questionnaire,
        urineLevel: UrineKetoneLevel
    ) {
        let visitCount = getReminderPageVisitCount()
        let ketoneCheckVisitCount = getKetoneVisitCount()
        let skippedFirst = skipFirstReminder
        
        if ketoneCheckVisitCount == 2 {
            saveSecondUrineKetoneValue(urineLevel)
        }
        
        let hasHighFirstKetone = (firstUrineKetoneValue == .eight || firstUrineKetoneValue == .sixteen) ||
        (firstBloodKetoneValue == .large)
        
        let hasHighSecondKetone = (secondUrineKetoneValue == .eight || secondUrineKetoneValue == .sixteen) ||
        (secondBloodKetoneValue == .large)
        
        print("🧪 Recheck Urine Ketone")
        print("   - Visit count: \(visitCount)")
        print("   - Ketone check visit count: \(ketoneCheckVisitCount)")
        print("   - Skipped first: \(skippedFirst)")
        print("   - Level: \(urineLevel)")
        print("   - First ketone value: \(String(describing: firstUrineKetoneValue))")
        print("   - Second ketone value: \(String(describing: secondUrineKetoneValue))")
        
        switch urineLevel {
        case .negative:
            // Negative ketones - continue care
            
            if skippedFirst == false {
                if visitCount == 1 && ketoneCheckVisitCount == 2 {
                    print("   → Continue regular care (first visit after 2 ketone checks)")
                    triggerContinueActionFlow(currentQuestion)
                } else if visitCount == 2 && ketoneCheckVisitCount == 3 {
                    triggerBloodSugarRecheckActionFlow(currentQuestion)
                } else if visitCount == 3 && ketoneCheckVisitCount == 4 {
                    triggerContinueWithDescriptionActionFlow(currentQuestion)
                }
            } else {
                if visitCount == 1 && ketoneCheckVisitCount == 2 {
                    print("   → Skipped First Reminder")
                    print("   → Recheck blood sugar")
                    triggerBloodSugarRecheckActionFlow(currentQuestion)
                }
            }
            
        case .zeroPointFive, .onePointFive, .four:
            // Moderate ketones
            
            if skippedFirst == false {
                if visitCount == 1 && ketoneCheckVisitCount == 2 {
                    showFinalStage(stage: .reminder, calculation: nil)
                } else if visitCount == 2 && ketoneCheckVisitCount == 3 {
                    triggerBloodSugarRecheckActionFlow(currentQuestion)
                } else if visitCount == 3 && ketoneCheckVisitCount == 4 {
                    triggerCallChoaEmergencyActionFlow(currentQuestion)
                }
            } else {
                if visitCount == 1 && ketoneCheckVisitCount == 2 {
                    print("   → Recheck blood sugar (first visit after 2 ketone checks)")
                    triggerBloodSugarRecheckActionFlow(currentQuestion)
                } else if visitCount == 2 && ketoneCheckVisitCount == 3 {
                    triggerCallChoaEmergencyActionFlow(currentQuestion)
                }
            }
            
        case .eight, .sixteen:
            // High ketones
            
            if skippedFirst == false {
                if visitCount == 1 && ketoneCheckVisitCount == 2 {
                    showFinalStage(stage: .reminder, calculation: nil)
                } else if visitCount == 2 && ketoneCheckVisitCount == 3 {
                    triggerBloodSugarRecheckActionFlow(currentQuestion)
                } else if visitCount == 3 && ketoneCheckVisitCount == 4 {
                    triggerCallChoaEmergencyActionFlow(currentQuestion)
                }
            } else {
                if visitCount == 1 && ketoneCheckVisitCount == 2 {
                    print("   → Recheck blood sugar (first visit after 2 ketone checks)")
                    triggerBloodSugarRecheckActionFlow(currentQuestion)
                } else if visitCount == 2 && ketoneCheckVisitCount == 3 {
                    triggerCallChoaEmergencyActionFlow(currentQuestion)
                }
            }
        }
    }
    
	func triggerRecheckBloodKetoneActionFlow(
		_ currentQuestion: Questionnaire,
		bloodLevel: BloodKetoneLevel,
	) {
		switch bloodLevel {
				// Low urine OR low blood
		case .low:
			if bloodSugarOver300 && currentTestType == .pump {
                let createQue = iLetPump ? createBloodSugarRecheckQuestion() : createYesOrNoQuestion(
                    questionId: .bloodSugarRecheck,
                    question: "Calculator.Que.BloodSugarRecheckPump.title".localized(),
                    description: nil,
                    showDescriptionAtBottom: false
                )
                
                actionsDelegate?.showNextQuestion(createQue)
			} else {
				showFinalStage(stage: .continueRegularCare, calculation: nil)
			}
				// Moderate/Large risk (urine 1.5 or 4) OR blood moderate
		case .moderate, .large:
            if bloodSugarOver300 && yesOver2hours {
                let createQue = createBloodSugarRecheckQuestion()

                actionsDelegate?.showNextQuestion(createQue)

            } else if bloodSugarOver300 {
                triggerCallChoaActionFlow(currentQuestion)
            } else {
                let createQue = createBloodSugarRecheckQuestion()

                actionsDelegate?.showNextQuestion(createQue)
            }
		}
	}
    
    func triggerRecheckBloodKetoneForILetActionFlow(
        _ currentQuestion: Questionnaire,
        bloodLevel: BloodKetoneLevel
    ) {
        let visitCount = getReminderPageVisitCount()
        let ketoneCheckVisitCount = getKetoneVisitCount()
        let skippedFirst = skipFirstReminder
        
        if ketoneCheckVisitCount == 2 {
            saveSecondBloodKetoneValue(bloodLevel)
        }
        
        let hasHighFirstKetone = (firstUrineKetoneValue == .eight || firstUrineKetoneValue == .sixteen) ||
        (firstBloodKetoneValue == .large)
        
        let hasHighSecondKetone = (secondUrineKetoneValue == .eight || secondUrineKetoneValue == .sixteen) ||
        (secondBloodKetoneValue == .large)
        
        print("🩸 Recheck Blood Ketone")
        print("   - Visit count: \(visitCount)")
        print("   - Ketone check visit count: \(ketoneCheckVisitCount)")
        print("   - Skipped first: \(skippedFirst)")
        print("   - Level: \(bloodLevel)")
        print("   - First ketone value: \(String(describing: firstBloodKetoneValue))")
        print("   - Second ketone value: \(String(describing: secondBloodKetoneValue))")
        
        switch bloodLevel {
        case .low:
            
            if skippedFirst == false {
                if visitCount == 1 && ketoneCheckVisitCount == 2 {
                    print("   → Continue regular care (first visit after 2 ketone checks)")
                    triggerContinueActionFlow(currentQuestion)
                } else if visitCount == 2 && ketoneCheckVisitCount == 3 {
                    triggerBloodSugarRecheckActionFlow(currentQuestion)
                } else if visitCount == 3 && ketoneCheckVisitCount == 4 {
                    triggerContinueWithDescriptionActionFlow(currentQuestion)
                }
            } else {
                if visitCount == 1 && ketoneCheckVisitCount == 2 {
                    print("   → Skipped First Reminder")
                    print("   → Continue regular care (first visit after 2 ketone checks)")
                    triggerBloodSugarRecheckActionFlow(currentQuestion)
                } else if visitCount == 2 && ketoneCheckVisitCount == 3 {
                    triggerContinueWithDescriptionActionFlow(currentQuestion)
                }
            }
            
        case .moderate:
            // Moderate ketones
            
            if skippedFirst == false {
                if visitCount == 1 && ketoneCheckVisitCount == 2 {
                    print("   → Recheck blood sugar (first visit after 2 ketone checks)")
                    showFinalStage(stage: .reminder, calculation: nil)
                } else if visitCount == 2 && ketoneCheckVisitCount == 3 {
                    triggerBloodSugarRecheckActionFlow(currentQuestion)
                } else if visitCount == 3 && ketoneCheckVisitCount == 4 {
                    triggerCallChoaEmergencyActionFlow(currentQuestion)
                }
            } else {
                if visitCount == 1 && ketoneCheckVisitCount == 2 {
                    print("   → Recheck blood sugar (first visit after 2 ketone checks)")
                    triggerBloodSugarRecheckActionFlow(currentQuestion)
                } else if visitCount == 2 && ketoneCheckVisitCount == 3 {
                    triggerCallChoaEmergencyActionFlow(currentQuestion)
                }
            }
        case .large:
            // High ketones
            
            if skippedFirst == false {
                if visitCount == 1 && ketoneCheckVisitCount == 2 {
                    print("   → Recheck blood sugar (first visit after 2 ketone checks)")
                    showFinalStage(stage: .reminder, calculation: nil)
                } else if visitCount == 2 && ketoneCheckVisitCount == 3 {
                    triggerBloodSugarRecheckActionFlow(currentQuestion)
                } else if visitCount == 3 && ketoneCheckVisitCount == 4 {
                    triggerCallChoaEmergencyActionFlow(currentQuestion)
                }
            } else {
                if visitCount == 1 && ketoneCheckVisitCount == 2 {
                    print("   → Recheck blood sugar (first visit after 2 ketone checks)")
                    triggerBloodSugarRecheckActionFlow(currentQuestion)
                } else if visitCount == 2 && ketoneCheckVisitCount == 3 {
                    triggerCallChoaEmergencyActionFlow(currentQuestion)
                }
            }
        }
    }
    
    func triggerUrineKetoneForILetActionFlow(_ currentQuestion: Questionnaire, level: UrineKetoneLevel) {
        print("🧪 Initial Urine Ketone Check - Level: \(level)")
        
        saveFirstUrineKetoneValue(level)
        saveUrineKetoneLevel(level: level)
        
        let hasModerateKetones = (urineKetones == .zeroPointFive || urineKetones == .onePointFive || urineKetones == .four) || (bloodKetones == .moderate)
        
        let hasHighKetones = (urineKetones == .eight || urineKetones == .sixteen) ||
        (bloodKetones == .large)
        
        switch level {
        case .negative:
            skipFirstReminder(false)
            print("   → Show reminder (negative ketones)")
            showFinalStage(stage: .reminder, calculation: nil)
            
        case .zeroPointFive, .onePointFive, .four:
            skipFirstReminder(true)
            print("   → Skip reminder (moderate ketones)")
            if bloodSugarOver300 {
                if hasModerateKetones {
                    showFinalStage(stage: .reminder, calculation: nil)
                } else {
                    showFinalStage(stage: .reminder, calculation: nil)
                }
            } else {
                let createQue = createBloodSugarRecheckQuestion()
                actionsDelegate?.showNextQuestion(createQue)
            }
            
        case .eight, .sixteen:
            skipFirstReminder(true)
            print("   → Skip reminder (high ketones)")
            if bloodSugarOver300 {
                if hasModerateKetones {
                    showFinalStage(stage: .reminder, calculation: nil)
                } else {
                    showFinalStage(stage: .reminder, calculation: nil)
                }
            } else {
                let createQue = createBloodSugarRecheckQuestion()
                actionsDelegate?.showNextQuestion(createQue)
            }
        }
    }

	func triggerUrineKetoneLevelActionFlow(_ currentQuestion: Questionnaire, level: UrineKetoneLevel) {
		switch level {
		case .negative, .zeroPointFive:
			// Low/negative ketones - continue with regular care

			showFinalStage(stage: .reminder, calculation: nil)
		case .onePointFive, .four:
			// Moderate ketones - show warning and contact endocrinologist
            if bloodSugarOver300 {
                triggerCallChoaActionFlow(currentQuestion)
            } else {
                let createQue = createBloodSugarRecheckQuestion()

                actionsDelegate?.showNextQuestion(createQue)
            }
		case .eight, .sixteen:
			// High ketones - emergency situation
            if bloodSugarOver300 {
                triggerCallChoaActionFlow(currentQuestion)
            } else {
                let createQue = createBloodSugarRecheckQuestion()

                actionsDelegate?.showNextQuestion(createQue)
            }
		}
	}

	func triggerBloodKetoneLevelActionFlow(_ currentQuestion: Questionnaire, level: BloodKetoneLevel) {
		switch level {
		case .low:
			// Low blood ketones - continue with normal insulin calculation
			if yesOver2hours {
				showFinalStage(stage: .continueRegularCare, calculation: nil)
			} else {
				showFinalStage(stage: .reminder, calculation: nil)
			}
		case .moderate:
			// Moderate blood ketones - show warning
            if bloodSugarOver300 {
                triggerCallChoaActionFlow(currentQuestion)
            } else {
                let createQue = createBloodSugarRecheckQuestion()

                actionsDelegate?.showNextQuestion(createQue)
            }
		case .large:
			// Large blood ketones - emergency situation
            if bloodSugarOver300 {
                triggerCallChoaActionFlow(currentQuestion)
            } else {
                let createQue = createBloodSugarRecheckQuestion()

                actionsDelegate?.showNextQuestion(createQue)
            }
		}
	}
    
    func triggerBloodKetoneForILetActionFlow(_ currentQuestion: Questionnaire, level: BloodKetoneLevel) {
        print("🩸 Initial Blood Ketone Check - Level: \(level)")
        
        if firstBloodKetoneValue == nil {
            saveFirstBloodKetoneValue(level)
        }
        saveBloodKetoneLevel(level: level)
        
        let hasModerateKetones = (urineKetones == .zeroPointFive || urineKetones == .onePointFive || urineKetones == .four) ||
        (bloodKetones == .moderate)
        
        let hasHighKetones = (urineKetones == .eight || urineKetones == .sixteen) ||
        (bloodKetones == .large)
        
        switch level {
        case .low:
            skipFirstReminder(false)
            print("   → Show reminder (low ketones)")
            showFinalStage(stage: .reminder, calculation: nil)
            
        case .moderate:
            skipFirstReminder(true)
            print("   → Skip reminder (moderate ketones)")
            if bloodSugarOver300 {
                if hasModerateKetones {
                    showFinalStage(stage: .reminder, calculation: nil)
                } else {
                    showFinalStage(stage: .reminder, calculation: nil)
                }
            } else {
                if bloodSugarOver300 {
                    if hasModerateKetones {
                        showFinalStage(stage: .reminder, calculation: nil)
                    } else {
                        showFinalStage(stage: .reminder, calculation: nil)
                    }
                } else {
                    let createQue = createBloodSugarRecheckQuestion()
                    actionsDelegate?.showNextQuestion(createQue)
                }
            }
            
        case .large:
            skipFirstReminder(true)
            print("   → Skip reminder (high ketones)")
            if bloodSugarOver300 {
                if hasModerateKetones {
                    showFinalStage(stage: .reminder, calculation: nil)
                } else {
                    showFinalStage(stage: .reminder, calculation: nil)
                }
            } else {
                if bloodSugarOver300 {
                    if hasModerateKetones {
                        showFinalStage(stage: .reminder, calculation: nil)
                    } else {
                        showFinalStage(stage: .reminder, calculation: nil)
                    }
                } else {
                    let createQue = createBloodSugarRecheckQuestion()
                    actionsDelegate?.showNextQuestion(createQue)
                }
            }
        }
    }
    
    func triggerTestActionFlow(_ currentQuestion: Questionnaire) {
		if currentTestType == .insulinShots {
			saveILetPump(false)
			let createQue = createBloodSugarCheckQuestion()

			actionsDelegate?.showNextQuestion(createQue)
		} else if currentTestType == .pump {
//            let createQue = createTwoCustomOptionsQuestion(questionId: .calculationType, question: "Calculator.Que.Method.title".localized(), description: "Calculator.Que.Method.description".localized(), answerOptions: ["Calculator.Que.Method.option1".localized(), "Calculator.Que.Method.option2".localized()])
			let createQue = createBloodSugarCheckQuestion()

			actionsDelegate?.showNextQuestion(createQue)
		}
    }

	func triggerCallChoaActionFlow(_ currentQuestion: Questionnaire) {
		showFinalStage(stage: .callChoa, calculation: nil)
	}

	func triggerCallChoaEmergencyActionFlow(_ currentQuestion: Questionnaire) {
		showFinalStage(stage: .callChoaEmergency, calculation: nil)
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
            let createQue = createBloodSugarCheckQuestion()
            actionsDelegate?.showNextQuestion(createQue)
        }
    }
    
    /// Routes the answer to the blood sugar reading question. Relies on
    /// `bloodSugarOver300` and `bloodSugarOver300For3Hours` being saved first.
    func triggerBloodSugarReadingActionFlow(_ currentQuestion: Questionnaire) {
        // Any reading of 300 or higher (with a duration selected) goes straight to the ketone check
        if bloodSugarOver300 {
            triggerKetoneMeasuringTypeActionFlow(currentQuestion)
        } else {
            triggerOtherSymptomsActionFlow(currentQuestion)
        }
    }

    func triggerBloodSugarActionFlow(_ currentQuestion: Questionnaire) {
        if currentMethod == .scale {
            let createQue = createOpenEndedMultipleInpQuestion(questionId: .bloodSugar, question: "Calculator.Que.BloodSugar.title".localized(), subQuestion: "Calculator.Que.BloodSugar.subQue.Scale".localized(), inputUnit: "Calculator.Que.BloodSugar.unit".localized(), description: "Calculator.Que.BloodSugar.description".localized(), showDescriptionAtBottom: true)
            actionsDelegate?.showNextQuestion(createQue)
        } else {
            let createQue = createOpenEndedMultipleInpQuestion(questionId: .bloodSugar, question: "Calculator.Que.BloodSugar.title".localized(), subQuestion: "Calculator.Que.BloodSugar.subQue".localized(), inputUnit: "Calculator.Que.BloodSugar.unit".localized(), description: "Calculator.Que.BloodSugar.description".localized(), showDescriptionAtBottom: true)
            actionsDelegate?.showNextQuestion(createQue)
        }
    }

	func triggerKetoneMeasuringTypeActionFlow(_ currentQuestion: Questionnaire) {
		let createQue = createTwoCustomOptionsQuestion(questionId: .measuringType, question: "Calculator.Que.KetonesMeasuringType.title".localized(), description: nil, answerOptions: [
			"Calculator.Que.KetonesMeasuringType.option1".localized(),
			"Calculator.Que.KetonesMeasuringType.option2".localized()]
		)
		actionsDelegate?.showNextQuestion(
			createQue
		)
	}

	func triggerRecheckKetonesActionFlow(_ currentQuestion: Questionnaire) {
        if (iLetPump && skipFirstReminder && getReminderPageVisitCount() == 1)  {
            showFinalStage(stage: .recheckKetoneLevel, calculation: nil)
        } else {
            showFinalStage(stage: .recheckKetoneLevel, calculation: nil)
        }
	}
    
    func triggerNextDoseActionFlow() {
        showFinalStage(stage: .nextDose, calculation: nil)
    }
    
    func triggerFullDoseActionFlow() {
        showFinalStage(stage: .fullDose, calculation: nil)
    }

	func triggerFirstEmergencyActionFlow(_ currentQuestion: Questionnaire) {
		showFinalStage(stage: FinalQuestionId.firstEmergencyScreen, calculation: nil)
	}

	func triggerContinueActionFlow(_ currentQuestion: Questionnaire) {
		showFinalStage(stage: .continueRegularCare, calculation: nil)
	}
    
    func triggerContinueWithDescriptionActionFlow(_ currentQuestion: Questionnaire) {
        showFinalStage(
            stage: .continueRegularCareWithDescription,
            calculation: nil
        )
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
    func createFinalStage(questionId: Int, title: String, description: String?, imageName: String? = nil) -> Questionnaire {
        let finalStepObj = FinalStep()
        finalStepObj.title = title
        finalStepObj.description = description
		finalStepObj.imageName = imageName

        let quesObj = Questionnaire()
        quesObj.questionId = questionId
        quesObj.questionType = .finalStep(FinalQuestionId(id: questionId))

		quesObj.finalStep = finalStepObj
        return quesObj
    }
    
    // TODO: Rework Final Stages

	func createFinalStageNoDescription(questionId: Int, title: String, imageName: String? = nil) -> Questionnaire {
		let finalStepObj = FinalStep()
		finalStepObj.title = title
		finalStepObj.imageName = imageName

		let quesObj = Questionnaire()
		quesObj.questionId = questionId
		quesObj.questionType = .finalStepNoDesc(FinalQuestionId(id: questionId))
		quesObj.finalStep = finalStepObj
		return quesObj
	}

	func createFinalStageWithDescription(questionId: Int, title: String) -> Questionnaire {
		let finalStepObj = FinalStep()
		finalStepObj.title = title

		let quesObj = Questionnaire()
		quesObj.questionId = questionId
		quesObj.questionType = .finalStepWithDesc(FinalQuestionId(id: questionId))
		quesObj.finalStep = finalStepObj
		return quesObj
	}

	func createFinalStageWithReminder(questionId: Int, title: String) -> Questionnaire {
		let finalStepObj = FinalStep()
		finalStepObj.title = title

		let quesObj = Questionnaire()
		quesObj.questionId = questionId
		quesObj.questionType = .reminder(FinalQuestionId(id: questionId))
		quesObj.finalStep = finalStepObj
		return quesObj
	}

	func createFinalStageCallChoa(questionId: Int, title: String) -> Questionnaire {
		let finalStepObj = FinalStep()
		finalStepObj.title = title

		let quesObj = Questionnaire()
		quesObj.questionId = questionId
		quesObj.questionType = .callChoa(FinalQuestionId(id: questionId))
		quesObj.finalStep = finalStepObj
		return quesObj
	}

	func createFinalStageCallChoaEmergency(questionId: Int, title: String) -> Questionnaire {
		let finalStepObj = FinalStep()
		finalStepObj.title = title

		let quesObj = Questionnaire()
		quesObj.questionId = questionId
		quesObj.questionType = .callChoaEmergency(FinalQuestionId(id: questionId))
		quesObj.finalStep = finalStepObj
		return quesObj
	}

	func createRecheckKetoneStage(questionId: Int, title: String) -> Questionnaire {
		let finalStepObj = FinalStep()
		finalStepObj.title = title

		let quesObj = Questionnaire()
		quesObj.questionId = questionId
		quesObj.questionType = .recheckKetoneLevel(FinalQuestionId(id: questionId))
		quesObj.finalStep = finalStepObj
		return quesObj
	}

    
    func showFinalStage(stage: FinalQuestionId, calculation: Float?) {
        switch stage {
        case .firstEmergencyScreen:
			let finalStepObj = createFirstEmergencyStage(questionId: stage.id, title: "Calculator.Final.FirstEmergency.title".localized())
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
            let finalStepObj = createFinalStage(questionId: stage.id, title: "Calculator.Final.FullDose.title".localized(), description: "Calculator.Final.ContinueRegularCare.description".localized())
            actionsDelegate?.showNextQuestion(finalStepObj)
		case .continueRegularCare:
			let finalStepObj = createFinalStageNoDescription(
				questionId: stage.id,
				title: "Calculator.Final.ContinueRegularCare.title".localized(),
				imageName: "hope_regular_care"
			)
			actionsDelegate?.showNextQuestion(finalStepObj)
		case .continueRegularCareWithDescription:
			let finalStepObj = createFinalStageWithDescription(
				questionId: stage.id,
				title: "Calculator.Final.ContinueRegularCare.title".localized(),
			)
			actionsDelegate?.showNextQuestion(finalStepObj)
		case .reminder:
			let finalStepObj = createFinalStageWithReminder(
				questionId: stage.id,
				title: "You can manage this at home by following these steps:",
			)
			actionsDelegate?.showNextQuestion(finalStepObj)
		case .callChoa:
			let finalStepObj = createFinalStageCallChoa(
				questionId: stage.id,
				title: "You can manage this at home by following these steps:",
			)
			actionsDelegate?.showNextQuestion(finalStepObj)
		case .callChoaEmergency:
			let finalStepObj = createFinalStageCallChoaEmergency(
				questionId: stage.id,
				title: "Call your care team or doctor for further instructions",
			)
			actionsDelegate?.showNextQuestion(finalStepObj)
		case .recheckKetoneLevel:
			let finalStepObj = createRecheckKetoneStage(questionId: stage.id, title: "Calculator.Final.RecheckKetone.title".localized())
			actionsDelegate?.showNextQuestion(finalStepObj)
		case .treatLowBloodSugar15g:
			let finalStepObj = createFinalStageWithReminder(
				questionId: stage.id,
				title: "Final.TreatLowBloodSugar15g.title".localized(),
			)
			actionsDelegate?.showNextQuestion(finalStepObj)
		case .treatLowBloodSugar8g:
			let finalStepObj = createFinalStageWithReminder(
				questionId: stage.id,
				title: "Final.TreatLowBloodSugar8g.title".localized(),
			)
			actionsDelegate?.showNextQuestion(finalStepObj)
		case .continueDMMP:
			let finalStepObj = createFinalStageNoDescription(
				questionId: stage.id,
				title: "Calculator.Final.ContinueDMMP.title".localized(),
				imageName: "hope_normal_care"
			)
			actionsDelegate?.showNextQuestion(finalStepObj)
		case .performFingerStickTest:
			let quesObj = Questionnaire()
			quesObj.questionId = stage.id
			quesObj.questionType = .performFingerStickTest(stage)
			actionsDelegate?.showNextQuestion(quesObj)
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
    
    func createBloodSugarCheckQuestion() -> Questionnaire {
        let quesObj = Questionnaire()
        quesObj.questionId = OpenEndedWithMultipleInputQuestionId.bloodSugarCheck.id
        quesObj.questionType = .openEndedWithMultipleInput(.bloodSugarCheck)
        quesObj.question = "Calculator.Que.BloodSugarReading.title".localized()
        quesObj.subQuestion = "Calculator.Que.BloodSugarDuration.title".localized()
        quesObj.inputUnit = "Calculator.Que.BloodSugar.unit".localized()
        return quesObj
    }

    /// Asks for the blood sugar reading on recheck. Unlike the first check, there is no duration follow-up.
    func createBloodSugarRecheckQuestion() -> Questionnaire {
        let quesObj = Questionnaire()
        quesObj.questionId = OpenEndedWithMultipleInputQuestionId.bloodSugarRecheck.id
        quesObj.questionType = .openEndedWithMultipleInput(.bloodSugarRecheck)
        quesObj.question = "Calculator.Que.BloodSugarReading.title".localized()
        quesObj.inputUnit = "Calculator.Que.BloodSugar.unit".localized()
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

	func createFirstEmergencyStage(questionId: Int, title: String) -> Questionnaire {

		let finalStepObj = FinalStep()
		finalStepObj.title = title

		let quesObj = Questionnaire()
		quesObj.questionId = questionId
		quesObj.questionType = .firstEmergency(FinalQuestionId(id: questionId))
		quesObj.finalStep = finalStepObj
		return quesObj
	}


	func createFourCustomOptionsQuestion(questionId: FourOptionsQuestionId, question: String, description: String?, answerOptions: [String]) -> Questionnaire {
		let quesObj = Questionnaire()
		quesObj.questionId = questionId.id
		quesObj.questionType = .fourOptions(questionId)
		quesObj.question = question
		quesObj.description = description
		quesObj.answerOptions = answerOptions
		return quesObj
	}

	func createFiveCustomOptionsQuestion(questionId: FiveOptionsQuestionId, question: String, description: String?, answerOptions: [String]) -> Questionnaire {
		let quesObj = Questionnaire()
		quesObj.questionId = questionId.id
		quesObj.questionType = .fiveOptions(questionId)
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

    /// Clears everything recorded since ketones were first measured: the current, first and
    /// second ketone readings, the over-2-hours flag and the visit counts.
    /// Used when the user backs out to (or before) the question where the ketone check starts.
    func resetKetoneProgress() {
        var updated = session
        updated.yesOver2hours = false
        updated.urineKetones = nil
        updated.bloodKetones = nil
        updated.firstUrineKetoneValue = nil
        updated.firstBloodKetoneValue = nil
        updated.secondUrineKetoneValue = nil
        updated.secondBloodKetoneValue = nil
        updated.visitCounts = VisitCounts()
        updated.visitCountsBeforeStack = VisitCounts()
        session = updated
        print("🗑️ Ketone progress reset")
    }

    /// Starts a new Get Help session. The instance is long-lived (views and view controllers
    /// keep a reference to it), so the session state is cleared in place rather than replaced.
    func reset() {
        session = GetHelpSession()

        print("🔄 QuestionnaireManager session completely reset")
    }
}

extension QuestionnaireManager {
    
    // MARK: - Visit Counts

    func getReminderPageVisitCount() -> Int {
        session.visitCounts.reminderPages
    }

    func getKetoneVisitCount() -> Int {
        session.visitCounts.ketoneChecks
    }

    /// Recounts visits from the questions on the navigation stack, oldest first. Called each time
    /// a Get Help screen appears, so popping back drops the screens that were left automatically.
    func updateVisitCounts(for path: [Questionnaire]) {
        session.visitCounts = session.visitCountsBeforeStack + visitCounts(in: path)
    }

    /// Keeps the current counts when the navigation stack is about to be discarded
    /// (e.g. a reminder notification pops to Home and pushes the recheck screen).
    func carryVisitCountsPastStack() {
        session.visitCountsBeforeStack = session.visitCounts
    }

    /// Restores a session saved with a reminder and re-shows that reminder page on a fresh stack.
    /// The saved counts already include the reminder page, so it's taken back out of the carried
    /// counts; the page is counted again from the stack once it appears.
    func restoreSession(_ restored: GetHelpSession, reshowing question: Questionnaire) {
        session = restored

        var updated = session
        updated.visitCountsBeforeStack = restored.visitCounts - visitCounts(in: [question])
        updated.visitCounts = updated.visitCountsBeforeStack
        session = updated
    }

    private func visitCounts(in path: [Questionnaire]) -> VisitCounts {
        var counts = VisitCounts()

        for question in path {
            guard let questionType = question.questionType else { continue }

            switch questionType {
            case .twoOptions(.measuringType), .recheckKetoneLevel:
                counts.ketoneChecks += 1
            case .reminder:
                if iLetPump && !FinalQuestionId(id: question.questionId).isLowBloodSugarTreatment {
                    counts.reminderPages += 1
                }
            default:
                break
            }
        }

        return counts
    }

    // MARK: - Session Persistence

    private func saveSession() {
        guard let data = try? JSONEncoder().encode(session) else { return }
        UserDefaults.standard.set(data, forKey: Self.sessionKey)
    }

    private static func loadSession() -> GetHelpSession? {
        guard let data = UserDefaults.standard.data(forKey: sessionKey) else { return nil }
        return try? JSONDecoder().decode(GetHelpSession.self, from: data)
    }

    /// Keys from before the session was saved as one value
    private static func removeLegacyKeys() {
        [
            "persistedUrineKetoneLevel", "persistedBloodKetoneLevel",
            "firstUrineKetoneValue", "firstBloodKetoneValue",
            "secondUrineKetoneValue", "secondBloodKetoneValue",
            "reminderPageVisitCount", "ketoneVisitCount"
        ].forEach(UserDefaults.standard.removeObject(forKey:))
    }
}


// MARK: - Add description for debugging (add to UrineKetoneLevel enum)
extension UrineKetoneLevel: CustomStringConvertible {
    var description: String {
        switch self {
        case .negative: return "Negative"
        case .zeroPointFive: return "0.5"
        case .onePointFive: return "1.5"
        case .four: return "4.0"
        case .eight: return "8.0"
        case .sixteen: return "16.0"
        }
    }
    
    var id: Int {
        switch self {
        case .negative: return 1
        case .zeroPointFive: return 2
        case .onePointFive: return 3
        case .four: return 4
        case .eight: return 5
        case .sixteen: return 6
        }
    }
}

// MARK: - Add description for debugging (add to BloodKetoneLevel enum)
extension BloodKetoneLevel: CustomStringConvertible {
    var description: String {
        switch self {
        case .low: return "Low (<0.6)"
        case .moderate: return "Moderate (0.6-1.5)"
        case .large: return "Large (>1.5)"
        }
    }
    
    var id: Int {
        switch self {
        case .low: return 1
        case .moderate: return 2
        case .large: return 3
        }
    }
}

