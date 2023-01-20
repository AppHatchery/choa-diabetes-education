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

        // Do any additional setup after loading the view.
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let calculatorAViewController = segue.destination as? CalculatorAViewController
        {
            calculatorAViewController.insulinForHighBloodSugarBoolean = insulinForHighBloodSugar
            calculatorAViewController.insulinForFoodBoolean = insulinForFood
        }
        if let calculatorBViewController = segue.destination as? CalculatorBViewController
        {
            calculatorBViewController.insulinForFoodBoolean = insulinForFood
            calculatorBViewController.insulinForHighBloodSugarBoolean = insulinForHighBloodSugar
        }
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
