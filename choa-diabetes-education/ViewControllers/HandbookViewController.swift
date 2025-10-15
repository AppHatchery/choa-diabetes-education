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
    @IBOutlet weak var sectionImage: UIImageView!
    
    var chapterName = ""
    var chapterSubName = ""
    var chapterContent = 0
    var quizContent = 0
    var contentURL = ""
    var contentTitleURL = ""
    var quizURL = 0
    var quizChapter = 0
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.shadowColor = UIColor.clear
        
        if chapterName == "Home.SectionOne.Subtitle".localized() {
            appearance.backgroundColor = .diabetesBasicsColor
        } else if chapterName == "Home.SectionTwo.Subtitle".localized() {
            appearance.backgroundColor = .nutritionAndCarbColor
            view.backgroundColor = .nutritionAndCarbColor
            sectionImage.image = UIImage(named: "will_nutrition")
        } else {
            appearance.backgroundColor = .diabetesSelfManagementColor
            view.backgroundColor = .diabetesSelfManagementColor
            sectionImage.image = UIImage(named: "hope_clock")
        }
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = UIColor.white
        
        navigationItem.backButtonDisplayMode = .minimal
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        segmentedControl.isHidden = true
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ChapterListTableViewCell", bundle: nil), forCellReuseIdentifier: "chapterCell")
        tableView.register(UINib(nibName: "QuizTableViewCell", bundle: nil), forCellReuseIdentifier: "quizCell")
        tableView.estimatedRowHeight = 100
        tableView.estimatedRowHeight = UITableView.automaticDimension
        
        chapterTitle.text = chapterName
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.shadowColor = UIColor.clear
        
        appearance.backgroundColor = .white
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = UIColor.black
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
            if chapterName == ContentChapter().sectionTitles[0] {
                cell.cardTitle.text = ContentChapter().sectionOne[indexPath.row].contentTitle
                cell.cardSubtitle.text = ContentChapter().sectionOne[indexPath.row].contentSubheader
                
                let imageNames = [
                    "basics_will_what_is_diabetes",
                    "basics_hope_diabetes_check",
                    "basics_types_of_insulin",
                    "basics_insulin_admin",
                    "basics_check_for_ketones"
                ]
                
                if indexPath.row < imageNames.count {
                    cell.cardImage.image = UIImage(named: imageNames[indexPath.row])
                } else {
                    cell.cardImage.image = nil
                }
                
            } else if chapterName == ContentChapter().sectionTitles[1] {
                cell.cardTitle.text = ContentChapter().sectionTwo[indexPath.row].contentTitle
                cell.cardSubtitle.text = ContentChapter().sectionTwo[indexPath.row].contentSubheader
                
                let imageNames = [
                    "nutritional_food_groups",
                    "nutrition_count",
                    "nutrition_dosages"
                ]
                
                if indexPath.row < imageNames.count {
                    cell.cardImage.image = UIImage(named: imageNames[indexPath.row])
                } else {
                    cell.cardImage.image = nil
                }
            } else if chapterName == ContentChapter().sectionTitles[2] {
                cell.cardTitle.text = ContentChapter().sectionThree[indexPath.row].contentTitle
                cell.cardSubtitle.text = ContentChapter().sectionThree[indexPath.row].contentSubheader
                
                let imageNames = [
                    "diabetes_treatment",
                    "diabetes_doctor",
                ]
                
                if indexPath.row < imageNames.count {
                    cell.cardImage.image = UIImage(named: imageNames[indexPath.row])
                } else {
                    cell.cardImage.image = nil
                }
            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "quizCell", for: indexPath) as! QuizTableViewCell
            
            cell.quizNumber.text = "Quiz \(indexPath.row+1)"
            
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
                quizURL = indexPath.row
            case 1:
                // This extra logic only pertains to the second section because the two of the quizzes are empty
                if segmentedControl.selectedSegmentIndex == 0 {
                    contentURL = ContentChapter().sectionTwo[indexPath.row].contentHTML
                    contentTitleURL = ContentChapter().sectionTwo[indexPath.row].contentTitle
                    quizURL = indexPath.row
                } else {
                    contentURL = ContentChapter().sectionTwo.filter({$0.quizQuestions != [""] })[indexPath.row].contentHTML
                    contentTitleURL = ContentChapter().sectionTwo.filter({$0.quizQuestions != [""] })[indexPath.row].contentTitle
                    // Hacky way to get this working for the missing quizzes, to be refactored in after release
                    if indexPath.row > 0 {
                        quizURL = 2
                    } else {
                        quizURL = 0
                    }
                }
            case 2:
                contentURL = ContentChapter().sectionThree[indexPath.row].contentHTML
                contentTitleURL = ContentChapter().sectionThree[indexPath.row].contentTitle
                quizURL = indexPath.row
            default:
                print("ChapterIndex doesn't exist")
            }
        }
        //        quizURL = indexPath.row
        
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
        if let chapterViewController = segue.destination as? ChapterViewController {
            chapterViewController.contentURL = contentURL
            chapterViewController.titleURL = contentTitleURL
            chapterViewController.contentIndex = quizChapter
        }
        if let quizViewController = segue.destination as? QuizIntroViewController {
            quizViewController.quizSubchapter = quizURL
            quizViewController.quizChapter = quizChapter
            quizViewController.quizTitle = contentTitleURL
        }
    }
}
