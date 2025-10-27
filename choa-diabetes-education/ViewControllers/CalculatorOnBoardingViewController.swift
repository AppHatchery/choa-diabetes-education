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

    var insulinForHighBloodSugarBoolean = false
    var insulinForFoodBoolean = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.clear
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
        
        bottomView.layer.cornerRadius = 12

        // Do any additional setup after loading the view.
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
