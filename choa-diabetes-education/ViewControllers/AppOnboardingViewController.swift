//
//  AppOnboardingViewController.swift
//  choa-diabetes-education
//
//  Created by Maxwell Kapezi Jr on 21/09/2026.
//

import UIKit

class AppOnboardingViewController: UIViewController {
    static let storyboardIdentifier = "appOnboardingQuestion"

    // Which question this screen instance shows, and every answer collected so far
    var currentQuestion: AppOnboardingQuestion = .userRole
    var answers: [AppOnboardingQuestion: AppOnboardingAnswer] = [:]

    private var questionView: AppOnboardingQuestionView {
        view as! AppOnboardingQuestionView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.tintColor = .choaGreenColor
        navigationItem.backButtonDisplayMode = .minimal

        // The first screen in the flow starts with no answers passed in; resume
        // from whatever was previously saved, if anything.
        if answers.isEmpty {
            answers = AppOnboardingManager.shared.answers
        }

        questionView.configure(with: currentQuestion, answer: answers[currentQuestion])
        questionView.onAnswerChanged = { [weak self] answer in
            guard let self else { return }
            self.answers[self.currentQuestion] = answer
        }
        questionView.onNext = { [weak self] in
            self?.goToNextQuestion()
        }
    }

    private func goToNextQuestion() {
        let selectedOptionId = answers[currentQuestion]?.selectedOptionId

        if let nextQuestion = currentQuestion.next(selectedOptionId: selectedOptionId) {
            let storyboard = UIStoryboard(name: "AppOnboarding", bundle: nil)
            if let nextViewController = storyboard.instantiateViewController(withIdentifier: Self.storyboardIdentifier) as? AppOnboardingViewController {
                nextViewController.currentQuestion = nextQuestion
                nextViewController.answers = answers
                navigationController?.pushViewController(nextViewController, animated: true)
            }
        } else {
            finishOnboarding()
        }
    }

    private func finishOnboarding() {
        AppOnboardingManager.shared.saveAnswers(answers)

        guard let window = view.window else { return }

        let mainViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()

        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            window.rootViewController = mainViewController
        })
    }
}
