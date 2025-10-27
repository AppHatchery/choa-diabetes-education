//
//  CalculatorOnBoardingWelcomeViewController.swift
//  choa-diabetes-education
//
//  Created by Maxwell Kapezi Jr on 27/10/2025.
//

import UIKit

class CalculatorOnBoardingWelcomeViewController: UIViewController {
    @IBOutlet weak var nextButton: PrimaryButton!
    @IBOutlet weak var skipButton: UIButton!
    
    var insulinForHighBloodSugarBoolean = false
    var insulinForFoodBoolean = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.backButtonDisplayMode = .minimal
        
        let icon = UIImage(named: "close_black")
        let rightButton = UIBarButtonItem(
            image: icon,
            style: .plain,
            target: self,
            action: #selector(didSelectExitAction)
        )
        navigationItem.rightBarButtonItem = rightButton
        
        // Do any additional setup after loading the view.
    }
    
    @objc func didSelectExitAction() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didTapNextButton(_ sender: Any) {
        
    }
    
    @IBAction func didTapSkipButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Calculator", bundle: nil)
        
        if insulinForFoodBoolean == true && insulinForHighBloodSugarBoolean == false {
            
            if let destinationVC = storyboard.instantiateViewController(withIdentifier: "insulinForFoodCalculator") as? CalculatorAViewController {
                destinationVC.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(destinationVC, animated: true)
                destinationVC.insulinForHighBloodSugarBoolean = insulinForHighBloodSugarBoolean
                destinationVC.insulinForFoodBoolean = insulinForFoodBoolean
            }
        } else if insulinForFoodBoolean == false && insulinForHighBloodSugarBoolean == true {
            
            if let destinationVC = storyboard.instantiateViewController(withIdentifier: "insulinForHighSugarCalculator") as? CalculatorBViewController {
                destinationVC.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(destinationVC, animated: true)

                destinationVC.insulinForFoodBoolean = false
                destinationVC.insulinForHighBloodSugarBoolean = true
                destinationVC.highBloodSugarOnly = true
            }
        } else if insulinForFoodBoolean == true && insulinForHighBloodSugarBoolean == true {
            
            if let destinationVC = storyboard.instantiateViewController(withIdentifier: "insulinForFoodCalculator") as? CalculatorAViewController {
                destinationVC.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(destinationVC, animated: true)
                destinationVC.insulinForFoodBoolean = true
                destinationVC.insulinForHighBloodSugarBoolean = true
            }
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
