//
//  ChapterEndViewController.swift
//  choa-diabetes-education
//
//  Created by Yago Arconada on 8/31/22.
//

import UIKit

class ChapterEndViewController: UIViewController {
    
    @IBOutlet weak var nextChapterLabel: UILabel!
    @IBOutlet weak var nextChapterButton: UIButton!
    @IBOutlet weak var quizLabel: UILabel!
    @IBOutlet weak var quizButton: UIView!
    
    var contentIndex = 0
    var chapterEndTitle = ""
    var nextChapter = ""
    var nextChapterURL = ""
    var quizIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        nextChapterButton.detailedDropShadow(color: UIColor(red: 232/255, green: 248/255, blue: 239/255, alpha: 1).cgColor, blur: 16, offset: 8,opacity: 1)
        
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
                if chapterEndTitleIndex != 0 {
                    quizLabel.isHidden = true
                    quizButton.isHidden = true
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
            nextChapterLabel.text = nextChapter
        } else {
            nextChapterLabel.isHidden = true
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
        if let chapterViewController = segue.destination as? ChapterViewController
        {
            chapterViewController.contentIndex = contentIndex
            chapterViewController.contentURL = nextChapterURL
            chapterViewController.titleURL = nextChapter
        }
        if let quizViewController = segue.destination as? QuizIntroViewController
        {
            quizViewController.quizSubchapter = quizIndex
            quizViewController.quizChapter = contentIndex
            quizViewController.quizTitle = chapterEndTitle
        }
    }
}
