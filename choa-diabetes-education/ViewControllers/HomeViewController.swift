//
//  HomeViewController.swift
//  choa-diabetes-education
//
//  Created by Yago Arconada on 8/16/22.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet var contentButtons: [UIButton]!
    @IBOutlet weak var orientationView: UIView!
    
    var chapterContent = 0
    var quizContent = 0
    var chapterName = ""
    var chapterSubName = ""
    
    let halloweenMessage = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        for contentBut in contentButtons {
            contentBut.dropShadow()
        }
        orientationView.dropShadow()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let orientationViewController = segue.destination as? OrientationViewController
        {
            // since we now know the contentView frame, pass it down so that the next controller will know it before viewDidAppear
            orientationViewController.contentFrame =
            self.view.bounds
            print(self.view.safeAreaInsets)
        }
        if let handbookViewController = segue.destination as? HandbookViewController
        {
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
            quizContent = ContentChapter().sectionTwo.count
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
