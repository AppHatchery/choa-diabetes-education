//
//  HomeViewController.swift
//  choa-diabetes-education
//
//  Created by Yago Arconada on 8/16/22.
//

import UIKit
import FirebaseAnalytics

class HomeViewController: UIViewController {
    
    @IBOutlet weak var diabetesBasicsButton: UIButton!
    @IBOutlet weak var nutritionButton: UIButton!
    @IBOutlet weak var managementButton: UIButton!
    @IBOutlet weak var orientationView: UIView!
//    @IBOutlet weak var orientationButton: UIButton!
//    @IBOutlet weak var orientationTitleLabel: UILabel!
//    @IBOutlet weak var orientationSubTitleLabel: UILabel!

	@IBOutlet var insulinCalculatorView: UIView!
	@IBOutlet var mealsAndHighSugarButton: UIButton!

	@IBOutlet var mealsButton: UIButton!
	@IBOutlet var highSugarButton: UIButton!

	@IBOutlet var getHelpView: UIView!
	@IBOutlet var getHelpButton: UIButton!

	@IBOutlet weak var firstDayLabel: UILabel!
    @IBOutlet weak var secondDayLabel: UILabel!
    
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
        
        let tabBarAppearance = UITabBarAppearance()
        
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor.white
        tabBarAppearance.shadowColor = UIColor.clear
        
        tabBarController?.tabBar.standardAppearance = tabBarAppearance
        tabBarController?.tabBar.scrollEdgeAppearance = tabBarAppearance
        tabBarController?.tabBar.tintColor = UIColor.black

//        orientationTitleLabel.text = "Home.Orientation.Title".localized()
//        orientationSubTitleLabel.text = "Home.Orientation.Subtitle".localized()
        
        let subtitleFont =  UIFont.gothamRoundedBold16
        let titleFont =  UIFont.avenirLight14
        
        let diabetesBasicsButtonTitle = NSAttributedString(string: "Home.SectionOne.Title".localized(), attributes: [NSAttributedString.Key.font: titleFont])
        let nutritionButtonTitle = NSAttributedString(string: "Home.SectionTwo.Title".localized(), attributes: [NSAttributedString.Key.font: titleFont])
        let managementButtonTitle = NSAttributedString(string: "Home.SectionThree.Title".localized(), attributes: [NSAttributedString.Key.font: titleFont])

		insulinCalculatorView.layer.cornerRadius = 12
		mealsAndHighSugarButton.layer.cornerRadius = 12

		mealsButton.layer.cornerRadius = 12
		mealsButton.layer.borderWidth = 1
		mealsButton.layer.borderColor = UIColor.white.cgColor

		highSugarButton.layer.cornerRadius = 12
		highSugarButton.layer.borderWidth = 1
		highSugarButton.layer.borderColor = UIColor.white.cgColor

		getHelpView.layer.cornerRadius = 12
		getHelpButton.layer.cornerRadius = 12
		getHelpButton.titleLabel?.font = .gothamRoundedMedium16
        
        resourceCards.forEach {
            $0.layer.cornerRadius = 8
        }

        addTapRecognizersToResourceCards()

//        diabetesBasicsButton.setAttributedTitle(diabetesBasicsButtonTitle, for: .normal)
//        nutritionButton.setAttributedTitle(nutritionButtonTitle, for: .normal)
//        managementButton.setAttributedTitle(managementButtonTitle, for: .normal)
//        
//        var resultSectionOne = AttributedString("Home.SectionOne.Subtitle".localized())
//        resultSectionOne.font = subtitleFont
//        diabetesBasicsButton.configuration?.attributedSubtitle = resultSectionOne
//        
//        var resultSectionTwo = AttributedString("Home.SectionTwo.Subtitle".localized())
//        resultSectionTwo.font = subtitleFont
//        nutritionButton.configuration?.attributedSubtitle = resultSectionTwo
//        
//        var resultSectionThree = AttributedString("Home.SectionThree.Subtitle".localized())
//        resultSectionThree.font = subtitleFont
//        managementButton.configuration?.attributedSubtitle = resultSectionThree
//        
//        diabetesBasicsButton.detailedDropShadow(color: UIColor.diabetesBasicsDropShadowColor.cgColor, blur: 24.0, offset: 12, opacity: 1)
//        nutritionButton.detailedDropShadow(color: UIColor.nutritionDropShadowColor.cgColor, blur: 24.0, offset: 12, opacity: 1)
//        managementButton.detailedDropShadow(color: UIColor.managementDropShadowColor.cgColor, blur: 24.0, offset: 12, opacity: 1)
//        orientationView.detailedDropShadow(color: UIColor.orientationViewDropShadowColor.cgColor, blur: 12.0, offset: 8, opacity: 0.62)
//        orientationButton.detailedDropShadow(color:  UIColor.orientationButtonDropShadowColor.cgColor, blur: 12, offset: 6, opacity: 0.59)
//        firstDayLabel.text = "Home.FirstDay.Title".localized()
//        secondDayLabel.text = "Home.SecondDay.Title".localized()
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

		if let destinationVC = storyboard.instantiateViewController(withIdentifier: "insulinForHighSugarCalculator") as? CalculatorBViewController {
			destinationVC.hidesBottomBarWhenPushed = true
			self.navigationController?.pushViewController(destinationVC, animated: true)

			destinationVC.insulinForFoodBoolean = insulinForFood
			destinationVC.insulinForHighBloodSugarBoolean = insulinForHighBloodSugar
		}
	}


	@IBAction func tappedMealsAndHighSugarButton(_ sender: Any) {
		let storyboard = UIStoryboard(name: "Calculator", bundle: nil)

		insulinForFood = true
		insulinForHighBloodSugar = true

		if let destinationVC = storyboard.instantiateViewController(withIdentifier: "insulinForFoodCalculator") as? CalculatorAViewController {
			destinationVC.hidesBottomBarWhenPushed = true
			self.navigationController?.pushViewController(destinationVC, animated: true)
			destinationVC.insulinForFoodBoolean = insulinForFood
			destinationVC.insulinForHighBloodSugarBoolean = insulinForHighBloodSugar
		}
	}

	@IBAction func tappedGetHelpButton(_ sender: Any) {
		insulinForFood = true
		insulinForHighBloodSugar = true
		getHelpButton.titleLabel?.font = .gothamRoundedMedium16

		let manager = QuestionnaireManager.instance
			//		let firstQues = manager.createYesOrNoQuestion(questionId: .severeDistress, question: "Calculator.Que.SevereDistress.title".localized(), description: "Calculator.Que.SevereDistress.description".localized(), showDescriptionAtBottom: false)

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

