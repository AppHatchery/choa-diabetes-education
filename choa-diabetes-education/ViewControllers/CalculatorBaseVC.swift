//
//  CalculatorBaseVC.swift
//  choa-diabetes-education
//

import UIKit

class CalculatorBaseVC: UIViewController {
    
    static let nibName = "CalculatorBaseVC"
    
    @IBOutlet weak var yesOrNoQueView: YesOrNoQueView!
    @IBOutlet weak var finalStepView: FinalStepView!
    @IBOutlet weak var twoOptionsView: TwoOptionsView!
    @IBOutlet weak var openEndedQueView: OpenEndedQueView!
    @IBOutlet weak var multipleOptionsView: MultipleOptionsView!
    
    private let questionObj: Questionnaire
    private let questionnaireManager: QuestionnaireManagerProvider = QuestionnaireManager.instance
    private let navVC: UINavigationController
    
    init(navVC: UINavigationController, currentQuestion: Questionnaire) {
        self.questionObj = currentQuestion
        self.navVC = navVC
        super.init(nibName: CalculatorBaseVC.nibName, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navVC.navigationBar.tintColor = UIColor.choaGreenColor
        self.questionnaireManager.actionsDelegate = self
        hideAllViews()
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
        case .openEndedWithSingleInput: break
        case .openEndedWithMultipleInput:
            openEndedQueView.isHidden = false
            openEndedQueView.delegate = self
            openEndedQueView.setupView(currentQuestion: questionObj)
        case .finalStep:
            finalStepView.isHidden = false
            finalStepView.delegate = self
            finalStepView.setupView(currentQuestion: questionObj)
        case .none: break
        }
    }
    
    private func hideAllViews() {
        yesOrNoQueView.isHidden = true
        finalStepView.isHidden = true
        twoOptionsView.isHidden = true
        openEndedQueView.isHidden = true
        multipleOptionsView.isHidden = true
    }
}

extension CalculatorBaseVC: YesOrNoQueViewProtocol, TwoOptionsViewProtocol, OpenEndedQueViewProtocol, MultipleOptionsViewProtocol {
    func didSelectNextAction(currentQuestion: Questionnaire, userSelectedType: KetonesType) {
        if userSelectedType == .urineKetones {
            self.questionnaireManager.triggerUrineKetonesActionFlow(currentQuestion)
        } else if userSelectedType == .bloodKetones {
            self.questionnaireManager.triggerBloodKetonesActionFlow(currentQuestion)
        } else {
            self.questionnaireManager.triggerNoKetonesActionFlow(currentQuestion)
        }
    }
    
    func didSelectNextAction(currentQuestion: Questionnaire, userSelectedType: YesOrNo) {
        switch currentQuestion.questionId {
        case YesOrNoQuestionId.severeDistress.id:
            if userSelectedType == .yes {
                self.questionnaireManager.triggerYesActionFlow(currentQuestion)
            } else {
                self.questionnaireManager.triggerNoActionFlow(currentQuestion)
            }
        case YesOrNoQuestionId.ketonesInNext30Mins.id:
            if userSelectedType == .yes {
                // TODO
            } else {
                // TODO
            }
        default:
            break
        }
    }
    
    func didSelectNextAction(currentQuestion: Questionnaire, userSelectedType: TestType) {
        self.questionnaireManager.saveTestType(userSelectedType)
        self.questionnaireManager.confirmBloodSugarFlow()
    }
    
    func didSelectNextAction(currentQuestion: Questionnaire, bloodSugar: Int, cf: Int) {
        self.questionnaireManager.saveBloodSugarAndCF(bloodSugar, cf)
        self.questionnaireManager.confirmForKetones()
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
        let calculatorBaseVC = CalculatorBaseVC(navVC: self.navVC, currentQuestion: question)
        self.navVC.pushViewController(calculatorBaseVC, animated: true)
    }
}
