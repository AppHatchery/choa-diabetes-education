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
    @IBOutlet weak var willImageView: UIImageView!
    @IBOutlet weak var buttonsStackView: UIStackView!

    var insulinForHighBloodSugarBoolean = false
    var insulinForFoodBoolean = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupNavigationBar()
    }

    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        setupNavigationBar()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if RemoteConfigManager.shared.isHalloweenThemeEnabled {
            applyHalloweenTheme()
        }
    }

    /// Spooky background behind a see-through nav bar, with Halloween Will (speech bubble included in the image)
    private func applyHalloweenTheme() {
        let backgroundImageView = UIImageView(image: UIImage(named: "halloween_bg_1"))
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(backgroundImageView, at: 0)
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        // Shows through the image's transparent rounded corners on tall screens
        view.backgroundColor = .diabetesBasicsColor050

        // Scoped to this screen so the rest of the stack keeps its white bar
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance

        willImageView.image = UIImage(named: "halloween_will_three_quick_questions")
        // The Halloween Will is taller than the regular one, so let it shrink rather than run into the buttons on small screens
        willImageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        willImageView.bottomAnchor.constraint(lessThanOrEqualTo: buttonsStackView.topAnchor, constant: -16).isActive = true
    }
    
    private func setupNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.white
        appearance.shadowColor = UIColor.white
        
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
    }
    
    @objc func didSelectExitAction() {
        navigationController?.popViewController(animated: true)
    }
        
    @IBAction func didTapSkipButton(_ sender: Any) {
        // Skipping still counts as having been through onboarding, so the user isn't
        // asked again every time they open a calculator
        CalculatorConstantsManager.shared.hasCompletedOnboarding = true
        
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
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToOnboarding",
           let destinationVC = segue.destination as? CalculatorOnBoardingViewController {
            // Pass the booleans to the onboarding VC
            destinationVC.insulinForHighBloodSugarBoolean = self.insulinForHighBloodSugarBoolean
            destinationVC.insulinForFoodBoolean = self.insulinForFoodBoolean
            destinationVC.currentQuestion = .carbRatio
        }
    }
}
