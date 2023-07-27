//
//  CalculatorBaseVC.swift
//  choa-diabetes-education
//

import UIKit

class CalculatorBaseVC: UITableViewController {

    
    
    static let nibName = "CalculatorBaseVC"
    
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
        super.init(nibName: CalculatorBaseVC.nibName, bundle: nil)
    }
    
    init?(navVC: UINavigationController, currentQuestion: Questionnaire, coder: NSCoder) {
        self.questionObj = currentQuestion
        self.navVC = navVC
        super.init(coder: coder)
    }

    

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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
        case .openEndedWithSingleInput:
            openEndedQueView.isHidden = false
            openEndedQueView.delegate = self
            openEndedQueView.setupView(currentQuestion: questionObj, multiple: false)
        case .openEndedWithMultipleInput:
            openEndedQueView.isHidden = false
            openEndedQueView.delegate = self
            openEndedQueView.setupView(currentQuestion: questionObj, multiple: true)
        case .finalStep:
            finalStepView.isHidden = false
            finalStepView.delegate = self
            finalStepView.setupView(currentQuestion: questionObj)
        case .fourOptions:
            print("unhid the view")
            fourOptionsView.isHidden = false
            fourOptionsView.delegate = self
            fourOptionsView.setupView(currentQuestion: questionObj)
            
        case .none: break
        }
    }
    
    @objc func closeTapped(_ sender: Any){
        self.navigationController?.popToRootViewController(animated: true)
    }
}

extension CalculatorBaseVC: YesOrNoQueViewProtocol, TwoOptionsViewProtocol, OpenEndedQueViewProtocol, MultipleOptionsViewProtocol, FourOptionsViewProtocol {

    
    
    
    func didSelectNextAction(currentQuestion: Questionnaire, selectedAnswer: TwoOptionsAnswer) {
        switch selectedAnswer {
        case .TestType(let testType):
            self.questionnaireManager.saveTestType(testType)
            self.questionnaireManager.confirmBloodSugarFlow()
        case .LastType(let lastType):
            switch lastType {
            case .pump:
                self.questionnaireManager.triggerLastPumpFlow(currentQuestion)
            case .injection:
                self.questionnaireManager.triggerLastShotFlow(currentQuestion)
            }
        case .UrineKetonesMeasurements(let urineKetonesMeasurements):
            switch urineKetonesMeasurements {
            case .zeroToSmall:
                self.questionnaireManager.saveKetones(1.0)
                self.questionnaireManager.triggerKetonesResponseActionFlow(currentQuestion)
            case .moderateToLarge:
                self.questionnaireManager.saveKetones(1.5)
                self.questionnaireManager.triggerKetonesResponseActionFlow(currentQuestion)
            }
        case .PumpLastDose(let pumpLastDose):
            switch pumpLastDose {
            case .lessThan30:
                self.questionnaireManager.triggerLastDoseTimeResponseActionFlow(currentQuestion)
            case .halfHourToTwoHours:
                self.questionnaireManager.saveDose(0)
                self.questionnaireManager.insulin(false)
                self.questionnaireManager.triggerLastDoseValueResponseActionFlow(currentQuestion)
                
            }
        case .ShotLastDose(let shotLastDose):
            switch shotLastDose {
            case .lessThanHour:
                self.questionnaireManager.triggerLastDoseTimeResponseActionFlow(currentQuestion)
            case .oneToThreeHours:
                self.questionnaireManager.saveDose(0)
                self.questionnaireManager.insulin(false)
                self.questionnaireManager.triggerLastDoseValueResponseActionFlow(currentQuestion)
            }
        }
        
    }
    
    func didSelectNextAction(currentQuestion: Questionnaire, selectedAnswer: FourOptionsAnswer) {
        switch selectedAnswer {
        case .ScheduledTime(let scheduledTime):
            switch scheduledTime {
            case .yes:
                self.questionnaireManager.triggerEndingStage()
            case .fourHoursLate:
                self.questionnaireManager.triggerEndingStage()
            case .moreThanFourHours:
                self.questionnaireManager.triggerEndoNoDoseActionFlow()
            case .notGiven:
                self.questionnaireManager.triggerNotGivenFlow(currentQuestion)
            }
        }
    }
    
    
    func didSelectNextAction(currentQuestion: Questionnaire, selectedAnswer: MultipleOptionsAnswer) {
        
        switch selectedAnswer {
        case .KetonesType(let ketonesType):
            switch ketonesType {
            case .none:
                self.questionnaireManager.saveKetones(1.0)
                self.questionnaireManager.triggerKetonesResponseActionFlow(currentQuestion)
            case .urineKetones:
                self.questionnaireManager.triggerUrineKetonesActionFlow(currentQuestion)
            case .bloodKetones:
                self.questionnaireManager.triggerBloodKetonesActionFlow(currentQuestion)
            case .noAccess:
                self.questionnaireManager.triggerNoKetonesActionFlow(currentQuestion)
            }
            
        
        case .BloodKetonesMeasurements(let bloodKetonesMeasurements):
            switch bloodKetonesMeasurements {
            case .lessThanOne:
                self.questionnaireManager.saveKetones(1.0)
                self.questionnaireManager.triggerKetonesResponseActionFlow(currentQuestion)
            case .oneToThree:
                self.questionnaireManager.triggerKetonesResponseActionFlow(currentQuestion)
            case .greaterThanThree:
                self.questionnaireManager.saveKetones(1.5)
                self.questionnaireManager.triggerEmergencyActionFlow()
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
        self.questionnaireManager.saveBloodSugarAndCF(bloodSugar, cf)
        self.questionnaireManager.confirmForKetones()
    }
    
    func didSelectNextAction(currentQuestion: Questionnaire, lastDose: Int) {
        self.questionnaireManager.saveDose(lastDose)
        self.questionnaireManager.triggerLastDoseValueResponseActionFlow(currentQuestion)
    }
}

extension CalculatorBaseVC: FinalStepViewProtocol {
    func didSelectGotItAction() {
        for controller in self.navVC.viewControllers as Array {
            if controller.isKind(of: CalculatorHomeViewController.self) {
                self.navVC.popToViewController(controller, animated: true)
                break
            }
        }
    }
}


extension CalculatorBaseVC: QuestionnaireActionsProtocol {
    func showNextQuestion(_ question: Questionnaire) {
        let calculatorBaseVC = UIStoryboard(name: "Calculator", bundle: nil).instantiateViewController(identifier: String(describing: CalculatorBaseVC.self)) { [weak self] creator in
            CalculatorBaseVC(navVC: self?.navigationController ?? self!.navVC, currentQuestion: question, coder: creator)
        }

        self.navVC.pushViewController(calculatorBaseVC, animated: true)
    }
}
