//
//  GetHelpViewController.swift
//  choa-diabetes-education
//

import UIKit

class GetHelpViewController: UIViewController {

    
    
    static let nibName = "GetHelp"

    @IBOutlet weak var yesOrNoQueView: YesOrNoQueView!
    @IBOutlet weak var finalStepView: FinalStepView!
	@IBOutlet weak var finalStepNoDescView: FinalStepNoDescView!
	@IBOutlet var finalStepWithDescView: FinalStepWithDescView!


    @IBOutlet weak var twoOptionsView: TwoOptionsView!
    @IBOutlet weak var openEndedQueView: OpenEndedQueView!
    @IBOutlet weak var multipleOptionsView: MultipleOptionsView!
    @IBOutlet weak var fourOptionsView: FourOptionsView!
	@IBOutlet weak var fiveOptionsView: FiveOptionsView!
	@IBOutlet var firstEmergencyView: FirstEmergencyView!
	@IBOutlet var finalStepCallChoaView: FinalStepCallChoaView!
	@IBOutlet var finalStepCallChoaEmergencyView: FinalStepCallChoaEmergencyView!
	@IBOutlet var finalStepWithReminderView: FinalStepWithReminderView!
	@IBOutlet var recheckKetoneLevelView: RecheckKetoneLevelView!


	private let questionObj: Questionnaire
    private let questionnaireManager: QuestionnaireManager = QuestionnaireManager.instance
    
    private let manager = QuestionnaireManager.instance
    
    private let navVC: UINavigationController
    
    init(navVC: UINavigationController, currentQuestion: Questionnaire) {
        self.questionObj = currentQuestion
        self.navVC = navVC
        super.init(nibName: GetHelpViewController.nibName, bundle: nil)
    }
    
    init?(navVC: UINavigationController, currentQuestion: Questionnaire, coder: NSCoder) {
        self.questionObj = currentQuestion
        self.navVC = navVC
        super.init(coder: coder)
    }

	required init?(coder: NSCoder) {
		self.questionObj = Questionnaire() // Initialize with a default value
		self.navVC = UINavigationController()
		super.init(coder: coder)
	}

//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    private var isReminderPageFirstAppearance = true
    private var hasAppearedFromPush = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationItem.backButtonDisplayMode = .minimal
        
        questionnaireManager.loadPersistedKetoneState()
        
        if isMovingToParent {
            hasAppearedFromPush = true
        }
        
        questionnaireManager.printCurrentKetoneState()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Track reminder page visits for iLet pump users
        // Only count when pushed (not when appearing from back navigation initially)
        if questionObj.questionType == .reminder(FinalQuestionId(id: questionObj.questionId)),
           questionnaireManager.iLetPump,
           hasAppearedFromPush {
            questionnaireManager.incrementReminderPageVisitCount()
            hasAppearedFromPush = false
            
            print("✅ Reminder page appeared - visit tracked")
            questionnaireManager.printCurrentKetoneState()
        }
        
