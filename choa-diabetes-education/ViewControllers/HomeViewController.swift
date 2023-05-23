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
    @IBOutlet weak var orientationButton: UIButton!
    @IBOutlet weak var orientationTitleLabel: UILabel!
    @IBOutlet weak var orientationSubTitleLabel: UILabel!
    
    @IBOutlet weak var firstDayLabel: UILabel!
    @IBOutlet weak var secondDayLabel: UILabel!
    
    var chapterContent = 0
    var quizContent = 0
    var chapterName = ""
    var chapterSubName = ""
    
    let halloweenMessage = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        orientationTitleLabel.text = "Home.Orientation.Title".localized()
        orientationSubTitleLabel.text = "Home.Orientation.Subtitle".localized()
        
        let subtitleFont =  UIFont.gothamRoundedBold
        let titleFont =  UIFont.avenirLight
        
        let diabetesBasicsButtonTitle = NSAttributedString(string: "Home.SectionOne.Title".localized(), attributes: [NSAttributedString.Key.font: titleFont])
        let nutritionButtonTitle = NSAttributedString(string: "Home.SectionTwo.Title".localized(), attributes: [NSAttributedString.Key.font: titleFont])
        let managementButtonTitle = NSAttributedString(string: "Home.SectionThree.Title".localized(), attributes: [NSAttributedString.Key.font: titleFont])
        
        diabetesBasicsButton.setAttributedTitle(diabetesBasicsButtonTitle, for: .normal)
        nutritionButton.setAttributedTitle(nutritionButtonTitle, for: .normal)
        managementButton.setAttributedTitle(managementButtonTitle, for: .normal)
        
        var resultSectionOne = AttributedString("Home.SectionOne.Subtitle".localized())
        resultSectionOne.font = subtitleFont
        diabetesBasicsButton.configuration?.attributedSubtitle = resultSectionOne
        
        var resultSectionTwo = AttributedString("Home.SectionTwo.Subtitle".localized())
        resultSectionTwo.font = subtitleFont
        nutritionButton.configuration?.attributedSubtitle = resultSectionTwo
        
        var resultSectionThree = AttributedString("Home.SectionThree.Subtitle".localized())
        resultSectionThree.font = subtitleFont
        managementButton.configuration?.attributedSubtitle = resultSectionThree
        
        diabetesBasicsButton.detailedDropShadow(color: UIColor.diabetesBasicsDropShadowColor.cgColor, blur: 24.0, offset: 12, opacity: 1)
        nutritionButton.detailedDropShadow(color: UIColor.nutritionDropShadowColor.cgColor, blur: 24.0, offset: 12, opacity: 1)
        managementButton.detailedDropShadow(color: UIColor.managementDropShadowColor.cgColor, blur: 24.0, offset: 12, opacity: 1)
        orientationView.detailedDropShadow(color: UIColor.orientationViewDropShadowColor.cgColor, blur: 12.0, offset: 8, opacity: 0.62)
        orientationButton.detailedDropShadow(color:  UIColor.orientationButtonDropShadowColor.cgColor, blur: 12, offset: 6, opacity: 0.59)
        firstDayLabel.text = "Home.FirstDay.Title".localized()
        secondDayLabel.text = "Home.SecondDay.Title".localized()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let orientationViewController = segue.destination as? OrientationViewController {
            // since we now know the contentView frame, pass it down so that the next controller will know it before viewDidAppear
            orientationViewController.contentFrame =
            self.view.bounds
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
}
