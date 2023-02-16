//
//  ResourcesViewController.swift
//  choa-diabetes-education
//
//  Created by Yago Arconada on 9/13/22.
//

import UIKit

class ResourcesViewController: UIViewController, FoodDiaryDelegate {
    
    @IBOutlet weak var contentView: UIView!
    
    var scrollView: UIScrollView!
    var contentFrame: CGRect!
    var contentURL = ""
    var contentTitle = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        updateView()
    }
    
    func updateView()
    {
        if scrollView != nil {
            scrollView.removeFromSuperview()
        }
        
        contentFrame = self.view.bounds
        
        scrollView = UIScrollView(frame: contentFrame)
        contentView.addSubview(scrollView)
    
    
        var y = 0
        
        let recommendedAppsView = AppsView(frame: CGRect(x: 20, y: y, width: Int(contentFrame.width)-40, height: 295))
        scrollView.addSubview(recommendedAppsView)
        y += 295
        
        y += 30
        
        let foodDiaryView = FoodDiary(frame: CGRect(x: 0, y: y, width: Int(contentFrame.width), height: 420), delegate: self)
        scrollView.addSubview(foodDiaryView)
        y += 420
        
        let communitiesView = Communities(frame: CGRect(x: 0, y: y, width: Int(contentFrame.width), height: 870))
        scrollView.addSubview(communitiesView)
        y += 900
        
        scrollView.contentSize = CGSize(width: Int(scrollView.frame.width), height: y)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let resourceDetailViewController = segue.destination as? ChapterViewController
        {
            resourceDetailViewController.contentURL = contentURL
            resourceDetailViewController.titleURL = contentTitle
        }
    }
    
    func loadResource() {
        // load relevant resource
        performSegue(withIdentifier: "SegueToDetailResourceViewController", sender: nil )
    }
    
    func loadLowCarbsButton(){
        contentURL = "low_carb_snack_combinations"
        contentTitle = "What can I eat?"
        loadResource()
    }
    func loadKnowYourCarbsButton(){
        contentURL = "know_your_carbs"
        contentTitle = "What can I eat?"
        loadResource()
    }
    func loadFoodsRaiseBloodSugarButton(){
        contentURL = "foods_that_raise_blood_sugar"
        contentTitle = "What can I eat?"
        loadResource()
    }
    func loadFoodsDontRaiseBloodSugarButton(){
        contentURL = "foods_that_don't_raise_blood_sugar"
        contentTitle = "What can I eat?"
        loadResource()
    }
    
    @IBAction func openapps(_ sender: UIButton){
        var appURL:URL!
        switch sender.tag {
        case 0:
            //
            appURL = URL(string: "https://apps.apple.com/us/app/mysugr-diabetes-tracker-log/id516509211")
        case 1:
            //
            appURL = URL(string: "https://apps.apple.com/us/app/calorieking-food-search/id454930992")
        case 2:
            //
            appURL = URL(string: "https://apps.apple.com/us/app/myfitnesspal-calorie-counter/id341232718")
        default:
        // Error
            print("there was an error loading the url")
        }
        UIApplication.shared.open(appURL!)
    }
}