        // Track ketone recheck visits when RecheckKetoneLevelView appears from push
        if questionObj.questionType == .recheckKetoneLevel(FinalQuestionId(id: questionObj.questionId)),
           hasAppearedFromPush {
            questionnaireManager.incrementKetoneVisitCount()
            hasAppearedFromPush = false
            
            print("✅ Ketone recheck page appeared - visit tracked")
            questionnaireManager.printCurrentKetoneState()
        }
    }

	override func viewDidLoad() {
		super.viewDidLoad()

			// Create appearance with transparent background
		let appearance = UINavigationBarAppearance()
		appearance.configureWithOpaqueBackground()
		appearance.shadowColor = .clear
		
			// Set the tint color on the appearance object itself
		appearance.buttonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.black]
		appearance.backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.black]

			// Apply the appearance
		navigationController?.navigationBar.standardAppearance = appearance
		navigationController?.navigationBar.scrollEdgeAppearance = appearance

			// IMPORTANT: Set tint color AFTER setting the appearance
		navigationController?.navigationBar.tintColor = UIColor.black
		navigationItem.backButtonDisplayMode = .minimal

		let icon = UIImage(named: "close_black")
		let rightButton = UIBarButtonItem(
			image: icon,
			style: .plain,
			target: self,
			action: #selector(didSelectExitAction)
		)
		navigationItem.rightBarButtonItem = rightButton

		self.questionnaireManager.actionsDelegate = self
		hideAllViews()
		setupViews()
	}
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)

        if isMovingFromParent {
            resetBackgroundColor()
            finalStepWithReminderView?.cleanup()
            
            print("⬅️ Popping from: \(String(describing: questionObj.questionType))")
            
            guard let previousVC = navigationController?.viewControllers.last as? GetHelpViewController else {
                return
            }
            
            print("   → Going back to: \(String(describing: previousVC.questionObj.questionType))")
            
            // ============================================================
            // REMINDER PAGE TRACKING
            // ============================================================
            if questionObj.questionType == .reminder(FinalQuestionId(id: questionObj.questionId)) {
                // Popping FROM reminder page
                
                if previousVC.questionObj.questionType == .yesOrNo(.bloodSugarRecheck) {
                    // Going back to blood sugar recheck
                    questionnaireManager.decrementReminderPageVisitCount()
                    print("   📊 Decremented reminder count (popping to bloodSugarRecheck)")
                }
                
                // Handle popping from reminder back to recheck ketone level
                if previousVC.questionObj.questionType == .recheckKetoneLevel(FinalQuestionId(id: previousVC.questionObj.questionId)) {
                    // Going back to recheck ketone level
                    questionnaireManager.decrementReminderPageVisitCount()
                    print("   📊 Decremented reminder count (popping to recheckKetoneLevel)")
                }
                
                if !previousVC.twoOptionsView.isHidden {
                    // Going back to test type selection - full reset
                    questionnaireManager.saveYesOver2hours(false)
                    questionnaireManager.resetReminderPageVisitCount()
                    questionnaireManager.resetKetoneVisitCount()
                    questionnaireManager.clearAllKetoneData()
                    questionnaireManager.clearFirstKetoneValues()
                    print("   🗑️ Full reset: popping back to test type selection from reminder")
                }
            }
            
            // ============================================================
            // KETONE RECHECK PAGE TRACKING
            // ============================================================
            if questionObj.questionType == .recheckKetoneLevel(FinalQuestionId(id: questionObj.questionId)) {
                // Popping FROM ketone recheck page
                
                if previousVC.questionObj.questionType == .reminder(FinalQuestionId(id: previousVC.questionObj.questionId)) {
                    // Going back to reminder page
                    questionnaireManager.decrementKetoneVisitCount()
                    print("   🧪 Decremented ketone count (popping to reminder page)")
                    
                    // Note: Ketones are preserved when going back to reminder
                    print("   ⚠️ Ketones PRESERVED when popping to reminder")
                }
                
                if previousVC.questionObj.questionType == .yesOrNo(.bloodSugarRecheck) {
                    // Going back to blood sugar recheck
                    questionnaireManager.decrementKetoneVisitCount()
                    print("   🧪 Decremented ketone count (popping to blood sugar recheck)")
                    
                    // Note: Ketones are preserved for the next check
                    print("   ⚠️ Ketones PRESERVED when popping to blood sugar recheck")
                }
                
                if previousVC.questionObj.questionType == .twoOptions(.measuringType) {
                    // Going back to measuring type selection - FULL RESET
                    questionnaireManager.resetReminderPageVisitCount()
                    questionnaireManager.resetKetoneVisitCount()
                    questionnaireManager.clearAllKetoneData()
                    questionnaireManager.clearFirstKetoneValues()
                    print("   🗑️ Full reset: popping to measuring type selection from recheck")
                }
                
                if !previousVC.twoOptionsView.isHidden && previousVC.questionObj.questionType == .twoOptions(.testType) {
                    // Going back to test type selection - full reset
                    questionnaireManager.saveYesOver2hours(false)
                    questionnaireManager.resetReminderPageVisitCount()
                    questionnaireManager.resetKetoneVisitCount()
                    questionnaireManager.clearAllKetoneData()
                    questionnaireManager.clearFirstKetoneValues()
                    print("   🗑️ Full reset: popping back to test type selection from recheck")
                }
            }
            
            // ============================================================
            // YES/NO VIEW TRACKING (Blood Sugar Recheck, etc.)
            // ============================================================
            if questionObj.questionType == .yesOrNo(.bloodSugarRecheck) {
                // Popping FROM blood sugar recheck page
                
                if previousVC.questionObj.questionType == .twoOptions(.measuringType) {
                    // Going back to measuring type selection - FULL RESET
                    questionnaireManager.resetReminderPageVisitCount()
                    questionnaireManager.resetKetoneVisitCount()
                    questionnaireManager.clearAllKetoneData()
                    questionnaireManager.clearFirstKetoneValues()
                    print("   🗑️ Full reset: popping to measuring type selection from blood sugar recheck")
                }
            }
            
            // ============================================================
            // GENERAL CLEANUP
            // ============================================================
            
            // Clear all data when going back to test type selection from ANY screen
            if !previousVC.twoOptionsView.isHidden &&
               previousVC.questionObj.questionType == .twoOptions(.testType) &&
               questionObj.questionType != .twoOptions(.testType) {
                
                questionnaireManager.saveYesOver2hours(false)
                questionnaireManager.resetReminderPageVisitCount()
                questionnaireManager.resetKetoneVisitCount()
                questionnaireManager.clearAllKetoneData()
                questionnaireManager.clearFirstKetoneValues()
                
                print("   🗑️ Full reset: popping back to test type selection from \(String(describing: questionObj.questionType))")
            }
            
            // Clear all data when exiting the flow completely (back to home)
            if let navControllers = navigationController?.viewControllers,
               navControllers.last is HomeViewController {
                questionnaireManager.clearAllKetoneData()
                questionnaireManager.resetReminderPageVisitCount()
                questionnaireManager.resetKetoneVisitCount()
                questionnaireManager.clearFirstKetoneValues()
                print("   🏠 Returning to home - all data cleared")
            }
            
            questionnaireManager.printCurrentKetoneState()
        }
    }

    
    private func hideAllViews() {
        yesOrNoQueView.isHidden = true
        finalStepView.isHidden = true
		finalStepNoDescView.isHidden = true
		finalStepWithDescView.isHidden = true
		finalStepCallChoaView.isHidden = true
		finalStepCallChoaEmergencyView.isHidden = true
		finalStepWithReminderView.isHidden = true
        twoOptionsView.isHidden = true
        openEndedQueView.isHidden = true
        multipleOptionsView.isHidden = true
        fourOptionsView.isHidden = true
		fiveOptionsView.isHidden = true
		firstEmergencyView.isHidden = true
    }

    private func setupViews() {
        switch questionObj.questionType {
        case .yesOrNo:
            yesOrNoQueView.isHidden = false
            yesOrNoQueView.delegate = self
            yesOrNoQueView.setupView(currentQuestion: questionObj)
        case .twoOptions:
			questionnaireManager.saveYesOver2hours(false)
            twoOptionsView.isHidden = false
            twoOptionsView.delegate = self
            twoOptionsView.setupView(currentQuestion: questionObj)
		case .fourOptions:
			fourOptionsView.isHidden = false
			fourOptionsView.delegate = self
			fourOptionsView.setupView(currentQuestion: questionObj)
		case .fiveOptions:
			fiveOptionsView.isHidden = false
			fiveOptionsView.delegate = self
			fiveOptionsView.setupView(currentQuestion: questionObj)
        case .multipleOptions: break
        case .multipleOptionsDescriptionAtBottom:
            multipleOptionsView.isHidden = false
            multipleOptionsView.delegate = self
            multipleOptionsView.setupView(currentQuestion: questionObj)
        case .openEndedWithMultipleInput:
            openEndedQueView.isHidden = false
            openEndedQueView.delegate = self
            openEndedQueView.setupView(currentQuestion: questionObj, multiple: true)
        case .finalStep:
            navigationItem.rightBarButtonItem = nil

            finalStepView.isHidden = false
            finalStepView.delegate = self
            finalStepView.setupView(currentQuestion: questionObj)
			updateBackgroundColorForFinalStep(questionId: questionObj.questionId)
		case .finalStepNoDesc:
            navigationItem.rightBarButtonItem = nil

			finalStepNoDescView.isHidden = false
			finalStepNoDescView.delegate = self
			finalStepNoDescView.setupView(currentQuestion: questionObj)
			updateBackgroundColorForFinalStep(questionId: questionObj.questionId)
		case .finalStepWithDesc:
            navigationItem.rightBarButtonItem = nil

			finalStepWithDescView.isHidden = false
			finalStepWithDescView.delegate = self
			finalStepWithDescView.setupView(currentQuestion: questionObj)
			updateBackgroundColorForFinalStep(questionId: questionObj.questionId)
		case .firstEmergency:
            navigationItem.rightBarButtonItem = nil

			firstEmergencyView.isHidden = false
			firstEmergencyView.delegate = self
			firstEmergencyView.setupView(currentQuestion: questionObj)
			updateBackgroundColorForFinalStep(questionId: questionObj.questionId)
		case .callChoa:
            navigationItem.rightBarButtonItem = nil

			finalStepCallChoaView.isHidden = false
			finalStepCallChoaView.delegate = self
			finalStepCallChoaView.setupView(currentQuestion: questionObj)
			updateBackgroundColorForFinalStep(questionId: questionObj.questionId)
		case .callChoaEmergency:
            navigationItem.rightBarButtonItem = nil

			finalStepCallChoaEmergencyView.isHidden = false
			finalStepCallChoaEmergencyView.delegate = self
			finalStepCallChoaEmergencyView.setupView(currentQuestion: questionObj)
			updateBackgroundColorForFinalStep(questionId: questionObj.questionId)
		case .reminder:
			finalStepWithReminderView.isHidden = false
			finalStepWithReminderView.delegate = self
			finalStepWithReminderView.viewController = self
			finalStepWithReminderView.setupView(currentQuestion: questionObj)
			updateBackgroundColorForFinalStep(questionId: questionObj.questionId)
		case .recheckKetoneLevel:
			questionnaireManager.saveYesOver2hours(true)
			recheckKetoneLevelView.isHidden = false
			recheckKetoneLevelView.delegate = self
			recheckKetoneLevelView.setupView(currentQuestion: questionObj)
        case .none:
			break
        }
    }

	private func updateBackgroundColorForFinalStep(questionId: Int) {
		let backgroundColor: UIColor

		switch questionId {
		case FinalQuestionId.firstEmergencyScreen.id:
			backgroundColor = .veryLightRed
		case FinalQuestionId.endo.id:
			backgroundColor = .white
		case FinalQuestionId.continueRegularCare.id:
			backgroundColor = .veryLightGreen
		case FinalQuestionId.callChoaEmergency.id:
			backgroundColor = .lightBackgroundColor
		default:
			backgroundColor = .white
		}

		view.backgroundColor = backgroundColor

		let appearance = UINavigationBarAppearance()
		appearance.configureWithOpaqueBackground()
		appearance.backgroundColor = backgroundColor
		appearance.shadowColor = .clear

		appearance.buttonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.black]
		appearance.backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.black]

		navigationController?.navigationBar.standardAppearance = appearance
		navigationController?.navigationBar.scrollEdgeAppearance = appearance
		navigationController?.navigationBar.tintColor = UIColor.black
	}

	private func resetBackgroundColor() {
		let appearance = UINavigationBarAppearance()
		appearance.configureWithOpaqueBackground()
		appearance.backgroundColor = .white
		appearance.shadowColor = .clear

		appearance.buttonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.black]
		appearance.backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.black]

		navigationController?.navigationBar.standardAppearance = appearance
		navigationController?.navigationBar.scrollEdgeAppearance = appearance
		navigationController?.navigationBar.tintColor = UIColor.black
		view.backgroundColor = .white
	}

    @objc func closeTapped(_ sender: Any){
        self.navigationController?.popToRootViewController(animated: true)
    }
}

