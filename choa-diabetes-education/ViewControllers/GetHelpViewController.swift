//
//  GetHelpViewController.swift
//  choa-diabetes-education
//

import UIKit

class GetHelpViewController: UIViewController {

    
    
    static let nibName = "GetHelp"

    @IBOutlet weak var yesOrNoQueView: YesOrNoQueView!
    @IBOutlet weak var finalStepView: FinalStepView!
    @IBOutlet weak var twoOptionsView: TwoOptionsView!
    @IBOutlet weak var openEndedQueView: OpenEndedQueView!
    @IBOutlet weak var multipleOptionsView: MultipleOptionsView!
    @IBOutlet weak var fourOptionsView: FourOptionsView!
	@IBOutlet weak var fiveOptionsView: FiveOptionsView!

    private let questionObj: Questionnaire
    private let questionnaireManager: QuestionnaireManagerProvider = QuestionnaireManager.instance
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

    override func viewDidLoad() {
        super.viewDidLoad()
		let appearance = UINavigationBarAppearance()
		appearance.configureWithOpaqueBackground()
		appearance.backgroundColor = UIColor.choaGreenColor

		appearance.titleTextAttributes = [
			.foregroundColor: UIColor.white,
			.font: UIFont.gothamRoundedBold16
		]
		appearance.largeTitleTextAttributes = [
			.foregroundColor: UIColor.white,
			.font: UIFont.gothamRoundedBold16
		]

			// ✅ Make back button (text + arrow) white
		let backButtonAppearance = UIBarButtonItemAppearance()
		backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
		appearance.backButtonAppearance = backButtonAppearance

			// Apply appearance
		navigationController?.navigationBar.standardAppearance = appearance
		navigationController?.navigationBar.scrollEdgeAppearance = appearance
		navigationController?.navigationBar.tintColor = UIColor.white // applies to the back icon


		self.hidesBottomBarWhenPushed = true
		navVC.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.gothamRoundedBold]

        self.questionnaireManager.actionsDelegate = self

        hideAllViews()
        setupViews()
        
    }
    
    private func hideAllViews() {
        yesOrNoQueView.isHidden = true
        finalStepView.isHidden = true
        twoOptionsView.isHidden = true
        openEndedQueView.isHidden = true
        multipleOptionsView.isHidden = true
        fourOptionsView.isHidden = true
		fiveOptionsView.isHidden = true
    }
    
    private func setupViews() {
        switch questionObj.questionType {
        case .yesOrNo:
            yesOrNoQueView.isHidden = false
            yesOrNoQueView.delegate = self
            yesOrNoQueView.setupView(currentQuestion: questionObj)
        case .twoOptions:
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
            finalStepView.isHidden = false
            finalStepView.delegate = self
            finalStepView.setupView(currentQuestion: questionObj)
            
        case .none: break
        }
    }
}

extension GetHelpViewController: YesOrNoQueViewProtocol, TwoOptionsViewProtocol, FourOptionsViewProtocol, FiveOptionsViewProtocol, OpenEndedQueViewProtocol, MultipleOptionsViewProtocol {

    func didSelectNextAction(currentQuestion: Questionnaire, selectedAnswer: TwoOptionsAnswer, followUpAnswer: TwoOptionsAnswer? ) {
        switch selectedAnswer {
        case .TestType(let testType):
            self.questionnaireManager.saveTestType(testType)

			if let followUp = followUpAnswer,
			   case .CalculationType(let calculationType) = followUp {
				self.questionnaireManager.saveCalculationType(calculationType)
			}

            self.questionnaireManager.triggerTestActionFlow(currentQuestion)
		default:
			return
        }
        
    }

	func didSelectNextAction(currentQuestion: Questionnaire, selectedAnswer: SixOptionsAnswer, followUpAnswer: SixOptionsAnswer?) {
		print("HERE IS FOLLOW UP ANSWER \(followUpAnswer)")
		print("Current Question: \(currentQuestion)")

		switch selectedAnswer {
		case .UrineKetoneLevel(let level):
			self.questionnaireManager.saveUrineKetoneLevel(level: level)
			self.questionnaireManager.showFinalPage(currentQuestion: currentQuestion)
		default:
			break
		}
	}

	func didSelectNextAction(currentQuestion: Questionnaire, selectedAnswer: FourOptionsAnswer) {
		switch selectedAnswer {
		case .DKAIssue(let childIssue):
			self.questionnaireManager.triggerDKAWorkFlow(currentQuestion, childIssue: childIssue)

			print("Four options selected answer: \(selectedAnswer)")
		case .HighBloodSugar(_):
			print("Four options selected answer: \(selectedAnswer)")
		case .LowBloodSugar(_):
			print("Four options selected answer: \(selectedAnswer)")
		case .NotSure(_):
			print("Four options selected answer: \(selectedAnswer)")
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
			print("Five options selected answer: \(selectedAnswer)")
		case .confused(_):
			print("Five options selected answer: \(selectedAnswer)")
		case .veryTired(_):
			print("Five options selected answer: \(selectedAnswer)")
		case .vomitedMoreThanOnce(_):
			print("Five options selected answer: \(selectedAnswer)")
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
    
    
    func didSelectNextAction(currentQuestion: Questionnaire, bloodSugar: Int, cf: Int) {
        self.questionnaireManager.saveData(bloodSugar: bloodSugar, correctionFactor: cf)
        self.questionnaireManager.triggerKetonesActionFlow(currentQuestion)
    }

	func didSelectExitAction() {
		self.navVC.popToRootViewController(animated: true)
	}

}

extension GetHelpViewController: FinalStepViewProtocol {
    
    func didSelectGotItAction(_ question: Questionnaire) {
        if question.questionId == FinalQuestionId.shot.id {
            self.questionnaireManager.triggerDisclaimerActionFlow(question)
            return
        }
        for controller in self.navVC.viewControllers as Array {
			if controller.isKind(of: HomeViewController.self) {
                self.navVC.popToViewController(controller, animated: true)
                break
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
