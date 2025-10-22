//
//  HomeViewController.swift
//  choa-diabetes-education
//
//  Created by Yago Arconada on 8/16/22.
//

import UIKit
import FirebaseAnalytics

class HomeViewController: UIViewController {
    
    @IBOutlet weak var orientationView: UIView!

	@IBOutlet var insulinCalculatorView: UIView!
	@IBOutlet var mealsAndHighSugarButton: UIButton!

	@IBOutlet var mealsButton: UIButton!
	@IBOutlet var highSugarButton: UIButton!

	@IBOutlet var getHelpView: UIView!
    @IBOutlet weak var getHelpViewImage: UIImageView!
    @IBOutlet var getHelpButton: UIButton!
    
    @IBOutlet var resourceCards: [UIView]!
    
    @IBOutlet weak var diabetesBasicsResourceCard: UIView!
    @IBOutlet weak var nutritionResourceCard: UIView!
    @IBOutlet weak var diabetesSelfManagementResourceCard: UIView!
    
    
    var chapterContent = 0
    var quizContent = 0
    var chapterName = ""
    var chapterSubName = ""
    
    let halloweenMessage = true

	var insulinForHighBloodSugar = false
	var insulinForFood = false
    var highBloodSugarOnly = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
		let appearance = UINavigationBarAppearance()
		appearance.configureWithOpaqueBackground()
		appearance.backgroundColor = UIColor.white
		appearance.shadowColor = UIColor.clear

		appearance.titleTextAttributes = [
			.foregroundColor: UIColor.black,
			.font: UIFont.gothamRoundedBold16
		]
		appearance.largeTitleTextAttributes = [
			.foregroundColor: UIColor.black,
			.font: UIFont.gothamRoundedBold16
		]
		appearance.backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
		appearance.backButtonAppearance.highlighted.titleTextAttributes = [.foregroundColor: UIColor.clear]

		navigationController?.navigationBar.standardAppearance = appearance
		navigationController?.navigationBar.scrollEdgeAppearance = appearance
		navigationController?.navigationBar.tintColor = UIColor.black

        navigationItem.backButtonDisplayMode = .minimal
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        let tabBarAppearance = UITabBarAppearance()
        
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor.white
        tabBarAppearance.shadowColor = UIColor.clear
        
        tabBarController?.tabBar.standardAppearance = tabBarAppearance
        tabBarController?.tabBar.scrollEdgeAppearance = tabBarAppearance
        tabBarController?.tabBar.tintColor = UIColor.black
        
        // Hide the tab bar entirely
        tabBarController?.tabBar.isHidden = true

		insulinCalculatorView.layer.cornerRadius = 12
		mealsAndHighSugarButton.layer.cornerRadius = 12

		mealsButton.layer.cornerRadius = 12
		mealsButton.layer.borderWidth = 1
		mealsButton.layer.borderColor = UIColor.white.cgColor

		highSugarButton.layer.cornerRadius = 12
		highSugarButton.layer.borderWidth = 1
		highSugarButton.layer.borderColor = UIColor.white.cgColor
        
		getHelpView.layer.cornerRadius = 12
        getHelpView.clipsToBounds = true
        getHelpViewImage.clipsToBounds = true
		getHelpButton.layer.cornerRadius = 12
		getHelpButton.titleLabel?.font = .gothamRoundedMedium16
        