extension GetHelpViewController: YesOrNoQueViewProtocol, TwoOptionsViewProtocol, FourOptionsViewProtocol, FiveOptionsViewProtocol, OpenEndedQueViewProtocol, MultipleOptionsViewProtocol {

    func didSelectNextAction(currentQuestion: Questionnaire, selectedAnswer: TwoOptionsAnswer, followUpAnswer: TwoOptionsAnswer?) {
        switch selectedAnswer {
        case .TestType(let testType):
            self.questionnaireManager.saveTestType(testType)

			print("TestType: \(testType)")

			if let followUp = followUpAnswer,
			   case .CalculationType(let calculationType) = followUp {
				self.questionnaireManager.saveCalculationType(calculationType)
			}

            self.questionnaireManager.triggerTestActionFlow(currentQuestion)
		default:
			return
        }
        
    }

		// For checking if they use iLet Pump
	func didSelectNextAction(currentQuestion: Questionnaire, selectedAnswer: TwoOptionsAnswer, followUpAnswer: YesOrNo?) {
		switch selectedAnswer {
		case .TestType(let testType):
			self.questionnaireManager.saveTestType(testType)

			print("TestType: \(testType)")

			if followUpAnswer == .yes {
				self.questionnaireManager.saveILetPump(true)
				print("Uses iLetPump")
			} else {
				self.questionnaireManager.saveILetPump(false)
				print("Does not use iLetPump")
				print(self.questionnaireManager.iLetPump)
			}

			self.questionnaireManager.triggerTestActionFlow(currentQuestion)
		
		default:
			return
		}
	}

