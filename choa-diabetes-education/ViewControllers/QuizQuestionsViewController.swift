//
//  QuizQuestionsViewController.swift
//  choa-diabetes-education
//
//  Created by Yago Arconada on 8/25/22.
//

import UIKit

class QuizQuestionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var questionTitle: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var answerFeedback: UILabel!
    @IBOutlet weak var answerTitle: UILabel!
    @IBOutlet weak var answerIcon: UIImageView!
    @IBOutlet weak var answerButton: UIButton!
    @IBOutlet weak var multipleAnswerLabel: UILabel!
    @IBOutlet weak var quizWindowHeight: NSLayoutConstraint!
    
    var answerArray = [String]()
    var questionName = ""
    var answerFeedbackText = ""
    var correctAnswer = [Int]()
    var quizNumber = 0
    var quizChapter = 0
    var quizSubchapter = 0
    
    var userAnswerArray = [Int]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "QuizAnswerTableViewCell", bundle: nil), forCellReuseIdentifier: "answerCell")
        tableView.estimatedRowHeight = 120
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.selectionFollowsFocus = false
        
        answerButton.dropShadow()
        
        // How does the app know which section the user is on??
        
        // Need a system to regulate the section and then this is done!
        switch quizChapter {
        case 0:
            questionName = ContentChapter().sectionOne[quizSubchapter].quizQuestions[quizNumber]
            answerArray = ContentChapter().sectionOne[quizSubchapter].quizAnswers[quizNumber]
            correctAnswer = ContentChapter().sectionOne[quizSubchapter].quizCorrectAnswer[quizNumber]
        case 1:
            questionName = ContentChapter().sectionTwo[quizSubchapter].quizQuestions[quizNumber]
            answerArray = ContentChapter().sectionTwo[quizSubchapter].quizAnswers[quizNumber]
            correctAnswer = ContentChapter().sectionTwo[quizSubchapter].quizCorrectAnswer[quizNumber]
        case 2:
            questionName = ContentChapter().sectionThree[quizSubchapter].quizQuestions[quizNumber]
            answerArray = ContentChapter().sectionThree[quizSubchapter].quizAnswers[quizNumber]
            correctAnswer = ContentChapter().sectionThree[quizSubchapter].quizCorrectAnswer[quizNumber]
        default:
            //
            print("Case didn't find an answer")
        }
        
        questionTitle.text = questionName
        
        if correctAnswer.count > 1 {
            multipleAnswerLabel.isHidden = false
            tableView.allowsMultipleSelection = true
        } else {
            tableView.allowsMultipleSelection = false
        }
        
        // If there are more than 4 answers you have to increase the view size
        if answerArray.count > 4 {
            quizWindowHeight.constant += 60
            tableView.isScrollEnabled = true
        }
        
//        if (quizNumber == ContentChapter().sectionOne[0].quizQuestions.count-1){
//            nextButton.setTitle("Done", for: .normal)
//        }

        // Do any additional setup after loading the view.
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return answerArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "answerCell", for: indexPath) as! QuizAnswerTableViewCell
                    
        cell.layer.cornerRadius = 10
        cell.answerLabel.text = answerArray[indexPath.row]
        
        return cell
    }
    
    // This will likely change to be button actionable
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! QuizAnswerTableViewCell
        
        cell.setSelected(true, animated: true)
        
        // Do we need to check if clicked multiple times?
        if !userAnswerArray.contains(indexPath.row){
            userAnswerArray.append(indexPath.row)
        }
        
        print(userAnswerArray)
    }
    
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! QuizAnswerTableViewCell
        
        // This won't be useful because we want all rows selected
        cell.setSelected(false, animated: true)
        
        // This should only fire one time
        if let answerValue = userAnswerArray.firstIndex(of: indexPath.row){
            userAnswerArray.remove(at: answerValue)
        }        
    }
    
    private func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    @IBAction func checkIfAnswersCorrect(_ sender: UIButton){
        
        // Check if options are correct
        let orderedArray = userAnswerArray.sorted()
        
        if answerButton.titleLabel?.text == "Submit" {
            // Check to ensure user has selected an answer in the quiz and avoid a crash
            if userAnswerArray.count > 0 {
                var answerString = ""
                orderedArray.forEach { answerString += "\($0+1), "}
                answerString.removeLast(2)
                
                if orderedArray == correctAnswer {
                    answerFeedback.isHidden = false
                    
                    answerTitle.text = "Answer \(answerString)"
                    answerIcon.image = UIImage(named: "correctIcon")
                    answerButton.setTitle("Done", for: .normal)
                } else {
                    answerFeedback.isHidden = true
                    answerIcon.image = UIImage(named: "incorrectIcon")
                    answerTitle.text = "Answer \(answerString) is not right. Please choose again"
                }
                
                answerTitle.isHidden = false
                answerIcon.isHidden = false
            }
        } else {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyBoard.instantiateViewController(withIdentifier: "quizSplash") as! QuizIntroViewController
            
            vc.beginQuiz = false

            let navigationController = self.navigationController

            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func nextQuestion(_ sender: UIButton){
        
        // Check here if the user is done with the quiz
        if (quizNumber == ContentChapter().sectionOne[0].quizQuestions.count-1){
            // Go to end Quiz
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyBoard.instantiateViewController(withIdentifier: "quizSplash") as! QuizIntroViewController
            
            vc.beginQuiz = false

            let navigationController = self.navigationController

            navigationController?.pushViewController(vc, animated: true)
        } else {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyBoard.instantiateViewController(withIdentifier: "quiz") as! QuizQuestionsViewController
            
            vc.quizNumber += 1

            let navigationController = self.navigationController

            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
