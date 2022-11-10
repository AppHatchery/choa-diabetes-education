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
    
    
        var y = 32
        
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
        contentTitle = "Food Diary"
        loadResource()
    }
    func loadKnowYourCarbsButton(){
        contentURL = "know_your_carbs"
        contentTitle = "Food Diary"
        loadResource()
    }
    func loadFoodsRaiseBloodSugarButton(){
        contentURL = "foods_that_raise_blood_sugar"
        contentTitle = "Food Diary"
        loadResource()
    }
    func loadFoodsDontRaiseBloodSugarButton(){
        contentURL = "foods_that_don't_raise_blood_sugar"
        contentTitle = "Food Diary"
        loadResource()
    }
    func loadAppsList(){
        contentURL = "apps-list"
        contentTitle = "Food Diary"
        loadResource()
    }
}
