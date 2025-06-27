//
//  GetHelpViewController.swift
//  choa-diabetes-education
//

import UIKit

class GetHelpViewController: UITableViewController {

    
    
    static let nibName = "GetHelp"

    @IBOutlet weak var yesOrNoQueView: YesOrNoQueView!
    @IBOutlet weak var finalStepView: FinalStepView!
    @IBOutlet weak var twoOptionsView: TwoOptionsView!
    @IBOutlet weak var openEndedQueView: OpenEndedQueView!
    @IBOutlet weak var multipleOptionsView: MultipleOptionsView!
    @IBOutlet weak var fourOptionsView: FourOptionsView!
    
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
        self.navVC.navigationBar.tintColor = UIColor.choaGreenColor
        self.questionnaireManager.actionsDelegate = self
        let exitBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeTapped))
        
        self.navigationItem.rightBarButtonItem  = exitBarButtonItem
        
        self.tableView.sectionHeaderTopPadding = 0.0
        self.tableView.sectionHeaderHeight = 0.0
        self.tableView.estimatedSectionHeaderHeight = 0.0
        self.tableView.contentInsetAdjustmentBehavior = .never
        
 
        hideAllViews()
        setupViews()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()

        self.navigationController?.navigationBar.standardAppearance = appearance
        
    }
    
    
    private func hideAllViews() {
        yesOrNoQueView.isHidden = true
        finalStepView.isHidden = true
        twoOptionsView.isHidden = true
        openEndedQueView.isHidden = true
        multipleOptionsView.isHidden = true
        fourOptionsView.isHidden = true
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
    
    @objc func closeTapped(_ sender: Any){
        self.navigationController?.popToRootViewController(animated: true)
    }
}

extension GetHelpViewController: YesOrNoQueViewProtocol, TwoOptionsViewProtocol, OpenEndedQueViewProtocol, MultipleOptionsViewProtocol {
    
    func didSelectNextAction(currentQuestion: Questionnaire, selectedAnswer: TwoOptionsAnswer) {
        switch selectedAnswer {
        case .TestType(let testType):
            self.questionnaireManager.saveTestType(testType)
            self.questionnaireManager.triggerTestActionFlow(currentQuestion)
        case .CalculationType(let method):
            self.questionnaireManager.saveCalculationType(method)
            self.questionnaireManager.triggerBloodSugarCheckActionFlow(currentQuestion)
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
    
}

extension GetHelpViewController: FinalStepViewProtocol {
    
    func didSelectGotItAction(_ question: Questionnaire) {
        if question.questionId == FinalQuestionId.shot.id {
            self.questionnaireManager.triggerDisclaimerActionFlow(question)
            return
        }
        for controller in self.navVC.viewControllers as Array {
            if controller.isKind(of: CalculatorHomeViewController.self) {
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

//	func showNextQuestion(_ question: Questionnaire) {
//		let getHelpViewController = GetHelpViewController(navVC: self.navigationController ?? self.navVC, currentQuestion: question)
//		self.navVC.pushViewController(getHelpViewController, animated: true)
//	}
}
