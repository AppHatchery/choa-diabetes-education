//
//  QuizIntroViewController.swift
//  choa-diabetes-education
//
//  Created by Yago Arconada on 8/25/22.
//

import UIKit
import CloudKit

class QuizIntroViewController: UIViewController {
    
    @IBOutlet weak var splashTitle: UILabel!
    @IBOutlet weak var congratsMessage: UILabel!
    @IBOutlet weak var splashChapter: UILabel!
    @IBOutlet weak var splashImage: UIImageView!
    @IBOutlet weak var quizDuration: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    
    var quizSubchapter = 0
    var quizChapter = 0
    var quizTitle = ""
    var quizQuestions = ""
    var beginQuiz = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if !beginQuiz {
            splashTitle.text = "Congrats".localized()
            congratsMessage.isHidden = false
            congratsMessage.text = "Result.Quiz.End".localized()
            splashChapter.isHidden = true
            quizDuration.isHidden = true
            nextButton.setTitle("Done".localized(), for: .normal)
            splashImage.image = UIImage(named: "quizEnd")
        } else {
            splashChapter.text = ContentChapter().sectionTitles[quizChapter]
            splashTitle.text = quizTitle
        }
    }
    
    // Need to assign this dynamically to the button in the view
    func doneButton() {
        // Pop all view controllers to HandBook Controller
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "quiz") as! HandbookViewController
        self.navigationController?.popToViewController(vc, animated: true)
    }
    
    @IBAction func nextButton(_ sender: UIButton){
        if beginQuiz {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyBoard.instantiateViewController(withIdentifier: "quiz") as! QuizQuestionsViewController
            vc.quizNumber = 0
            vc.quizSubchapter = quizSubchapter
            vc.quizChapter = quizChapter
            let navigationController = self.navigationController
            navigationController?.pushViewController(vc, animated: true)
        } else {
            if let viewController = navigationController?.viewControllers.first(where: {$0 is HandbookViewController}) {
                navigationController?.popToViewController(viewController, animated: true)
            }
        }
    }
}