		// For checking if blood sugar is over 300 for 3 hours or 90 minutes (for iLet Pump)
    func didSelectNextAction(currentQuestion: Questionnaire, selectedAnswer: YesOrNo, followUpAnswer: YesOrNo?) {
        
        switch selectedAnswer {
        case .yes:
            self.questionnaireManager.saveBloodSugarOver300(true)
            if let followUp = followUpAnswer {
                switch followUp {
                case .yes:
                    self.questionnaireManager.saveBloodSugarOver300For3Hours(true)
                    print("Saved: over 300 for 3 hours = TRUE")
                case .no:
                    self.questionnaireManager.saveBloodSugarOver300For3Hours(false)
                    print("Saved: over 300 for 3 hours = FALSE")
                }
            } else {
                print("🔍 WARNING: followUpAnswer is nil!")
            }
            self.questionnaireManager.triggerYesActionFlow(currentQuestion)
        case .no:
            self.questionnaireManager.saveBloodSugarOver300(false)
            self.questionnaireManager.saveBloodSugarOver300For3Hours(false)
            print("🔍 Saved: both FALSE")
            self.questionnaireManager.triggerNoActionFlow(currentQuestion)

        }
    }

	func didSelectNextAction(currentQuestion: Questionnaire, selectedAnswer: SixOptionsAnswer, followUpAnswer: SixOptionsAnswer?) {

		switch selectedAnswer {
		case .UrineKetoneLevel(let level):
			self.questionnaireManager.saveUrineKetoneLevel(level: level)
            self.questionnaireManager.iLetPump ?
            self.questionnaireManager.triggerUrineKetoneForILetActionFlow(currentQuestion, level: level) : self.questionnaireManager.triggerUrineKetoneLevelActionFlow(currentQuestion, level: level)
		}
	}

