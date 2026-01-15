//
//  CalculatorOnBoardingViewController.swift
//  choa-diabetes-education
//
//  Created by Maxwell Kapezi Jr on 27/10/2025.
//

import UIKit

class CalculatorOnBoardingViewController: UIViewController {
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var questionImage: UIImageView!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var questionTextField: UITextField!
    @IBOutlet weak var nextButton: PrimaryButton!
    
    private let progressView = UIProgressView(progressViewStyle: .bar)

    var insulinForHighBloodSugarBoolean = false
    var insulinForFoodBoolean = false
    
    // Current question state
    var currentQuestion: CalculatorOnboardingQuestion = .carbRatio
        
    // Store the collected values
    private var collectedValues: [CalculatorOnboardingQuestion: Int] = [:]
    
    private let constantsManager = CalculatorConstantsManager.shared
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        setupNavigationBar()
        updateProgressBar()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        setupTextField()
        setupUI()
        updateNextButtonState()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .diabetesBasicsColor050
        appearance.shadowColor = UIColor.clear
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
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
        
        setupProgressBarInNavigationBar()
    }
    
    private func setupProgressBarInNavigationBar() {
        let navBarWidth = UIScreen.main.bounds.width - 150
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: navBarWidth, height: 20))
        
        // Configure progress view
        progressView.frame = CGRect(x: 0, y: 5, width: navBarWidth, height: 20)
        progressView.progressTintColor = .progressBarColor
        progressView.trackTintColor = UIColor.lightGray.withAlphaComponent(0.3)
        progressView.layer.cornerRadius = 2
        progressView.clipsToBounds = true
        
        containerView.addSubview(progressView)
        navigationItem.titleView = containerView
    }
    
    private func updateProgressBar() {
        let totalQuestions: Float = 3.0
        let currentQuestionNumber: Float = Float(currentQuestion.rawValue + 1)
        let progress = currentQuestionNumber / totalQuestions
        
        // Animate progress update
        UIView.animate(withDuration: 0.3) {
            self.progressView.setProgress(progress, animated: true)
        }
    }
    
    private func setupTextField() {
            questionTextField.delegate = self
            questionTextField.keyboardType = .numberPad
            questionTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
            
            questionTextField.layer.cornerRadius = 8
            questionTextField.layer.borderWidth = 1
            questionTextField.layer.borderColor = UIColor.lightGray.cgColor
            
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: questionTextField.frame.height))
            questionTextField.leftView = paddingView
            questionTextField.leftViewMode = .always
            
            setupTrailingText()
        }
        
        private func setupTrailingText() {
            let unit = currentQuestion.unit
            
            if !unit.isEmpty {
                let trailingLabel = UILabel()
                trailingLabel.text = unit
                trailingLabel.textColor = .black
                trailingLabel.font = questionTextField.font
                trailingLabel.sizeToFit()
                
                let containerView = UIView(frame: CGRect(x: 0, y: 0, width: trailingLabel.frame.width + 12, height: trailingLabel.frame.height))
                containerView.addSubview(trailingLabel)
                containerView.backgroundColor = .clear
                containerView.layer.borderWidth = 0
                containerView.layer.borderColor = UIColor.clear.cgColor
                trailingLabel.center = containerView.center
                
                questionTextField.rightView = containerView
                questionTextField.rightViewMode = .always
            } else {
                questionTextField.rightView = nil
                questionTextField.rightViewMode = .never
            }
        }
        
        private func setupUI() {
            bottomView.layer.cornerRadius = 24

            questionLabel.text = currentQuestion.title
            questionImage.image = UIImage(named: currentQuestion.imageName)
            
            // Load previously entered value if exists
            if let savedValue = collectedValues[currentQuestion] {
                questionTextField.text = String(savedValue)
            } else {
                questionTextField.text = ""
            }
        }
        
        @objc private func textFieldDidChange() {
            updateQuestionTextFieldState()
            updateNextButtonState()
        }
    
        private func updateQuestionTextFieldState() {
            let text = questionTextField.text ?? ""
            let value = Int(text) ?? 0
            
            let isValid = value > 0
            if isValid {
                questionTextField.backgroundColor = .veryLightGreen
                questionTextField.layer.borderColor = UIColor.choaGreenColor.cgColor
            } else {
                questionTextField.backgroundColor = UIColor.textFieldBackgroundColor
                questionTextField.layer.borderColor = UIColor.lightGray.cgColor
            }
        }
        
        private func updateNextButtonState() {
            let text = questionTextField.text ?? ""
            let value = Int(text) ?? 0
            
            let isValid = value > 0
            nextButton.isEnabled = isValid
            nextButton.alpha = isValid ? 1.0 : 0.5
        }
        
        @IBAction func nextButtonTapped(_ sender: Any) {
            guard let text = questionTextField.text,
                  let value = Int(text),
                  value > 0 else {
                
                return
            }
            
            // Save the current value
            collectedValues[currentQuestion] = value
            
            // Check if there's a next question
            if let nextQuestion = currentQuestion.next {
                // Navigate to next question
                let storyboard = UIStoryboard(name: "Calculator", bundle: nil)
                if let nextVC = storyboard.instantiateViewController(withIdentifier: "calculatorOnboarding") as? CalculatorOnBoardingViewController {
                    nextVC.currentQuestion = nextQuestion
                    nextVC.collectedValues = self.collectedValues
                    nextVC.insulinForHighBloodSugarBoolean = self.insulinForHighBloodSugarBoolean
                    nextVC.insulinForFoodBoolean = self.insulinForFoodBoolean
                    self.navigationController?.pushViewController(nextVC, animated: true)
                }
            } else {
                // This is the last question, save all constants
                saveConstants()
            }
        }
        
        private func saveConstants() {
            guard let carbRatio = collectedValues[.carbRatio],
                  let targetBloodSugar = collectedValues[.targetBloodSugar],
                  let correctionFactor = collectedValues[.correctionFactor] else {

                return
            }
            
            // Save to CalculatorConstantsManager
            constantsManager.saveConstants(
                carbRatio: carbRatio,
                targetBloodSugar: targetBloodSugar,
                correctionFactor: correctionFactor
            )
            
            // Navigate to the appropriate calculator
            navigateToCalculator()
        }
        
    private func navigateToCalculator() {
        let storyboard = UIStoryboard(name: "Calculator", bundle: nil)
        
        if insulinForFoodBoolean == true && insulinForHighBloodSugarBoolean == false {
            // Navigate to CalculatorA (meals only)
            if let calculatorVC = storyboard.instantiateViewController(withIdentifier: "insulinForFoodCalculator") as? CalculatorAViewController {
                calculatorVC.insulinForFoodBoolean = insulinForFoodBoolean
                calculatorVC.insulinForHighBloodSugarBoolean = insulinForHighBloodSugarBoolean
                
                // Replace the navigation stack
                if let navigationController = self.navigationController {
                    var viewControllers = navigationController.viewControllers
                    // Remove all onboarding VCs
                    viewControllers.removeAll { $0 is CalculatorOnBoardingViewController || $0 is CalculatorOnBoardingWelcomeViewController }
                    viewControllers.append(calculatorVC)
                    navigationController.setViewControllers(viewControllers, animated: true)
                }
            }
        } else if insulinForHighBloodSugarBoolean == true && insulinForFoodBoolean == false {
            // Navigate to CalculatorB (high sugar only)
            if let calculatorVC = storyboard.instantiateViewController(withIdentifier: "insulinForHighSugarCalculator") as? CalculatorBViewController {
                calculatorVC.insulinForFoodBoolean = insulinForFoodBoolean
                calculatorVC.insulinForHighBloodSugarBoolean = insulinForHighBloodSugarBoolean
                calculatorVC.highBloodSugarOnly = true
                
                if let navigationController = self.navigationController {
                    var viewControllers = navigationController.viewControllers
                    viewControllers.removeAll { $0 is CalculatorOnBoardingViewController || $0 is CalculatorOnBoardingWelcomeViewController }
                    viewControllers.append(calculatorVC)
                    navigationController.setViewControllers(viewControllers, animated: true)
                }
            }
        } else if insulinForHighBloodSugarBoolean == true && insulinForFoodBoolean == true {
            // Navigate to CalculatorA (meals and high sugar)
            if let calculatorVC = storyboard.instantiateViewController(withIdentifier: "insulinForFoodCalculator") as? CalculatorAViewController {
                calculatorVC.insulinForFoodBoolean = insulinForFoodBoolean
                calculatorVC.insulinForHighBloodSugarBoolean = insulinForHighBloodSugarBoolean
                
                if let navigationController = self.navigationController {
                    var viewControllers = navigationController.viewControllers
                    viewControllers.removeAll { $0 is CalculatorOnBoardingViewController || $0 is CalculatorOnBoardingWelcomeViewController }
                    viewControllers.append(calculatorVC)
                    navigationController.setViewControllers(viewControllers, animated: true)
                }
            }
        }
    }
    
    @objc func didSelectExitAction() {
        if let viewControllers = navigationController?.viewControllers {
            for vc in viewControllers {
                if vc is HomeViewController {
                    navigationController?.popToViewController(vc, animated: true)
                    return
                }
            }
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension CalculatorOnBoardingViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Allow only numbers and decimal point
        let allowedCharacters = CharacterSet(charactersIn: "0123456789")
        let characterSet = CharacterSet(charactersIn: string)
        
        guard allowedCharacters.isSuperset(of: characterSet) else {
            return false
        }
        
        // Prevent multiple decimal points
        if string == "." && textField.text?.contains(".") == true {
            return false
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
