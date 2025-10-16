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
    func triggerSkipReminderActionFlow(_ currentQuestion: Questionnaire)
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
    
        // Track Reminder Page Visits
    func incrementReminderPageVisitCount()
    func decrementReminderPageVisitCount()
    func getReminderPageVisitCount() -> Int
    func resetReminderPageVisitCount()
}

class QuestionnaireManager: QuestionnaireManagerProvider  {
    
    
	static var instance: QuestionnaireManager = QuestionnaireManager()
    var actionsDelegate: QuestionnaireActionsProtocol?
    
    private(set) var currentTestType: TestType = .pump
	private(set) var currentMeasuringMethod: MeasuringType = .urineKetone
	private(set) var currentChildIssue: ChildIssue = .diabeticKetoacidosis
    var currentMethod: CalculationType = .formula
    private(set) var cgm: Bool = true
	private(set) var iLetPump: Bool = false
	private(set) var bloodSugarOver300: Bool = false
	private(set) var bloodSugarOver300For3Hours: Bool = false
    private(set) var bloodSugar: Int = 0
    private(set) var correctionFactor: Int = 0
    private(set) var ketones: KetonesMeasurements?
	private(set) var urineKetones: UrineKetoneLevel?
	private(set) var bloodKetones: BloodKetoneLevel?
	private(set) var yesOver2hours: Bool = false
    private(set) var skipFirstReminder: Bool = false

	private(set) var activeReminderId: String?
	private(set) var reminderScheduledTime: Date?

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

	func triggerOtherSymptomsActionFlow(_ currentQuestion: Questionnaire) {
		switch currentQuestion.questionId {
		case YesOrNoQuestionId.bloodSugarCheck.id:
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
            if iLetPump {
                if skipFirstReminder && getReminderPageVisitCount() >= 1 {
                    showFinalStage(
                        stage: .continueRegularCareWithDescription,
                        calculation: nil
                    )
                } else {
                    showFinalStage(stage: .reminder, calculation: nil)
                }
            } else {
                triggerCallChoaActionFlow(currentQuestion)
            }
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
            if iLetPump {
                let visitCount = getReminderPageVisitCount()
                
                if visitCount == 1 && skipFirstReminder == false {
                    triggerContinueActionFlow(currentQuestion)
                } else if visitCount > 2 {
                    triggerCallChoaEmergencyActionFlow(currentQuestion)
                } else {
                    triggerCallChoaEmergencyActionFlow(currentQuestion)
                }
            } else if currentTestType == .pump && yesOver2hours && (
                urineKetones == .negative || urineKetones == .zeroPointFive || bloodKetones == .low) {
                triggerContinueActionFlow(currentQuestion)
            } else {
                triggerCallChoaEmergencyActionFlow(currentQuestion)
            }
        case YesOrNoQuestionId.shotTwentyFourHours.id:
            triggerNextDoseActionFlow()
        default:
            return
        }
        
    }
    
    func saveTestType(_ testType: TestType) {
        currentTestType = testType
    }

