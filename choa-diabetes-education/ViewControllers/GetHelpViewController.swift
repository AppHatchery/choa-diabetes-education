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
    @IBOutlet var threeOptionQueView: ThreeOptionQueView!
    @IBOutlet weak var openEndedQueView: OpenEndedQueView!
    @IBOutlet weak var multipleOptionsView: MultipleOptionsView!
    @IBOutlet weak var fourOptionsView: FourOptionsView!
	@IBOutlet weak var fiveOptionsView: FiveOptionsView!
	@IBOutlet var firstEmergencyView: FirstEmergencyView!
	@IBOutlet var finalStepCallChoaView: FinalStepCallChoaView!
	@IBOutlet var finalStepCallChoaEmergencyView: FinalStepCallChoaEmergencyView!
	@IBOutlet var finalStepWithReminderView: FinalStepWithReminderView!
	@IBOutlet var recheckKetoneLevelView: RecheckKetoneLevelView!
    @IBOutlet var performFingerStickBloodTest: PerformFingerStickTestView!
    @IBOutlet var lowBloodSugarSymptomsView: LowBloodSugarSymptomsView!


	let questionObj: Questionnaire
    private let questionnaireManager: QuestionnaireManager = QuestionnaireManager.instance
    
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

    /// This screen's navigation bar colours. The bar is shared by every screen on the stack,
    /// so they're applied again whenever this screen appears, including when it's popped back to.
    private var navigationBarColors: (background: UIColor, tint: UIColor) = (.white, .black)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationItem.backButtonDisplayMode = .minimal
        applyNavigationBarColors()

        // The manager only holds a weak reference to one delegate, so whichever screen is
        // showing takes it over, including a screen uncovered by popping back to it
        questionnaireManager.actionsDelegate = self

        questionnaireManager.printCurrentKetoneState()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if isMovingToParent {
            // Raise the keyboard once the push finishes so it doesn't animate in mid-transition
            if !openEndedQueView.isHidden {
                openEndedQueView.focusBloodSugarField()
            }
        }

        // Visit counts are derived from the questions on the stack, so recount whenever a screen
        // appears: after a push, after popping back, and after a cancelled swipe back
        questionnaireManager.updateVisitCounts(for: questionPath)
        questionnaireManager.printCurrentKetoneState()
    }

    /// The questions on the navigation stack, oldest first
    private var questionPath: [Questionnaire] {
        (navigationController ?? navVC).viewControllers.compactMap { ($0 as? GetHelpViewController)?.questionObj }
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

		hideAllViews()
		setupViews()
	}
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)

        if isMovingFromParent {
            finalStepWithReminderView?.cleanup()
            
            print("⬅️ Popping from: \(String(describing: questionObj.questionType))")
            
            guard let previousVC = navigationController?.viewControllers.last as? GetHelpViewController else {
                resetBackgroundColor()
                return
            }

            // Restore the uncovered screen's bar colours rather than resetting them to white
            previousVC.applyNavigationBarColors()
            
            print("   → Going back to: \(String(describing: previousVC.questionObj.questionType))")
            
            // Visit counts need no bookkeeping here: the uncovered screen recounts them when it appears
            if shouldResetKetoneProgress(poppingTo: previousVC.questionObj.questionType) {
                questionnaireManager.resetKetoneProgress()
                print("   🗑️ Ketone progress reset: popping from \(String(describing: questionObj.questionType)) to \(String(describing: previousVC.questionObj.questionType))")
            }
            
            questionnaireManager.printCurrentKetoneState()
        }
    }

    
    /// Backing out to the point where ketones are first measured (or before it) starts
    /// the ketone check over.
    private func shouldResetKetoneProgress(poppingTo previousType: QuestionType?) -> Bool {
        let currentType: QuestionType? = questionObj.questionType
        let isPoppingFromReminder = currentType == .reminder(FinalQuestionId(id: questionObj.questionId))
        let isPoppingFromRecheck = currentType == .recheckKetoneLevel(FinalQuestionId(id: questionObj.questionId)) ||
            currentType?.isBloodSugarRecheck == true

        var isPoppingToTwoOptions = false
        if case .twoOptions = previousType {
            isPoppingToTwoOptions = true
        }

        return (isPoppingFromReminder && isPoppingToTwoOptions) ||
            (isPoppingFromRecheck && previousType == .twoOptions(.measuringType)) ||
            (previousType == .twoOptions(.testType) && currentType != .twoOptions(.testType))
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
        threeOptionQueView.isHidden = true
        openEndedQueView.isHidden = true
        multipleOptionsView.isHidden = true
        fourOptionsView.isHidden = true
		fiveOptionsView.isHidden = true
		firstEmergencyView.isHidden = true
		performFingerStickBloodTest.isHidden = true
		lowBloodSugarSymptomsView.isHidden = true
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
        case .threeOptions:
            threeOptionQueView.isHidden = false
            threeOptionQueView.delegate = self
            threeOptionQueView.setupView(currentQuestion: questionObj)
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
		case .performFingerStickTest, .giveGlucagon:
			performFingerStickBloodTest.isHidden = false
			performFingerStickBloodTest.delegate = self
			performFingerStickBloodTest.setupView(currentQuestion: questionObj)
			updateBackgroundColorForFinalStep(questionId: questionObj.questionId)
		case .lowBloodSugarSymptoms:
			lowBloodSugarSymptomsView.isHidden = false
			lowBloodSugarSymptomsView.delegate = self
			lowBloodSugarSymptomsView.setupView(currentQuestion: questionObj)
        case .none:
			break
        }
    }

	private func updateBackgroundColorForFinalStep(questionId: Int) {
		let backgroundColor: UIColor
		let tintColor: UIColor

		switch questionId {
		case FinalQuestionId.firstEmergencyScreen.id:
			backgroundColor = .secondaryRedColor
			tintColor = .white
		case FinalQuestionId.endo.id:
			backgroundColor = .white
			tintColor = .black
		case FinalQuestionId.continueRegularCare.id, FinalQuestionId.continueDMMP.id:
			backgroundColor = .secondaryMeadowGreen300
			tintColor = .white
		case FinalQuestionId.callChoaEmergency.id, FinalQuestionId.performFingerStickTest.id,
			FinalQuestionId.giveGlucagon.id, FinalQuestionId.callCareTeam.id:
			backgroundColor = .sunsetOrangeColor300
			tintColor = .white
		default:
			backgroundColor = .white
			tintColor = .black
		}

		view.backgroundColor = backgroundColor
		navigationBarColors = (backgroundColor, tintColor)
		applyNavigationBarColors()
	}

	private func applyNavigationBarColors() {
		let (backgroundColor, tintColor) = navigationBarColors

		let appearance = UINavigationBarAppearance()
		appearance.configureWithOpaqueBackground()
		appearance.backgroundColor = backgroundColor
		appearance.shadowColor = .clear

		appearance.buttonAppearance.normal.titleTextAttributes = [.foregroundColor: tintColor]
		appearance.backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: tintColor]

		navigationController?.navigationBar.standardAppearance = appearance
		navigationController?.navigationBar.scrollEdgeAppearance = appearance
		navigationController?.navigationBar.tintColor = tintColor
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

		// For checking how blood sugar was checked in the hypoglycemia flow
	func didSelectNextAction(currentQuestion: Questionnaire, selectedAnswer: TwoOptionsAnswer) {
		switch selectedAnswer {
		case .BloodSugarCheckMethod(let method):
			print("Blood sugar check method: \(method)")
			self.questionnaireManager.triggerBloodSugarCheckMethodActionFlow(currentQuestion, method: method)
		case .LowBloodSugarTestType(let testType, let pumpShowsCGM):
			self.questionnaireManager.triggerLowBloodSugarTestTypeActionFlow(currentQuestion, testType: testType, pumpShowsCGM: pumpShowsCGM)
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
		case .LowBloodSugar:
			print("Four options selected answer: \(selectedAnswer)")
            self.questionnaireManager.triggerCallChoaEmergencyActionFlow(currentQuestion)
            // TODO: Will be enabled in the next version after Halloween
            // self.questionnaireManager.triggerHypoglycemiaFlow(currentQuestion)
        case .NotSure:
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

		// For the blood sugar reading question. The duration is only provided when the reading is 300 or higher.
	func didSelectNextAction(currentQuestion: Questionnaire, bloodSugar: Int, durationOver300: HighBloodSugarDuration?) {
		// iLet Pump users escalate after 90 minutes above 300, everyone else after 3 hours
		let thresholdMinutes = questionnaireManager.iLetPump ? 90 : 180

		if let duration = durationOver300 {
			questionnaireManager.saveBloodSugarOver300(true)
			questionnaireManager.saveBloodSugarOver300For3Hours(duration.minutes >= thresholdMinutes)
		} else {
			questionnaireManager.saveBloodSugarOver300(false)
			questionnaireManager.saveBloodSugarOver300For3Hours(false)
		}

		print("Blood sugar: \(bloodSugar), duration over 300: \(String(describing: durationOver300)), over threshold: \(questionnaireManager.bloodSugarOver300For3Hours)")
		questionnaireManager.triggerBloodSugarReadingActionFlow(currentQuestion)
	}

		// For the hypoglycemia reading, and the blood sugar recheck reading (compared against the 150/180 mg/dL threshold).
	func didSelectNextAction(currentQuestion: Questionnaire, bloodSugar: Int) {
		if currentQuestion.questionType == .openEndedWithMultipleInput(.lowBloodSugarCheck) {
			questionnaireManager.triggerLowBloodSugarReadingResultActionFlow(currentQuestion, bloodSugar: bloodSugar)
			return
		}

		questionnaireManager.triggerBloodSugarRecheckReadingActionFlow(currentQuestion, bloodSugar: bloodSugar)
	}

	func didEnterLowBloodSugar(currentQuestion: Questionnaire, bloodSugar: Int) {
		let alert = AlertPopUpViewController(
			title: String(format: "Calculator.LowBloodSugarAlert.title".localized(), AppOnboardingManager.shared.lowBloodSugarThreshold),
			message: "Calculator.LowBloodSugarAlert.message".localized(),
			primaryActionTitle: "Calculator.LowBloodSugarAlert.primaryAction".localized(),
			secondaryActionTitle: "Calculator.LowBloodSugarAlert.secondaryAction".localized()
		)
		alert.onPrimaryAction = { [weak self] in
			self?.popToChildIssueQuestion()
		}
		alert.onSecondaryAction = { [weak self] in
			guard let self else { return }

			// On recheck, keep the first reading's flags and continue down the below-threshold path
			if currentQuestion.questionType == .openEndedWithMultipleInput(.bloodSugarRecheck) {
				self.questionnaireManager.triggerBloodSugarRecheckReadingActionFlow(currentQuestion, bloodSugar: bloodSugar)
				return
			}

			// A low reading can't have been over 300, so clear those flags before moving on
			self.questionnaireManager.saveBloodSugarOver300(false)
			self.questionnaireManager.saveBloodSugarOver300For3Hours(false)
			self.questionnaireManager.triggerKetoneMeasuringTypeActionFlow(currentQuestion)
		}
		alert.appear(sender: self)
	}

		// Returns to the "What's going on with your child?" question so a different symptom can be picked
	private func popToChildIssueQuestion() {
		let childIssueVC = navVC.viewControllers.last { controller in
			guard let getHelpVC = controller as? GetHelpViewController else { return false }
			return getHelpVC.questionObj.questionType == .fourOptions(.childIssue)
		}

		if let childIssueVC {
			navVC.popToViewController(childIssueVC, animated: true)
		} else {
			navVC.popViewController(animated: true)
		}
	}

	@objc func didSelectExitAction() {
        print("🚪 Exit button pressed - clearing all state")
        
        questionnaireManager.reset()
        
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

        // Low blood sugar: once the 15 minutes are up, check for vomiting or loss of consciousness and recheck the blood sugar
        if FinalQuestionId(id: question.questionId).isLowBloodSugarTreatment {
            print("   → Low blood sugar flow: Recheck")
            q.triggerLowBloodSugarRecheckActionFlow(question)
            return
        }

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
            q.triggerRecheckKetonesActionFlow(question)
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


extension GetHelpViewController: PerformFingerStickTestViewProtocol {
	func didSelectFingerStickNextAction(_ question: Questionnaire) {
		if case .giveGlucagon = question.questionType {
			questionnaireManager.triggerGiveGlucagonNextActionFlow(question)
		} else {
			questionnaireManager.triggerLowBloodSugarReadingActionFlow(question)
		}
	}
}

extension GetHelpViewController: ThreeOptionQueViewProtocol {
	func didSelectNextAction(currentQuestion: Questionnaire, selectedAnswer: LowBloodSugarRecheckAnswer) {
		print("Low blood sugar recheck: \(selectedAnswer)")
		questionnaireManager.triggerLowBloodSugarRecheckAnswerActionFlow(currentQuestion, answer: selectedAnswer)
	}
}

extension GetHelpViewController: LowBloodSugarSymptomsViewProtocol {
	func didSelectLowBloodSugarSymptoms(_ question: Questionnaire, hasSymptoms: Bool) {
		questionnaireManager.triggerLowBloodSugarSymptomsActionFlow(question, hasSymptoms: hasSymptoms)
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
