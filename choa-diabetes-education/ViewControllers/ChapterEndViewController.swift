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
        
        appearance.buttonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
        
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
            if let chapterEndTitleIndex = ContentChapter().sectionOne.firstIndex(where: {$0.contentTitle == chapterEndTitle}){
                if chapterEndTitleIndex < ContentChapter().sectionOne.count-1 {
                    nextChapter = ContentChapter().sectionOne[chapterEndTitleIndex+1].contentTitle
                    nextChapterURL = ContentChapter().sectionOne[chapterEndTitleIndex+1].contentHTML
                }
                quizIndex = chapterEndTitleIndex
            }
        case 1:
            if let chapterEndTitleIndex = ContentChapter().sectionTwo.firstIndex(where: {$0.contentTitle == chapterEndTitle}){
                if chapterEndTitleIndex < ContentChapter().sectionTwo.count-1 {
                    nextChapter = ContentChapter().sectionTwo[chapterEndTitleIndex+1].contentTitle
                    nextChapterURL = ContentChapter().sectionTwo[chapterEndTitleIndex+1].contentHTML
                }
                quizIndex = chapterEndTitleIndex
                //
                //                print(chapterEndTitleIndex)
                // Extra logic for section 2 with chapters that don't contain a quiz
                if chapterEndTitleIndex == 1 || chapterEndTitleIndex == 3 {
//                    quizLabel.isHidden = true
//                    quizButton.isHidden = true
                }
            }
        case 2:
            if let chapterEndTitleIndex = ContentChapter().sectionThree.firstIndex(where: {$0.contentTitle == chapterEndTitle}){
                if chapterEndTitleIndex < ContentChapter().sectionThree.count-1 {
                    nextChapter = ContentChapter().sectionThree[chapterEndTitleIndex+1].contentTitle
                    nextChapterURL = ContentChapter().sectionThree[chapterEndTitleIndex+1].contentHTML
                }
                quizIndex = chapterEndTitleIndex
            }
        default:
            print("error where index doesn't match")
        }
        
        // If there is no quiz assigned for this chapter hide the quiz related section
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        // Hide next button if the end of the section
        if nextChapter != "" {
//            nextChapterLabel.text = nextChapter
        } else {
//            nextChapterLabel.isHidden = true
            nextChapterButton.isHidden = true
        }
    }
    
    @IBAction func nextChapter(_ sender: UIButton){
        performSegue(withIdentifier: "SegueToChapterViewController", sender: nil)
    }
    
    @IBAction func launchQuiz(_ sender: UIButton){
        performSegue(withIdentifier: "SegueToQuizIntroViewController", sender: nil)
    }
    
    @IBAction func backToChapterList(_ sender: UIButton){
        // Go back to the list view controller
        // Some function of pop to view controller - https://stackoverflow.com/questions/30003814/how-can-i-pop-specific-view-controller-in-swift
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