	func didSelectNextAction(currentQuestion: Questionnaire, selectedAnswer: ThreeOptionsAnswer, followUpAnswer: ThreeOptionsAnswer?) {

		switch selectedAnswer {
		case .BloodKetoneLevel(let level):
			self.questionnaireManager.saveBloodKetoneLevel(level: level)
            self.questionnaireManager.iLetPump ?
                self.questionnaireManager.triggerBloodKetoneForILetActionFlow(currentQuestion, level: level) :
                self.questionnaireManager.triggerBloodKetoneLevelActionFlow(currentQuestion, level: level)
		}
	}

	func didSelectNextAction(currentQuestion: Questionnaire, selectedAnswer: FourOptionsAnswer) {
		switch selectedAnswer {
		case .DKAIssue(let childIssue):
			self.questionnaireManager.triggerDKAWorkFlow(currentQuestion, childIssue: childIssue)

			print("Four options selected answer: \(selectedAnswer)")
		case .HighBloodSugar(let childIssue):
			print("Four options selected answer: \(selectedAnswer)")
			self.questionnaireManager.triggerDKAWorkFlow(currentQuestion, childIssue: childIssue)
		case .LowBloodSugar(let childIssue):
			print("Four options selected answer: \(selectedAnswer)")
            self.questionnaireManager.triggerCallChoaEmergencyActionFlow(currentQuestion)
        case .NotSure(let childIssue):
            self.questionnaireManager.triggerCallChoaEmergencyActionFlow(currentQuestion)
			print("Four options selected answer: \(selectedAnswer)")

		case .Nausea(_):
			print("Four options selected answer: \(selectedAnswer)")
			self.questionnaireManager.triggerKetoneMeasuringTypeActionFlow(currentQuestion)
		case .AbdominalPain(_):
			print("Four options selected answer: \(selectedAnswer)")
			self.questionnaireManager.triggerKetoneMeasuringTypeActionFlow(currentQuestion)
		case .RepeatedVomiting(_):
			print("Four options selected answer: \(selectedAnswer)")
			self.questionnaireManager.triggerKetoneMeasuringTypeActionFlow(currentQuestion)
		case .NoneOfTheAbove(_):
			print("Four options selected answer: \(selectedAnswer)")
			self.questionnaireManager.triggerContinueActionFlow(currentQuestion)
		}

	}

