//
//  CalculatorHomeViewController.swift
//  choa-diabetes-education
//
//  Created by Yago Arconada on 1/3/23.
//

import UIKit

class CalculatorHomeViewController: UIViewController {

    var insulinForHighBloodSugar = false
    var insulinForFood = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.tableView.sectionHeaderTopPadding = 0.0
//        self.tableView.sectionHeaderHeight = 0.0
//        self.tableView.estimatedSectionHeaderHeight = 0.0
//        self.tableView.contentInsetAdjustmentBehavior = .never
    }
    
    @IBAction func calculateInsulinForFood(_ sender: UIButton){
        insulinForFood = true
        insulinForHighBloodSugar = false
    }
    
    @IBAction func calculateInsulinForHighBloodSugar(_ sender: UIButton){
        insulinForFood = false
        insulinForHighBloodSugar = true
    }
    
    @IBAction func calculateBoth(_ sender: UIButton){
        insulinForFood = true
        insulinForHighBloodSugar = true
    }
    
    @IBAction func calculateBloodSugarWithSymptoms(_ sender: UIButton) {
        let manager = QuestionnaireManager.instance
        let firstQues = manager.createYesOrNoQuestion(questionId: .severeDistress, question: "Calculator.Que.SevereDistress.title".localized(), description: "Calculator.Que.SevereDistress.description".localized(), showDescriptionAtBottom: false)
        let calculatorBaseVC = UIStoryboard(name: "Calculator", bundle: nil).instantiateViewController(identifier: String(describing: CalculatorBaseVC.self)) { creator in
            CalculatorBaseVC(navVC: self.navigationController!, currentQuestion: firstQues, coder: creator)
        }
        
        self.navigationController?.pushViewController(calculatorBaseVC, animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let calculatorAViewController = segue.destination as? CalculatorAViewController {
            calculatorAViewController.insulinForHighBloodSugarBoolean = insulinForHighBloodSugar
            calculatorAViewController.insulinForFoodBoolean = insulinForFood
        }
        if let calculatorBViewController = segue.destination as? CalculatorBViewController {
            calculatorBViewController.insulinForFoodBoolean = insulinForFood
            calculatorBViewController.insulinForHighBloodSugarBoolean = insulinForHighBloodSugar
        }
        
//        if let calculatorBaseVC = segue.destination as? CalculatorBaseVC {
//            let manager = QuestionnaireManager.instance
//            let firstQues = manager.createQuestion(questionId: 1, questionType: .yesOrNoWithDescription, question: "Calculator.Que.SevereDistress.title".localized(), description: "Calculator.Que.SevereDistress.description".localized(), answerOptions: ["Yes", "No"])
//            calculatorBaseVC.questionObj = firstQues
//        }
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
