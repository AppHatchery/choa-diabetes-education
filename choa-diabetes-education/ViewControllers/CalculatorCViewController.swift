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

    @IBOutlet weak var heroView: UIView!
    @IBOutlet weak var willImageView: UIImageView!
    @IBOutlet weak var resultsCardView: UIView!
    @IBOutlet weak var newCalculationButton: UIButton!
    @IBOutlet weak var heroTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var heroHeightConstraint: NSLayoutConstraint!

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

        if RemoteConfigManager.shared.isHalloweenThemeEnabled {
            applyHalloweenTheme()
        }

        calculateInsulin()
        // Do any additional setup after loading the view.
    }

    /// Spooky background behind a see-through nav bar, a bigger Halloween Will
    /// standing on the results card, and a translucent card.
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

        // Will replaces the confetti and grows into the top spacing, keeping the card where it was
        animationView.stop()
        animationView.isHidden = true
        heroView.backgroundColor = .clear
        heroHeightConstraint.constant += heroTopConstraint.constant
        heroTopConstraint.constant = 0
        willImageView.image = UIImage(named: "halloween_will_calculator_cropped")
        willImageView.contentMode = .scaleAspectFit

        resultsCardView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        resultsCardView.layer.cornerRadius = 12
        newCalculationButton.backgroundColor = .clear
    }
    
    func calculateInsulin() {
        let targetBloodSugarValue = targetBloodSugar > 0 ? targetBloodSugar : (constantsManager.hasStoredConstants ? constantsManager.targetBloodSugar : 0)
        
        // For meals + correction, round only the total; each part is shown unrounded.
        let roundsOnlyTotal = insulinForFoodBoolean && insulinForHighBloodSugarBoolean

        // Each dose is kept as an exact fraction (numerator / denominator) so the sum isn't
        // affected by floating-point error before it's rounded.
        var food = (numerator: 0, denominator: 1)
        var blood = (numerator: 0, denominator: 1)

        // Insulin for food
        if insulinForFoodBoolean && carbRatio > 0 {
            food = (totalCarbs, carbRatio)
            let exactFoodInsulin = Float(food.numerator) / Float(food.denominator)
            insulinForFood.text = (roundsOnlyTotal ? exactFoodInsulin.preciseString : roundDownToNearestHalf(value: exactFoodInsulin).cleanString) + " units"
        } else {
            insulinForFood.text = "0"
        }

        // Insulin for blood sugar - use the same value for both condition and calculation
        if (insulinForHighBloodSugarBoolean && bloodSugar > 0 && targetBloodSugarValue > 0 && bloodSugar >= targetBloodSugarValue && correctionFactor > 0){
            blood = (bloodSugar - targetBloodSugarValue, correctionFactor)
            let exactBloodInsulin = Float(blood.numerator) / Float(blood.denominator)
            insulinForBloodSugar.text = (roundsOnlyTotal ? exactBloodInsulin.preciseString : roundDownToNearestHalf(value: exactBloodInsulin).cleanString) + " units"
        } else {
            insulinForBloodSugar.text = "0"
        }

        // Total insulin
        let total: Float
        if roundsOnlyTotal {
            // food + blood = (a/b + c/d) = (a·d + c·b) / (b·d); round to the nearest whole unit (.5 rounds up)
            let numerator = food.numerator * blood.denominator + blood.numerator * food.denominator
            let denominator = food.denominator * blood.denominator
            total = Float((2 * numerator + denominator) / (2 * denominator))
        } else {
            let foodInsulin = roundDownToNearestHalf(value: Float(food.numerator) / Float(food.denominator))
            let bloodInsulin = roundDownToNearestHalf(value: Float(blood.numerator) / Float(blood.denominator))
            total = (foodInsulin + bloodInsulin).rounded()
        }
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