	func didSelectNextAction(currentQuestion: Questionnaire, selectedAnswer: FiveOptionsAnswer) {

		switch selectedAnswer {
		case .noneOfTheAbove(let childSymptom):
			self.questionnaireManager
				.triggerNoSymptomsActionFlow(
					currentQuestion,
					childSymptom: childSymptom
				)
			print("Five options selected answer: \(selectedAnswer)")
		case .troubleBreathing(_):
			self.questionnaireManager
				.triggerFirstEmergencyActionFlow(currentQuestion)
			print("Five options selected answer: \(selectedAnswer)")
		case .confused(_):
			print("Five options selected answer: \(selectedAnswer)")
			self.questionnaireManager
				.triggerFirstEmergencyActionFlow(currentQuestion)
		case .veryTired(_):
			print("Five options selected answer: \(selectedAnswer)")
			self.questionnaireManager.triggerFirstEmergencyActionFlow(currentQuestion)
		case .repeatedVomiting(_):
			print("Five options selected answer: \(selectedAnswer)")
			self.questionnaireManager.triggerFirstEmergencyActionFlow(currentQuestion)
		}

	}

    
    func didSelectNextAction(currentQuestion: Questionnaire, selectedAnswer: MultipleOptionsAnswer) {
        
        switch selectedAnswer {
        case .KetonesMeasurements(let ketonesType):
            switch ketonesType {
            case .zeroToSmall:
                self.questionnaireManager.saveKetones(type: ketonesType)
                self.questionnaireManager.triggerResultsActionFlow(currentQuestion)
                
            case .moderateToLarge:
                self.questionnaireManager.saveKetones(type: ketonesType)
                self.questionnaireManager.triggerResultsActionFlow(currentQuestion)
            case .unknown:
                self.questionnaireManager.triggerNoKetonesActionFlow(currentQuestion)
            }
            
        
        }

    }
    
    func didSelectNextAction(currentQuestion: Questionnaire, userSelectedType: YesOrNo) {
        if userSelectedType == .yes {
            self.questionnaireManager.triggerYesActionFlow(currentQuestion)
        } else {
            self.questionnaireManager.triggerNoActionFlow(currentQuestion)
        }
    }

	func didSelectLearnHowAction() {
		let storyboard = UIStoryboard(name: "GetHelp", bundle: nil)
		if let aboutVC = storyboard.instantiateViewController(withIdentifier: "AboutKetoneMeasurementsViewController") as? AboutKetoneMeasurementsViewController {
			aboutVC.modalPresentationStyle = .pageSheet
			present(aboutVC, animated: true)
		}
	}
    
    func didSelectNextAction(currentQuestion: Questionnaire, bloodSugar: Int, cf: Int) {
        self.questionnaireManager.saveData(bloodSugar: bloodSugar, correctionFactor: cf)
        self.questionnaireManager.triggerKetonesActionFlow(currentQuestion)
    }

