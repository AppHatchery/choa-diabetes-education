//
//  ResourcesViewController.swift
//  choa-diabetes-education
//
//  Created by Yago Arconada on 9/13/22.
//

import UIKit

class ResourcesViewController: UIViewController {
    @IBOutlet weak var diabetesBasicsView: UIView!
    @IBOutlet weak var nutritionAndCarbCountingView: UIView!
    @IBOutlet weak var diabetesSelfManagementView: UIView!
        
    var chapterContent = 0
    var quizContent = 0
    var chapterName = ""
    var chapterSubName = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        diabetesBasicsView.layer.cornerRadius = 24
        nutritionAndCarbCountingView.layer.cornerRadius = 24
        diabetesSelfManagementView.layer.cornerRadius = 24
        
        addTapRecognizersToResourceCards()
    }
    
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
    
    private func addTapRecognizersToResourceCards() {
        // Ensure the views can receive touches
        diabetesBasicsView.isUserInteractionEnabled = true
        nutritionAndCarbCountingView.isUserInteractionEnabled = true
        diabetesSelfManagementView.isUserInteractionEnabled = true
        
        let basicsTap = UITapGestureRecognizer(target: self, action: #selector(didTapDiabetesBasicsCard))
        diabetesBasicsView.addGestureRecognizer(basicsTap)

        let nutritionTap = UITapGestureRecognizer(target: self, action: #selector(didTapNutritionCard))
        nutritionAndCarbCountingView.addGestureRecognizer(nutritionTap)

        let managementTap = UITapGestureRecognizer(target: self, action: #selector(didTapManagementCard))
        diabetesSelfManagementView.addGestureRecognizer(managementTap)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let handbookViewController = segue.destination as? HandbookViewController {
            handbookViewController.chapterName = chapterName
            handbookViewController.chapterSubName = chapterSubName
            handbookViewController.chapterContent = chapterContent
            handbookViewController.quizContent = quizContent
        }
    }
}
