//
//  HandbookViewController.swift
//  choa-diabetes-education
//
//  Created by Yago Arconada on 8/4/22.
//

import UIKit

class HandbookViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var chapterTitle: UILabel!
    @IBOutlet weak var chapterSubtitle: UILabel!
    
    var chapterName = ""
    var chapterSubName = ""
    var chapterContent = 0
    var quizContent = 0
    var contentURL = ""
    var contentTitleURL = ""
    var quizURL = 0
    var quizChapter = 0

    override func viewDidLoad() {
        super.viewDidLoad()
                
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ChapterListTableViewCell", bundle: nil), forCellReuseIdentifier: "chapterCell")
        tableView.register(UINib(nibName: "QuizTableViewCell", bundle: nil), forCellReuseIdentifier: "quizCell")
        tableView.estimatedRowHeight = 100
        tableView.estimatedRowHeight = UITableView.automaticDimension
        
        chapterTitle.text = chapterName
        chapterSubtitle.text = chapterSubName
        
        // Do any additional setup after loading the view.
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segmentedControl.selectedSegmentIndex == 0 {
            // it's a chapter list
            return chapterContent
        } else {
            // it's a quiz list
            return quizContent
        }
    }
    
    private func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if segmentedControl.selectedSegmentIndex == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "chapterCell", for: indexPath) as! ChapterListTableViewCell
                        
            // In progress, when toggling there is a bug where some segments disappear, something to do with the indexpath
            if chapterName == ContentChapter().sectionTitles[0]{
                cell.cardTitle.text = ContentChapter().sectionOne[indexPath.row].contentTitle
            } else if chapterName == ContentChapter().sectionTitles[1]{
                cell.cardTitle.text = ContentChapter().sectionTwo[indexPath.row].contentTitle
            } else if chapterName == ContentChapter().sectionTitles[2]{
                cell.cardTitle.text = ContentChapter().sectionThree[indexPath.row].contentTitle
            }
            
            if indexPath.row == 0 {
                cell.topLineConnector.isHidden = true
            } else if indexPath.row == chapterContent-1 {
                cell.bottomLineConnector.isHidden = true
            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "quizCell", for: indexPath) as! QuizTableViewCell
            
            cell.quizNumber.text = "Quiz \(indexPath.row+1)"
            
            if indexPath.row == 0 {
                cell.topLineConnector.isHidden = true
            } else if indexPath.row == quizContent-1 {
                cell.bottomLineConnector.isHidden = true
            }
            
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let chapterIndex = ContentChapter().sectionTitles.firstIndex(of: chapterName){
            quizChapter = chapterIndex
            switch chapterIndex {
            case 0:
                contentURL = ContentChapter().sectionOne[indexPath.row].contentHTML
                contentTitleURL = ContentChapter().sectionOne[indexPath.row].contentTitle
            case 1:
                contentURL = ContentChapter().sectionTwo[indexPath.row].contentHTML
                contentTitleURL = ContentChapter().sectionTwo[indexPath.row].contentTitle
            case 2:
                contentURL = ContentChapter().sectionThree[indexPath.row].contentHTML
                contentTitleURL = ContentChapter().sectionThree[indexPath.row].contentTitle
            default:
                print("ChapterIndex doesn't exist")
            }
        }
        quizURL = indexPath.row
        
        if segmentedControl.selectedSegmentIndex == 0 {
            performSegue(withIdentifier: "SegueToContentViewController", sender: nil )
        } else {
            
            performSegue(withIdentifier: "SegueToQuizIntroViewController", sender: nil)
        }
        
    }
    
    @IBAction func toggleListView(_ sender: UISegmentedControl) {
        tableView.reloadData()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let chapterViewController = segue.destination as? ChapterViewController
        {
            chapterViewController.contentURL = contentURL
            chapterViewController.titleURL = contentTitleURL
            chapterViewController.contentIndex = quizChapter
        }
        if let quizViewController = segue.destination as? QuizIntroViewController
        {
            quizViewController.quizSubchapter = quizURL
            quizViewController.quizChapter = quizChapter
            quizViewController.quizTitle = contentTitleURL
        }
    }

}