	@objc func didSelectExitAction() {
        print("🚪 Exit button pressed - clearing all state")
        
        // Clear all persisted state
        questionnaireManager.clearAllKetoneData()
        questionnaireManager.resetReminderPageVisitCount()
        questionnaireManager.resetKetoneVisitCount()
        
        // Reset the instance
        QuestionnaireManager.resetInstance()
        
        questionnaireManager.printCurrentKetoneState()
        
        self.navVC.popToRootViewController(animated: true)
	}
    
    func logNavigationState() {
        guard let navControllers = navigationController?.viewControllers else { return }
        
        print("""
        🗺️ Navigation Stack:
        """)
        
        for (index, vc) in navControllers.enumerated() {
            if let getHelpVC = vc as? GetHelpViewController {
                print("   [\(index)] GetHelpVC: \(getHelpVC.questionObj.questionType)")
            } else {
                print("   [\(index)] \(type(of: vc))")
            }
        }
    }

}

extension GetHelpViewController: FinalStepViewProtocol, FinalStepNoDescViewProtocol, FinalStepWithDescViewProtocol, FirstEmergencyViewProtocol, FinalStepWithReminderViewProtocol, FinalStepCallChoaViewProtocol, FinalStepCallChoaEmergencyViewProtocol, RecheckKetoneLevelViewProtocol {
    
    func didSelectGotItAction(_ question: Questionnaire) {
        ReminderPersistence.clearReminderState()
        
        for controller in self.navVC.viewControllers as Array {
            if controller.isKind(of: HomeViewController.self) {
                self.navVC.popToViewController(controller, animated: true)
                break
            }
        }
    }
    
    private func performIf(_ condition: Bool, message: String, action: () -> Void) -> Bool {
        if condition {
            print("   → \(message)")
            action()
            return true
        }
        return false
    }
    
    func didSelectYesOverAction(_ question: Questionnaire) {
        let q = questionnaireManager
        let iLetPump = q.iLetPump
        let reminderPageVisitCount = q.getReminderPageVisitCount()
        let ketoneCheckPageVisitCount = q.getKetoneVisitCount()
        let skippedFirst = q.skipFirstReminder
        
        let hasModerateUrine = [.zeroPointFive, .onePointFive, .four].contains(q.urineKetones)
        let hasModerateBlood = q.bloodKetones == .moderate
        let hasHighUrine = [.eight, .sixteen].contains(q.urineKetones)
        let hasHighBlood = q.bloodKetones == .large
        
        guard iLetPump else {
            print("   → Non-iLet flow: Recheck ketones")
            q.triggerRecheckKetonesActionFlow(question)
            return
        }
        
        print("""
        🧩 DEBUG (iLetPump flow)
        skippedFirst = \(skippedFirst)
        reminderPageVisitCount = \(reminderPageVisitCount)
        urineKetones = \(String(describing: q.urineKetones))
        bloodKetones = \(String(describing: q.bloodKetones))
        """)
        
        let matched =
        performIf(skippedFirst && reminderPageVisitCount >= 2 && (hasHighUrine || hasHighBlood),
                  message: "Condition 1 matched: High ketones + skipped first + visit ≥ 2 → Blood sugar recheck") {
            q.triggerBloodSugarRecheckActionFlow(question)
        } ||
        performIf(skippedFirst && reminderPageVisitCount == 1 && (hasHighUrine || hasHighBlood),
                  message: "Condition 2 matched: High ketones + skipped first + visit = 1 → Blood sugar recheck") {
            q.triggerBloodSugarRecheckActionFlow(question)
        } ||
        performIf(skippedFirst && reminderPageVisitCount >= 2 && (hasModerateUrine || hasModerateBlood),
                  message: "Condition 3 matched: Moderate ketones + skipped first + visit ≥ 2 → Blood sugar recheck") {
            q.triggerBloodSugarRecheckActionFlow(question)
        } ||
        performIf(skippedFirst && reminderPageVisitCount == 1 && (hasModerateUrine || hasModerateBlood),
                  message: "Condition 4 matched: Moderate ketones + skipped first + visit = 1 → Recheck ketones") {
            q.triggerRecheckKetonesActionFlow(question)
        } ||
        performIf(!skippedFirst && reminderPageVisitCount > 2 && (hasHighUrine || hasHighBlood || hasModerateUrine || hasModerateBlood),
                  message: "Condition 5 matched: Any ketones + did not skip + visit > 2 → Blood sugar recheck") {
            q.triggerBloodSugarRecheckActionFlow(question)
        } ||
        performIf(
            !skippedFirst && (reminderPageVisitCount == 1 || reminderPageVisitCount == 2) && (
                ketoneCheckPageVisitCount == 1 || ketoneCheckPageVisitCount == 2),
                  message: "Condition 6 matched: Did not skip + reminder visit 1 or 2 + ketoneCheck visit 1 or 2 → Recheck ketones") {
            q.triggerRecheckKetonesActionFlow(question)
        }

        if !matched {
            print("⚠️ WARNING: No condition matched! Using fallback.")
            q.triggerRecheckKetonesActionFlow(question)
        }
    }

