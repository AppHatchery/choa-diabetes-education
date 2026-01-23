//
//  ChapterEndViewController.swift
//  choa-diabetes-education
//
//  Created by Yago Arconada on 8/31/22.
//

import UIKit

class ChapterEndViewController: UIViewController {
    
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var nextChapterButton: PrimaryButton!
    @IBOutlet weak var congratsLabel: UILabel!
    
    @IBOutlet weak var textBubbleImage: UIImageView!
    @IBOutlet weak var hopeOrWillImage: UIImageView!
    
    @IBOutlet weak var bottomStarsView: UIView!
    @IBOutlet weak var starsStackView: UIStackView!
    
    @IBOutlet weak var chaptersCompletedLabel: UILabel!
    
    @IBOutlet weak var rightStarsStackConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftStarsStackConstraint: NSLayoutConstraint!
    
    
    
    var contentIndex = 0
    var chapterEndTitle = ""
    var nextChapter = ""
    var nextChapterURL = ""
    var quizIndex = 0
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.shadowColor = UIColor.clear
        
        appearance.buttonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        if contentIndex == 0 {
            appearance.backgroundColor = .diabetesBasicsColor
            mainView.backgroundColor = .diabetesBasicsColor
        } else if contentIndex == 1 {
            appearance.backgroundColor = .nutritionAndCarbColor
            mainView.backgroundColor = .nutritionAndCarbColor
        } else {
            appearance.backgroundColor = .diabetesSelfManagementColor
            mainView.backgroundColor = .diabetesSelfManagementColor
        }
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        
        navigationController?.navigationBar.tintColor = .white
        navigationItem.backButtonDisplayMode = .minimal
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.tintColor = .white
        navigationItem.backButtonDisplayMode = .minimal
        
        bottomStarsView.layer.cornerRadius = 20
        bottomStarsView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        nextChapterButton.layer.cornerRadius = 12
        
        switch contentIndex {
        case 0:
            if let chapterEndTitleIndex = ContentChapter().sectionOne.firstIndex(where: { $0.contentTitle == chapterEndTitle }) {
                if chapterEndTitleIndex < ContentChapter().sectionOne.count - 1 {
                    nextChapter = ContentChapter().sectionOne[chapterEndTitleIndex + 1].contentTitle
                    nextChapterURL = ContentChapter().sectionOne[chapterEndTitleIndex + 1].contentHTML
                }
                quizIndex = chapterEndTitleIndex
                
                // Update text bubble image for Section One based on the completed chapter index
                if chapterEndTitleIndex == 0 {
                    congratsLabel.text = "Congratulatory1".localized()
                    textBubbleImage.image = UIImage(named: "diabetes_basics_text_bubble_1")
                } else if chapterEndTitleIndex == 1 {
                    congratsLabel.text = "Congratulatory2".localized()
                    textBubbleImage.image = UIImage(named: "diabetes_basics_text_bubble_2")
                    hopeOrWillImage.image = UIImage(named: "will_pump")
                } else if chapterEndTitleIndex == 2 {
                    congratsLabel.text = "Congratulatory3".localized()
                    textBubbleImage.image = UIImage(named: "diabetes_basics_text_bubble_3")
                    hopeOrWillImage.image = UIImage(named: "hope_basics")
                } else if chapterEndTitleIndex == 3 {
                    congratsLabel.text = "Congratulatory4".localized()
                    textBubbleImage.image = UIImage(named: "diabetes_basics_text_bubble_4")
                    hopeOrWillImage.image = UIImage(named: "will_pen")
                } else {
                    congratsLabel.text = "Congratulatory5".localized()
                    textBubbleImage.image = UIImage(named: "diabetes_basics_text_bubble_5")
                    hopeOrWillImage.image = UIImage(named: "will_pen")
                }
            }
        case 1:
            if let chapterEndTitleIndex = ContentChapter().sectionTwo.firstIndex(where: { $0.contentTitle == chapterEndTitle }) {
                if chapterEndTitleIndex < ContentChapter().sectionTwo.count - 1 {
                    nextChapter = ContentChapter().sectionTwo[chapterEndTitleIndex + 1].contentTitle
                    nextChapterURL = ContentChapter().sectionTwo[chapterEndTitleIndex + 1].contentHTML
                }
                quizIndex = chapterEndTitleIndex
                
                if chapterEndTitleIndex == 0 {
                    congratsLabel.text = "Congratulatory1".localized()
                    textBubbleImage.image = UIImage(named: "nutrition_carb_text_bubble_1")
                    hopeOrWillImage.image = UIImage(named: "will_nutrition_food")
                } else if chapterEndTitleIndex == 1 {
                    congratsLabel.text = "Congratulatory2".localized()
                    textBubbleImage.image = UIImage(named: "nutrition_carb_text_bubble_2")
                    hopeOrWillImage.image = UIImage(named: "hope_burger")
                } else {
                    congratsLabel.text = "Congratulatory6".localized()
                    textBubbleImage.image = UIImage(named: "nutrition_carb_text_bubble_3")
                    hopeOrWillImage.image = UIImage(named: "will_nutrition")
                }
                
                // Extra logic for section 2 with chapters that don't contain a quiz
                if chapterEndTitleIndex == 1 || chapterEndTitleIndex == 3 {
                    // quiz disabled for these indices
                }
            }
        case 2:
            if let chapterEndTitleIndex = ContentChapter().sectionThree.firstIndex(where: { $0.contentTitle == chapterEndTitle }) {
                if chapterEndTitleIndex < ContentChapter().sectionThree.count - 1 {
                    nextChapter = ContentChapter().sectionThree[chapterEndTitleIndex + 1].contentTitle
                    nextChapterURL = ContentChapter().sectionThree[chapterEndTitleIndex + 1].contentHTML
                }
                quizIndex = chapterEndTitleIndex
                
                if chapterEndTitleIndex == 0 {
                    congratsLabel.text = "Congratulatory1".localized()
                    textBubbleImage.image = UIImage(named: "self_managment_text_bubble_1")
                    hopeOrWillImage.image = UIImage(named: "will_nutrition_food")
                } else {
                    congratsLabel.text = "Congratulatory6".localized()
                    textBubbleImage.image = UIImage(named: "self_managment_text_bubble_2")
                    hopeOrWillImage.image = UIImage(named: "hope_on_call")
                }
            }
        default:
            print("error where index doesn't match")
        }
        
        updateStarsUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        navigationController?.navigationBar.tintColor = .white
        navigationItem.backButtonDisplayMode = .minimal
        
        // Hide next button if the end of the section
        if nextChapter != "" {
            // there is a next chapter, keep button as-is
        } else {
            // final chapter in section
            nextChapterButton
                .setTitleWithStyle(
                    "Done",
                    font: .gothamRoundedMedium20,
                    image: nil
                )
            nextChapterButton.setImage(nil, for: .normal)
        }
        
        // Refresh stars in case the view reappears
        updateStarsUI()
    }
    
    @IBAction func nextChapter(_ sender: UIButton){
        // If this is the final chapter in the section, launch the quiz instead of going to next chapter
        if nextChapter.isEmpty {
            for controller in self.navigationController!.viewControllers as Array {
                if controller.isKind(of: HomeViewController.self) {
                    self.navigationController!.popToViewController(controller, animated: true)
                    break
                }
            }
        } else {
            performSegue(withIdentifier: "SegueToChapterViewController", sender: nil)
        }
    }
    
    @IBAction func launchQuiz(_ sender: UIButton){
        performSegue(withIdentifier: "SegueToQuizIntroViewController", sender: nil)
    }
    
    @IBAction func backToChapterList(_ sender: UIButton){
        // Go back to the list view controller
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: HandbookViewController.self) {
                self.navigationController!.popToViewController(controller, animated: true)
                break
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let chapterViewController = segue.destination as? ChapterViewController {
            chapterViewController.contentIndex = contentIndex
            chapterViewController.contentURL = nextChapterURL
            chapterViewController.titleURL = nextChapter
        }
        if let quizViewController = segue.destination as? QuizIntroViewController {
            quizViewController.quizSubchapter = quizIndex
            quizViewController.quizChapter = contentIndex
            quizViewController.quizTitle = chapterEndTitle
        }
    }
}

// MARK: - Stars helpers
private extension ChapterEndViewController {
    func totalChaptersCount(for section: Int) -> Int {
        switch section {
        case 0: return ContentChapter().sectionOne.count
        case 1: return ContentChapter().sectionTwo.count
        case 2: return ContentChapter().sectionThree.count
        default: return 0
        }
    }
    
    func updateStarsUI() {
        // Compute totals based on the current section and the current chapter index
        let totalCount = totalChaptersCount(for: contentIndex)
        let completedCount = max(0, min(totalCount, quizIndex + 1))
        
        chaptersCompletedLabel.text = "\(completedCount) of \(totalCount) chapters completed"
        
        // Clear existing stars
        starsStackView.arrangedSubviews.forEach { sub in
            starsStackView.removeArrangedSubview(sub)
            sub.removeFromSuperview()
        }
        
        starsStackView.alignment = .center
        
        if totalCount == 5 {
            starsStackView.distribution = .fillEqually
            starsStackView.spacing = 8
            
            rightStarsStackConstraint.constant = 50
            leftStarsStackConstraint.constant = 50
        } else {
            starsStackView.spacing = 0
            starsStackView.distribution = .fillEqually
            rightStarsStackConstraint.constant = 100
            leftStarsStackConstraint.constant = 100
        }
        
        for i in 0..<totalCount {
            let isCompleted = i < completedCount
            let starView = makeStarImageView(completed: isCompleted)
            starsStackView.addArrangedSubview(starView)
        }
    }
    
    func makeStarImageView(completed: Bool) -> UIImageView {
        let assetName = completed ? "star_completed" : "star_uncompleted"
        let image = UIImage(named: assetName)?.withRenderingMode(.alwaysOriginal)
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 40),
            imageView.heightAnchor.constraint(equalToConstant: 40)
        ])
        return imageView
    }
}