	func saveMeasuringMethod(_ method: MeasuringType) {
		currentMeasuringMethod = method
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

	func saveUrineKetoneLevel(level: UrineKetoneLevel) {
		self.urineKetones = level
	}

	func saveBloodKetoneLevel(level: BloodKetoneLevel) {
		self.bloodKetones = level
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

	func triggerRecheckUrineKetoneActionFlow(
		_ currentQuestion: Questionnaire,
		urineLevel: UrineKetoneLevel,
	) {
		switch urineLevel {
				// Negative/Trace
		case .negative, .zeroPointFive:
			if bloodSugarOver300 && currentTestType == .pump {
//				showFinalStage(stage: .callChoa, calculation: nil)
                
                let createQue = createYesOrNoQuestion(
                    questionId: .bloodSugarRecheck,
                    question: iLetPump ? "Calculator.Que.BloodSugarRecheckILetPump.title"
                        .localized() : "Calculator.Que.BloodSugarRecheckPump.title".localized(),
                    description: nil,
                    showDescriptionAtBottom: false
                )
                
                actionsDelegate?.showNextQuestion(createQue)
			}	else {
				showFinalStage(stage: .continueRegularCare, calculation: nil)
			}
            
//        case .zeroPointFive:
//            if bloodSugarOver300 && currentTestType == .pump {
//                let createQue = createYesOrNoQuestion(
//                    questionId: .bloodSugarRecheck,
//                    question: iLetPump ? "Calculator.Que.BloodSugarRecheckILetPump.title"
//                        .localized() : "Calculator.Que.BloodSugarRecheckPump.title".localized(),
//                    description: nil,
//                    showDescriptionAtBottom: false
//                )
//                
//                actionsDelegate?.showNextQuestion(createQue)
//            }    else {
//                showFinalStage(stage: .continueRegularCare, calculation: nil)
//            }

				// Moderate risk (urine 1.5 or 4) OR blood moderate
        case .onePointFive, .four, .eight, .sixteen:
			let createQue = createYesOrNoQuestion(
				questionId: .bloodSugarRecheck,
				question: iLetPump ? "Calculator.Que.BloodSugarRecheckILetPump.title"
					.localized() :				"Calculator.Que.BloodSugarRecheck.title".localized(),
				description: nil,
				showDescriptionAtBottom: false
			)

			actionsDelegate?.showNextQuestion(createQue)
		}
	}
    
    func triggerRecheckUrineKetoneForILetActionFlow(
        _ currentQuestion: Questionnaire,
        urineLevel: UrineKetoneLevel
    ) {
        let reminderPageVisitCount = getReminderPageVisitCount()
        
        switch urineLevel {
        case .negative:
            if reminderPageVisitCount > 2 {
                triggerContinueWithDescriptionActionFlow(currentQuestion)
            } else {
                triggerContinueActionFlow(currentQuestion)
            }
        case .zeroPointFive, .onePointFive, .four:
            if reminderPageVisitCount > 2 {
                triggerCallChoaEmergencyActionFlow(currentQuestion)
            } else {
                let createQue = createYesOrNoQuestion(
                    questionId: .bloodSugarRecheck,
                    question: "Calculator.Que.BloodSugarRecheckILetPump.title"
                        .localized(),
                    description: nil,
                    showDescriptionAtBottom: false
                )
                
                actionsDelegate?.showNextQuestion(createQue)
            }
        case .eight, .sixteen:
            if reminderPageVisitCount > 2 {
                triggerCallChoaEmergencyActionFlow(currentQuestion)
            } else {
                let createQue = createYesOrNoQuestion(
                    questionId: .bloodSugarRecheck,
                    question: "Calculator.Que.BloodSugarRecheckILetPump.title"
                        .localized(),
                    description: nil,
                    showDescriptionAtBottom: false
                )
                
                actionsDelegate?.showNextQuestion(createQue)
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
                let createQue = createYesOrNoQuestion(
                    questionId: .bloodSugarRecheck,
                    question: iLetPump ? "Calculator.Que.BloodSugarRecheckILetPump.title"
                        .localized() : "Calculator.Que.BloodSugarRecheckPump.title".localized(),
                    description: nil,
                    showDescriptionAtBottom: false
                )
                
                actionsDelegate?.showNextQuestion(createQue)
			} else {
				showFinalStage(stage: .continueRegularCare, calculation: nil)
			}
				// Moderate/Large risk (urine 1.5 or 4) OR blood moderate
		case .moderate, .large:
			let createQue = createYesOrNoQuestion(
				questionId: .bloodSugarRecheck,
				question: iLetPump ? "Calculator.Que.BloodSugarRecheckILetPump.title"
					.localized() :	"Calculator.Que.BloodSugarRecheck.title".localized(),
				description: nil,
				showDescriptionAtBottom: false
			)

			actionsDelegate?.showNextQuestion(createQue)
		}
	}
    
    func triggerRecheckBloodKetoneForILetActionFlow(
        _ currentQuestion: Questionnaire,
        bloodLevel: BloodKetoneLevel,
    ) {
        let reminderPageVisitCount = getReminderPageVisitCount()
        
        switch bloodLevel {
                // Low urine OR low blood
        case .low:
            triggerContinueActionFlow(currentQuestion)
                // Moderate/Large risk (urine 1.5 or 4) OR blood moderate
        case .moderate:
            if reminderPageVisitCount > 2 {
                triggerCallChoaEmergencyActionFlow(currentQuestion)
            } else {
                let createQue = createYesOrNoQuestion(
                    questionId: .bloodSugarRecheck,
                    question: "Calculator.Que.BloodSugarRecheckILetPump.title"
                        .localized(),
                    description: nil,
                    showDescriptionAtBottom: false
                )
                
                actionsDelegate?.showNextQuestion(createQue)
            }
        case .large:
            if reminderPageVisitCount > 2 {
                triggerCallChoaEmergencyActionFlow(currentQuestion)
            } else {
                let createQue = createYesOrNoQuestion(
                    questionId: .bloodSugarRecheck,
                    question: "Calculator.Que.BloodSugarRecheckILetPump.title"
                        .localized(),
                    description: nil,
                    showDescriptionAtBottom: false
                )
                
                actionsDelegate?.showNextQuestion(createQue)
            }
        }
    }
    
    func triggerUrineKetoneForILetActionFlow(_ currentQuestion: Questionnaire, level: UrineKetoneLevel) {
        switch level {
        case .negative:
            showFinalStage(stage: .reminder, calculation: nil)
        case .zeroPointFive, .onePointFive, .four, .eight, .sixteen:
            
            skipFirstReminder(true)
            let createQue = createYesOrNoQuestion(
                questionId: .bloodSugarRecheck,
                question: "Calculator.Que.BloodSugarRecheckILetPump.title"
                    .localized(),
                description: nil,
                showDescriptionAtBottom: false
            )

            actionsDelegate?.showNextQuestion(createQue)
        }
    }


	func triggerUrineKetoneLevelActionFlow(_ currentQuestion: Questionnaire, level: UrineKetoneLevel) {
		switch level {
		case .negative, .zeroPointFive:
			// Low/negative ketones - continue with regular care

			showFinalStage(stage: .reminder, calculation: nil)
		case .onePointFive, .four:
			// Moderate ketones - show warning and contact endocrinologist
			let createQue = createYesOrNoQuestion(
				questionId: .bloodSugarRecheck,
				question: iLetPump ? "Calculator.Que.BloodSugarRecheckILetPump.title"
					.localized() :				"Calculator.Que.BloodSugarRecheck.title".localized(),
				description: nil,
				showDescriptionAtBottom: false
			)

			actionsDelegate?.showNextQuestion(createQue)
		case .eight, .sixteen:
			// High ketones - emergency situation
			let createQue = createYesOrNoQuestion(
				questionId: .bloodSugarRecheck,
				question: iLetPump ? "Calculator.Que.BloodSugarRecheckILetPump.title"
					.localized() :				"Calculator.Que.BloodSugarRecheck.title".localized(),
				description: nil,
				showDescriptionAtBottom: false
			)

			actionsDelegate?.showNextQuestion(createQue)
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
			let createQue = createYesOrNoQuestion(
				questionId: .bloodSugarRecheck,
				question: iLetPump ? "Calculator.Que.BloodSugarRecheckILetPump.title"
					.localized() :				"Calculator.Que.BloodSugarRecheck.title".localized(),
				description: nil,
				showDescriptionAtBottom: false
			)

			actionsDelegate?.showNextQuestion(createQue)
		case .large:
			// Large blood ketones - emergency situation
			let createQue = createYesOrNoQuestion(
				questionId: .bloodSugarRecheck,
				question: iLetPump ? "Calculator.Que.BloodSugarRecheckILetPump.title"
					.localized() :				"Calculator.Que.BloodSugarRecheck.title".localized(),
				description: nil,
				showDescriptionAtBottom: false
			)

			actionsDelegate?.showNextQuestion(createQue)
		}
	}
    
    func triggerBloodKetoneForILetActionFlow(_ currentQuestion: Questionnaire, level: BloodKetoneLevel) {
        let reminderPageVisitCount = getReminderPageVisitCount()

        switch level {
        case .low:
            if reminderPageVisitCount > 2 {
                triggerContinueWithDescriptionActionFlow(currentQuestion)
            } else {
                triggerContinueActionFlow(currentQuestion)
            }
        case .moderate:
            // Moderate blood ketones - show warning
            if reminderPageVisitCount > 2 {
                triggerCallChoaEmergencyActionFlow(currentQuestion)
            } else {
                let createQue = createYesOrNoQuestion(
                    questionId: .bloodSugarRecheck,
                    question: "Calculator.Que.BloodSugarRecheckILetPump.title"
                        .localized(),
                    description: nil,
                    showDescriptionAtBottom: false
                )
                
                actionsDelegate?.showNextQuestion(createQue)
            }
        case .large:
            // Large blood ketones - emergency situation
            let createQue = createYesOrNoQuestion(
                questionId: .bloodSugarRecheck,
                question: "Calculator.Que.BloodSugarRecheckILetPump.title"
                    .localized(),
                description: nil,
                showDescriptionAtBottom: false
            )

            actionsDelegate?.showNextQuestion(createQue)
        }
    }
    
    
    
    
    func triggerTestActionFlow(_ currentQuestion: Questionnaire) {
		if currentTestType == .insulinShots {
			saveILetPump(false)
			let createQue = createYesOrNoQuestion(questionId: .bloodSugarCheck, question: "Calculator.Que.BloodSugarCheck.title".localized(), description: nil, showDescriptionAtBottom: false)

			actionsDelegate?.showNextQuestion(createQue)
		} else if currentTestType == .pump {
//            let createQue = createTwoCustomOptionsQuestion(questionId: .calculationType, question: "Calculator.Que.Method.title".localized(), description: "Calculator.Que.Method.description".localized(), answerOptions: ["Calculator.Que.Method.option1".localized(), "Calculator.Que.Method.option2".localized()])
			let createQue = createYesOrNoQuestion(questionId: .bloodSugarCheck, question: "Calculator.Que.BloodSugarCheck.title".localized(), description: nil, showDescriptionAtBottom: false)

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
            let createQue = createYesOrNoQuestion(questionId: .bloodSugarCheck, question: "Calculator.Que.BloodSugarCheck.title".localized(), description: nil, showDescriptionAtBottom: false)
            actionsDelegate?.showNextQuestion(createQue)
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
        if (iLetPump && skipFirstReminder && (
            urineKetones == .eight || urineKetones == .sixteen || bloodKetones == .large)) ||
            (iLetPump && skipFirstReminder == false && (
                urineKetones == .eight || urineKetones == .sixteen || bloodKetones == .large) && getReminderPageVisitCount() >= 1)  {
            triggerSkipReminderActionFlow(currentQuestion)
        } else {
            showFinalStage(stage: .recheckKetoneLevel, calculation: nil)
        }
	}
    
    func triggerSkipReminderActionFlow(_ currentQuestion: Questionnaire) {
        let createQue = createYesOrNoQuestion(
            questionId: .bloodSugarRecheck,
            question: iLetPump ? "Calculator.Que.BloodSugarRecheckILetPump.title"
                .localized() :    "Calculator.Que.BloodSugarRecheck.title".localized(),
            description: nil,
            showDescriptionAtBottom: false
        )

        actionsDelegate?.showNextQuestion(createQue)
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

	static func resetInstance() {
		instance = QuestionnaireManager()
        instance.resetReminderPageVisitCount()
	}
}

extension QuestionnaireManager {
    
    private static let reminderPageVisitCountKey = "reminderPageVisitCount"
    
    func incrementReminderPageVisitCount() {
        guard iLetPump || currentTestType == .pump else { return }
        
        let currentCount = getReminderPageVisitCount()
        let newCount = currentCount + 1
        UserDefaults.standard.set(newCount, forKey: QuestionnaireManager.reminderPageVisitCountKey)
        
        print("📊 Reminder page visit count incremented: \(newCount)")
    }
    
    func decrementReminderPageVisitCount() {
        guard iLetPump else { return }
        
        let currentCount = getReminderPageVisitCount()
        guard currentCount > 0 else { return }
        
        let newCount = currentCount - 1
        UserDefaults.standard.set(newCount, forKey: QuestionnaireManager.reminderPageVisitCountKey)
        
        print("📊 Reminder page visit count decremented: \(newCount)")
    }
    
    func getReminderPageVisitCount() -> Int {
        return UserDefaults.standard.integer(forKey: QuestionnaireManager.reminderPageVisitCountKey)
    }
    
    func resetReminderPageVisitCount() {
        UserDefaults.standard.set(0, forKey: QuestionnaireManager.reminderPageVisitCountKey)
        print("📊 Reminder page visit count reset")
    }
}
