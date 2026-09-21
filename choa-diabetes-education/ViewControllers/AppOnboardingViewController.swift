//
//  AppOnboardingViewController.swift
//  choa-diabetes-education
//
//  Created by Maxwell Kapezi Jr on 21/09/2026.
//

import UIKit

class AppOnboardingViewController: UIViewController {
    @IBOutlet weak var testButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "App Onboarding"
    }

    @IBAction func didTapMainAppButton(_ sender: Any) {
        guard let window = view.window else { return }

        let mainViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()

        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            window.rootViewController = mainViewController
        })
    }
}
