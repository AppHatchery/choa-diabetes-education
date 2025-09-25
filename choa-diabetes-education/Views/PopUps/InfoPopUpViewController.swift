//
//  InfoPopUpViewController.swift
//  choa-diabetes-education
//
//  Created by Maxwell Kapezi Jr on 25/09/2025.
//

import UIKit

class InfoPopUpViewController: UIViewController {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var popupTitle: UILabel!
    @IBOutlet weak var popupDetails: UITextView!
    @IBOutlet weak var closeButton: PrimaryButton!
    
    var popupTitleText: String = ""
    var popupDetailsText: String = ""
    
    init() {
        super.init(nibName: "InfoPopUpViewController", bundle: nil)
        self.modalPresentationStyle = .overFullScreen
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        configView()
    }
    
    func configView() {
        self.view.backgroundColor = .clear
        self.backgroundView.backgroundColor = .black.withAlphaComponent(0.6)
        self.contentView.alpha = 0
        self.contentView.layer.cornerRadius = 12
    }
    
    func appear(sender: UIViewController, title: String, details: String) {
        
        self.popupTitleText = title
        self.popupDetailsText = details
        
        sender.present(self, animated: true) {
            self.show()
        }
    }
    
    private func show() {
        self.backgroundView.alpha = 1

        UIView.animate(withDuration: 0.1, delay: 0) {
            self.contentView.alpha = 1
            
            self.popupTitle.text = self.popupTitleText
            
            switch self.popupTitleText {
            case "PopupInfo.CorrectionFactor.title".localized():
                self.popupDetails.setText( self.popupDetailsText, boldPhrases: ["correction factor", "1 unit of insulin lowers blood glucose", "50 mg/dL","blood sugar", "200 mg/dL","target","100 mg/dL","(200-100) ÷ 50 = 2 units of insulin", "Example"])
            case "PopupInfo.CarbRatio.title".localized():
                self.popupDetails.setText( self.popupDetailsText, boldPhrases: ["amount of carbohydrates that one unit of insulin", "Example", "1 unit of insulin per 10 grams", "50 ÷ 10 = 5 units"])
            case "PopupInfo.TargetBloodSugar.title".localized():
                self.popupDetails.setText( self.popupDetailsText, boldPhrases: ["optimal blood glucose level", "Example"])
            case "PopupInfo.TotalCarbs.title".localized():
                self.popupDetails.setText( self.popupDetailsText, boldPhrases: ["amount of carbohydrates in a meal", "Example", "60 grams", "60 ÷ 15 = 4 units"])
            default:
                print("Unknown fruit")
            }
        }
    }
    
    func hide() {
        self.backgroundView.alpha = 0
        self.contentView.alpha = 0
        
//        UIView.animate(withDuration: 0.2, delay: 0) {
//            self.backgroundView.alpha = 0
//            self.contentView.alpha = 0
//        } completion: { _ in
//            self.dismiss(animated: true)
//            self.removeFromParent()
//        }
    }

    
    @IBAction func closeButtonTap(_ sender: Any) {
        hide()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
