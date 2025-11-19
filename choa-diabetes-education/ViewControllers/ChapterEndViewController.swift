//
//  ChapterEndViewController.swift
//  choa-diabetes-education
//
//  Created by Yago Arconada on 8/31/22.
//

import UIKit

class ChapterEndViewController: UIViewController {
    
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var nextChapterButton: UIButton!
    @IBOutlet weak var congratsLabel: UILabel!
    
    @IBOutlet weak var textBubbleImage: UIImageView!
    @IBOutlet weak var hopeOrWillImage: UIImageView!
    
    @IBOutlet weak var bottomStarsView: UIView!
    @IBOutlet weak var starsStackView: UIStackView!
    
    @IBOutlet weak var chaptersCompletedLabel: UILabel!
    
    
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
        
        if contentIndex == 0 {
            appearance.backgroundColor = .diabetesBasicsColor
            mainView.backgroundColor = .diabetesBasicsColor
        } else if contentIndex == 1 {
            appearance.backgroundColor = .nutritionAndCarbColor
            mainView.backgroundColor = .nutritionAndCarbColor
            hopeOrWillImage.image = UIImage(named: "will_nutrition")
        } else {
            appearance.backgroundColor = .diabetesSelfManagementColor
            mainView.backgroundColor = .diabetesSelfManagementColor
            hopeOrWillImage.image = UIImage(named: "hope_clock")
        }
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = UIColor.white
        
        navigationItem.backButtonDisplayMode = .minimal
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        congratsLabel.text = "Congrats".localized()
        
        bottomStarsView.layer.cornerRadius = 12
        nextChapterButton.layer.cornerRadius = 12
        
        switch contentIndex {
        case 0:
            if let chapterEndTitleIndex = ContentChapter().sectionOne.firstIndex(where: { $0.contentTitle == chapterEndTitle }) {
                if chapterEndTitleIndex < ContentChapter().sectionOne.count - 1 {
                    nextChapter = ContentChapter().sectionOne[chapterEndTitleIndex + 1].contentTitle
                    nextChapterURL = ContentChapter().sectionOne[chapterEndTitleIndex + 1].contentHTML
                }
                quizIndex = chapterEndTitleIndex
            }
        case 1:
            if let chapterEndTitleIndex = ContentChapter().sectionTwo.firstIndex(where: { $0.contentTitle == chapterEndTitle }) {
                if chapterEndTitleIndex < ContentChapter().sectionTwo.count - 1 {
                    nextChapter = ContentChapter().sectionTwo[chapterEndTitleIndex + 1].contentTitle
                    nextChapterURL = ContentChapter().sectionTwo[chapterEndTitleIndex + 1].contentHTML
                }
                quizIndex = chapterEndTitleIndex
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
            }
        default:
            print("error where index doesn't match")
        }
        
        updateStarsUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        // Hide next button if the end of the section
        if nextChapter != "" {
            // nextChapterLabel.text = nextChapter
        } else {
            // nextChapterLabel.isHidden = true
            nextChapterButton.isHidden = true
        }
        
        // Refresh stars in case the view reappears
        updateStarsUI()
    }
    
    @IBAction func nextChapter(_ sender: UIButton){
        performSegue(withIdentifier: "SegueToChapterViewController", sender: nil)
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
        
        chaptersCompletedLabel.text = "\(completedCount) of \(totalCount) completed"
        
        // Clear existing stars
        starsStackView.arrangedSubviews.forEach { sub in
            starsStackView.removeArrangedSubview(sub)
            sub.removeFromSuperview()
        }
        
        starsStackView.alignment = .center
        starsStackView.distribution = .equalSpacing
        starsStackView.spacing = 8
        
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
