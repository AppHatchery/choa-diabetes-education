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

        NotificationCenter.default.addObserver(self, selector: #selector(constantsDidChange), name: .calculatorConstantsDidChange, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Calculated here rather than in viewDidLoad so it also picks up a rounding rule changed while off screen
        calculateInsulin()
    }

    /// Redoes the total with the saved rounding rule (whole unit unless the user chose half unit)
    @objc private func constantsDidChange() {
        guard isViewLoaded else { return }
        calculateInsulin()
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

        resultsCardView.layer.cornerRadius = 12
        newCalculationButton.backgroundColor = .clear
    }
    
    func calculateInsulin() {
        let targetBloodSugarValue = targetBloodSugar > 0 ? targetBloodSugar : (constantsManager.hasStoredConstants ? constantsManager.targetBloodSugar : 0)
        
        // For meals + correction, round only the total; each part is shown unrounded.
        let roundsOnlyTotal = insulinForFoodBoolean && insulinForHighBloodSugarBoolean
        let roundingRule = constantsManager.roundingRule

        // Each dose is kept as an exact fraction so the sum isn't affected by floating-point error before it's rounded
        var food = InsulinDose.zero
        var blood = InsulinDose.zero

        // Insulin for food
        if insulinForFoodBoolean && carbRatio > 0 {
            food = .food(totalCarbs: totalCarbs, carbRatio: carbRatio)
            insulinForFood.text = food.displayText(rounded: !roundsOnlyTotal, using: roundingRule)
        } else {
            insulinForFood.text = "0"
        }

        // Insulin for blood sugar - use the same value for both condition and calculation
        if (insulinForHighBloodSugarBoolean && bloodSugar > 0 && targetBloodSugarValue > 0 && bloodSugar >= targetBloodSugarValue && correctionFactor > 0){
            blood = .correction(bloodSugar: bloodSugar, targetBloodSugar: targetBloodSugarValue, correctionFactor: correctionFactor)
            insulinForBloodSugar.text = blood.displayText(rounded: !roundsOnlyTotal, using: roundingRule)
        } else {
            insulinForBloodSugar.text = "0"
        }

        // Total insulin: the exact parts are added first and only the sum is rounded, using the saved rounding rule.
        // With only one part, the other is zero and this is just that part.
        totalInsulin.text = (food + blood).displayText(rounded: true, using: roundingRule)
        
        PendoManager.shared().track("Calculator_results", properties: ["total":totalInsulin.text ?? "-","for_food":insulinForFood.text ?? "-","for_hbs":insulinForBloodSugar.text ?? "-"])
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