		// Recheck Ketone Level Functions
	func didSelectNextAction(currentQuestion: Questionnaire, selectedAnswer: SixOptionsAnswer) {

		print("Selected Answer: \(selectedAnswer)")
        let iLetPump = self.questionnaireManager.iLetPump
        let reminderPageVisitCount = self.questionnaireManager
                .getReminderPageVisitCount()
        let skippedFirst = self.questionnaireManager.skipFirstReminder
        
        let hasModerateUrineKetones = self.questionnaireManager.urineKetones == .zeroPointFive || self.questionnaireManager.urineKetones == .onePointFive || self.questionnaireManager.urineKetones == .four
        
        let hasModerateBloodKetones = self.questionnaireManager.bloodKetones == .moderate
        
        let hasHighUrineKetones = self.questionnaireManager.urineKetones == .eight || self.questionnaireManager.urineKetones == .sixteen
        
        let hasHighBloodKetones = self.questionnaireManager.bloodKetones == .large

		switch selectedAnswer {
            
		case .UrineKetoneLevel(let level):
			self.questionnaireManager.saveUrineKetoneLevel(level: level)
            
            if iLetPump {
                self.questionnaireManager.triggerRecheckUrineKetoneForILetActionFlow(currentQuestion, urineLevel: level)
            } else {
                self.questionnaireManager.triggerRecheckUrineKetoneActionFlow(currentQuestion, urineLevel: level)
            }
		}
	}

	func didSelectNextAction(currentQuestion: Questionnaire, selectedAnswer: ThreeOptionsAnswer) {
        
        let iLetPump = self.questionnaireManager.iLetPump
        let reminderPageVisitCount = self.questionnaireManager
                .getReminderPageVisitCount()
        let skippedFirst = self.questionnaireManager.skipFirstReminder
        
        let hasModerateUrineKetones = self.questionnaireManager.urineKetones == .zeroPointFive || self.questionnaireManager.urineKetones == .onePointFive || self.questionnaireManager.urineKetones == .four
        
        let hasModerateBloodKetones = self.questionnaireManager.bloodKetones == .moderate
        
        let hasHighUrineKetones = self.questionnaireManager.urineKetones == .eight || self.questionnaireManager.urineKetones == .sixteen
        
        let hasHighBloodKetones = self.questionnaireManager.bloodKetones == .large

		print("Selected Answer: \(selectedAnswer)")

		switch selectedAnswer {
		case .BloodKetoneLevel(let level):
			self.questionnaireManager.saveBloodKetoneLevel(level: level)
            
            if iLetPump {
                self.questionnaireManager.triggerRecheckBloodKetoneForILetActionFlow(currentQuestion, bloodLevel: level)
            } else {
                self.questionnaireManager
                    .triggerRecheckBloodKetoneActionFlow(currentQuestion, bloodLevel: level)
            }
		}
	}
}


extension GetHelpViewController: QuestionnaireActionsProtocol {
    func showNextQuestion(_ question: Questionnaire) {
        let getHelpViewController = UIStoryboard(name: "GetHelp", bundle: nil).instantiateViewController(identifier: String(describing: GetHelpViewController.self)) { [weak self] creator in
            GetHelpViewController(navVC: self?.navigationController ?? self!.navVC, currentQuestion: question, coder: creator)
        }

        self.navVC.pushViewController(getHelpViewController, animated: true)
    }
}
