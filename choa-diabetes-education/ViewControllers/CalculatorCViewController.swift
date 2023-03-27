//
//  CalculatorCViewController.swift
//  choa-diabetes-education
//
//  Created by Yago Arconada on 1/3/23.
//

import UIKit
import Pendo

class CalculatorCViewController: UIViewController {

    @IBOutlet weak var insulinForFood: UILabel!
    @IBOutlet weak var insulinForBloodSugar: UILabel!
    @IBOutlet weak var totalInsulin: UILabel!
    
    var totalCarbs: Float = 0
    var bloodSugar: Float = 0
    var targetBloodSugar: Float = 0
    var carbRatio: Float = 0
    var correctionFactor: Float = 0
    
    var insulinForHighBloodSugarBoolean = false
    var insulinForFoodBoolean = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        calculateInsulin()
        // Do any additional setup after loading the view.
    }
    
    func calculateInsulin() {
        // Algorithm operations to calculate each block
        var foodInsulin:Float = 0.0
        var bloodInsulin:Float = 0.0
        
        // Insulin for food
        if (insulinForFoodBoolean){
            foodInsulin = roundToOneDecimal(value: (totalCarbs / carbRatio))
            insulinForFood.text = String(foodInsulin)
        } else {
            insulinForFood.text = "-"
        }
        
        // Insulin for blood sugar
        if (insulinForHighBloodSugarBoolean && bloodSugar >= 150){
            bloodInsulin = roundToOneDecimal(value: (bloodSugar - targetBloodSugar) / correctionFactor)
            insulinForBloodSugar.text = String(bloodInsulin)
        } else {
            insulinForBloodSugar.text = "-"
        }
        
        // Total insulin
        totalInsulin.text = String(roundToOneDecimal(value:foodInsulin + bloodInsulin))
        print("calculate insulin")
        PendoManager.shared().track("Calculator_results", properties: ["total":totalInsulin.text ?? "-","for_food":insulinForFood.text ?? "-","for_hbs":insulinForBloodSugar.text ?? "-"])
    }

    func roundToOneDecimal(value: Float)-> Float {
        return (round(value*10)/10.0)
    }
    
    @IBAction func newCalculation(_ sender: UIButton){
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: CalculatorHomeViewController.self) {
                self.navigationController!.popToViewController(controller, animated: true)
                break
            }
        }
    }

}
