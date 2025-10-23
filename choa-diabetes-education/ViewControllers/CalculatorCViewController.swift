//
//  CalculatorCViewController.swift
//  choa-diabetes-education
//
//  Created by Yago Arconada on 1/3/23.
//

import UIKit
import Pendo
import Lottie

class CalculatorCViewController: UIViewController {
    
    @IBOutlet weak var insulinForFood: UILabel!
    @IBOutlet weak var insulinForBloodSugar: UILabel!
    @IBOutlet weak var totalInsulin: UILabel!
    @IBOutlet weak var animationView: LottieAnimationView!
    
    var totalCarbs: Int = 0
    var bloodSugar: Int = 0
    var targetBloodSugar: Int = 0
    var carbRatio: Int = 0
    var correctionFactor: Int = 0
    
    var insulinForHighBloodSugarBoolean = false
    var insulinForFoodBoolean = true
    
    private let constantsManager = CalculatorConstantsManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appearance = UINavigationBarAppearance()
        
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .whiteColor
        appearance.shadowColor = .clear
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        animationView.loopMode = .loop
        animationView.play()
        
        calculateInsulin()
        // Do any additional setup after loading the view.
    }
    
    func calculateInsulin() {
        let targetBloodSugarValue = targetBloodSugar > 0 ? targetBloodSugar : (constantsManager.hasStoredConstants ? constantsManager.targetBloodSugar : 0)
        
        // Algorithm operations to calculate each block
        var foodInsulin:Float = 0.0
        var bloodInsulin:Float = 0.0
        
        // Insulin for food
        if (insulinForFoodBoolean){
            foodInsulin = roundDownToNearestHalf(
                value: Float(totalCarbs) / Float(carbRatio)
            )
            insulinForFood.text = String(foodInsulin.cleanString) + " units"
        } else {
            insulinForFood.text = "0"
        }
        
        // Insulin for blood sugar - use the same value for both condition and calculation
        if (insulinForHighBloodSugarBoolean && bloodSugar > 0 && targetBloodSugarValue > 0 && bloodSugar >= targetBloodSugarValue){
            bloodInsulin = roundDownToNearestHalf(
                value: Float(bloodSugar - targetBloodSugarValue) / Float(correctionFactor)
            )
            insulinForBloodSugar.text = String(
                bloodInsulin.cleanString
            ) + " units"
        } else {
            insulinForBloodSugar.text = "0"
        }
        
        // Total insulin
        let total = roundDownToNearestHalf(value: foodInsulin + bloodInsulin)
        totalInsulin.text = "\(total.cleanString) units"
        
        PendoManager.shared().track("Calculator_results", properties: ["total":totalInsulin.text ?? "-","for_food":insulinForFood.text ?? "-","for_hbs":insulinForBloodSugar.text ?? "-"])
    }
    
    func roundDownToNearestHalf(value: Float) -> Float {
        let integerPart = floor(value)
        let decimalPart = value - integerPart

        if decimalPart >= 0.5 {
            return integerPart + 0.5
        } else {
            return integerPart
        }
    }
    
    @IBAction func newCalculation(_ sender: UIButton){
        for controller in self.navigationController!.viewControllers as Array {
            if let calcA = controller as? CalculatorAViewController {
                calcA.resetCalculatorFields()
                self.navigationController!.popToViewController(controller, animated: true)
                break
            } else if controller.isKind(of: CalculatorBViewController.self) {
                self.navigationController!.popToViewController(controller, animated: true)
                break
            }
        }
    }
    
    @IBAction func didExitCalculatorTap(_ sender: Any) {
        
        if let nav = self.navigationController {
            for controller in nav.viewControllers {
                if controller.isKind(of: HomeViewController.self) {
                    nav.popToViewController(controller, animated: true)
                    return
                }
            }
            
            // Fallback: pop to root if HomeViewController isn't found
            nav.popToRootViewController(animated: true)
        }
    }
}