        getHelpView.isUserInteractionEnabled = true
        let getHelpTap = UITapGestureRecognizer(target: self, action: #selector(didTapGetHelpView))
        getHelpView.addGestureRecognizer(getHelpTap)
        
        resourceCards.forEach {
            $0.layer.cornerRadius = 8
        }

        addTapRecognizersToResourceCards()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Get Help Gradient
        getHelpView.setGradientBackground(
            colors: [.gradientRedColor, .gradientRedColor2]
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let appearance = UINavigationBarAppearance()
        
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.shadowColor = .clear
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkAndRestoreActiveReminder()
    }

    private func addTapRecognizersToResourceCards() {
        // Ensure the views can receive touches
        diabetesBasicsResourceCard.isUserInteractionEnabled = true
        nutritionResourceCard.isUserInteractionEnabled = true
        diabetesSelfManagementResourceCard.isUserInteractionEnabled = true

        let basicsTap = UITapGestureRecognizer(target: self, action: #selector(didTapDiabetesBasicsCard))
        diabetesBasicsResourceCard.addGestureRecognizer(basicsTap)

        let nutritionTap = UITapGestureRecognizer(target: self, action: #selector(didTapNutritionCard))
        nutritionResourceCard.addGestureRecognizer(nutritionTap)

        let managementTap = UITapGestureRecognizer(target: self, action: #selector(didTapManagementCard))
        diabetesSelfManagementResourceCard.addGestureRecognizer(managementTap)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let orientationViewController = segue.destination as? OrientationViewController {
            // since we now know the contentView frame, pass it down so that the next controller will know it before viewDidAppear
            orientationViewController.contentFrame = self.view.bounds
            //            print(self.view.safeAreaInsets)
        }
        if let handbookViewController = segue.destination as? HandbookViewController {
            handbookViewController.chapterName = chapterName
            handbookViewController.chapterSubName = chapterSubName
            handbookViewController.chapterContent = chapterContent
            handbookViewController.quizContent = quizContent
        }
    }
    
    @IBAction func tapSection(_ sender: UIButton){
        switch sender.tag {
        case 0:
            chapterContent = ContentChapter().sectionOne.count
            quizContent = ContentChapter().sectionOne.count
        case 1:
            chapterContent = ContentChapter().sectionTwo.count
            quizContent = 2 // Commenting this out and fixing it at 1 because this section only has 1 chapter ContentChapter().sectionTwo.count
        case 2:
            chapterContent = ContentChapter().sectionThree.count
            quizContent = ContentChapter().sectionThree.count
        default:
            print("tag wasn't found")
        }
        chapterName = ContentChapter().sectionTitles[sender.tag]
        chapterSubName = ContentChapter().sectionSubtitles[sender.tag]
        
        // Halloween Style
        var dateComponents: DateComponents
        dateComponents = Calendar.current.dateComponents([.day, .month, .year, .hour, .minute, .second], from: Date())
        if dateComponents.month == 10 && dateComponents.day == 31 {
            let scared = UIAlertAction(title: "I'm scared", style: .default) { _ in
                self.performSegue(withIdentifier: "SegueToContentListViewController", sender: nil )
            }
            let boo = UIAlertController(title: "BE SPOOKED!", message: "", preferredStyle: .alert)
            boo.addAction(scared)
            self.present(boo, animated: true)
        } else {
            performSegue(withIdentifier: "SegueToContentListViewController", sender: nil )
        }
        
        //        performSegue(withIdentifier: "SegueToContentListViewController", sender: nil )
    }

    // MARK: - Tap handlers for resource cards

    @objc private func didTapDiabetesBasicsCard() {
        chapterContent = ContentChapter().sectionOne.count
        quizContent = ContentChapter().sectionOne.count
        chapterName = ContentChapter().sectionTitles[0]
        chapterSubName = ContentChapter().sectionSubtitles[0]
        performSegue(withIdentifier: "SegueToHandbook", sender: nil)
    }

    @objc private func didTapNutritionCard() {
        chapterContent = ContentChapter().sectionTwo.count
        quizContent = 2
        chapterName = ContentChapter().sectionTitles[1]
        chapterSubName = ContentChapter().sectionSubtitles[1]
        performSegue(withIdentifier: "SegueToHandbook", sender: nil)
    }

    @objc private func didTapManagementCard() {
        chapterContent = ContentChapter().sectionThree.count
        quizContent = ContentChapter().sectionThree.count
        chapterName = ContentChapter().sectionTitles[2]
        chapterSubName = ContentChapter().sectionSubtitles[2]
        performSegue(withIdentifier: "SegueToHandbook", sender: nil)
    }

	@IBAction func tappedMealsButton(_ sender: Any) {
		insulinForFood = true
		insulinForHighBloodSugar = false

		let storyboard = UIStoryboard(name: "Calculator", bundle: nil)

		if let destinationVC = storyboard.instantiateViewController(withIdentifier: "insulinForFoodCalculator") as? CalculatorAViewController {
			destinationVC.hidesBottomBarWhenPushed = true
			self.navigationController?.pushViewController(destinationVC, animated: true)
			destinationVC.insulinForHighBloodSugarBoolean = insulinForHighBloodSugar
			destinationVC.insulinForFoodBoolean = insulinForFood
		}
	}

	@IBAction func tappedHighSugarButton(_ sender: Any) {
		let storyboard = UIStoryboard(name: "Calculator", bundle: nil)

		insulinForFood = false
		insulinForHighBloodSugar = true
        highBloodSugarOnly = true

		if let destinationVC = storyboard.instantiateViewController(withIdentifier: "insulinForHighSugarCalculator") as? CalculatorBViewController {
			destinationVC.hidesBottomBarWhenPushed = true
			self.navigationController?.pushViewController(destinationVC, animated: true)

			destinationVC.insulinForFoodBoolean = insulinForFood
			destinationVC.insulinForHighBloodSugarBoolean = insulinForHighBloodSugar
            destinationVC.highBloodSugarOnly = highBloodSugarOnly
		}
	}


	@IBAction func tappedMealsAndHighSugarButton(_ sender: Any) {
		let storyboard = UIStoryboard(name: "Calculator", bundle: nil)

		insulinForFood = true
		insulinForHighBloodSugar = true
        highBloodSugarOnly = false

		if let destinationVC = storyboard.instantiateViewController(withIdentifier: "insulinForFoodCalculator") as? CalculatorAViewController {
			destinationVC.hidesBottomBarWhenPushed = true
			self.navigationController?.pushViewController(destinationVC, animated: true)
			destinationVC.insulinForFoodBoolean = insulinForFood
			destinationVC.insulinForHighBloodSugarBoolean = insulinForHighBloodSugar
		}
	}
    
    @objc private func didTapGetHelpView() {
        tappedGetHelpButton(self)
    }

	@IBAction func tappedGetHelpButton(_ sender: Any) {
		insulinForFood = true
		insulinForHighBloodSugar = true
		getHelpButton.titleLabel?.font = .gothamRoundedMedium16
        

		let manager = QuestionnaireManager.instance
			//		let firstQues = manager.createYesOrNoQuestion(questionId: .severeDistress, question: "Calculator.Que.SevereDistress.title".localized(), description: "Calculator.Que.SevereDistress.description".localized(), showDescriptionAtBottom: false)
        
        QuestionnaireManager.resetInstance()

		let firstQues = manager.createFourCustomOptionsQuestion(
			questionId: FourOptionsQuestionId.childIssue,
			question: "GetHelp.Que.ChildIssue.title".localized(),
			description: nil,
			answerOptions: [
				"GetHelp.Que.ChildIssue.option1".localized(),
				"GetHelp.Que.ChildIssue.option2".localized(),
				"GetHelp.Que.ChildIssue.option3".localized(),
				"GetHelp.Que.ChildIssue.option4".localized()
			]
		)

		let getHelpViewController = UIStoryboard(name: "GetHelp", bundle: nil).instantiateViewController(
			identifier: String(describing: GetHelpViewController.self)
		) { creator in
			GetHelpViewController(
				navVC: self.navigationController!,
				currentQuestion: firstQues,
				coder: creator
			)
		}

		self.navigationController?.pushViewController(getHelpViewController, animated: true)
	}
}

extension HomeViewController {
    func checkAndRestoreActiveReminder() {
        // Only check once per app launch to avoid repeated navigation
        guard !hasCheckedForReminder else { return }
        hasCheckedForReminder = true
        
        // Check if there's a saved reminder state
        guard let reminderState = ReminderPersistence.loadReminderState() else {
            return
        }
        
        // Check if the reminder is still valid
        let timeRemaining = reminderState.scheduledTime.timeIntervalSince(Date())
        guard timeRemaining > 0 else {
            // Reminder expired, clean up
            ReminderPersistence.clearReminderState()
            return
        }
        
        // Navigate to the FinalStepWithReminder page after a short delay
        // to allow the view to fully appear
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
            ReminderPersistence.navigateToReminderPage(from: self, state: reminderState)
        }
    }
    
    // Add this property to HomeViewController to track if we've checked
    private static var hasCheckedForReminder = false
    private var hasCheckedForReminder: Bool {
        get { HomeViewController.hasCheckedForReminder }
        set { HomeViewController.hasCheckedForReminder = newValue }
    }
    
    // Reset the check flag when app becomes active
    static func resetReminderCheck() {
        hasCheckedForReminder = false
    }
}
