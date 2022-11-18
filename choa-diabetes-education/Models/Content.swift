//
//  Content.swift
//  choa-diabetes-education
//
//  Created by Yago Arconada on 8/17/22.
//

import Foundation

struct Content {
    var contentTitle = ""
    var contentParent = ""
    var contentHTML = ""
    var quizQuestions = [String]()
    var quizAnswers = [[String]]()
    var quizCorrectAnswer = [[Int]]()
}

class ContentChapter {
    // Populate with all the content
    let sectionTitles = ["Diabetes Basics","Nutrition and Diabetes","Diabetes Self-Management"]
    let sectionSubtitles = ["A focus on diabetes and skills.","lorem ipsum","lorem ipsum"]
    
    let sectionOne = [
        Content(contentTitle: "What is Diabetes?", contentParent: "Diabetes Basics", contentHTML: "whatisdiabetes", quizQuestions:["Diabetes is best described as:"], quizAnswers: [["The body’s lack of insulin-producing beta cells","The body’s inability to regulate blood glucose with proper amounts of insulin","The body’s rejection of insulin by the pancreas","The body’s insulin response to carbohydrates"]],quizCorrectAnswer: [[0,1]]),
        Content(contentTitle: "Blood sugar monitoring", contentParent: "Diabetes Basics", contentHTML: "blood_sugar_monitoring", quizQuestions:["How often should BG be checked in Type 1 Diabetes?"], quizAnswers: [["Hourly","Every 5 minutes","Before meals, before bed, and before exercise","Fasting and 2 hours after largest meal"]],quizCorrectAnswer: [[2]]),
        Content(contentTitle: "Types of insulin", contentParent: "Diabetes Basics", contentHTML: "insulin", quizQuestions:["Long-acting insulin should be given:"], quizAnswers: [["1-2 times daily","With every meal"," Weekly","Only at bedtime"]],quizCorrectAnswer: [[0]]),
        Content(contentTitle: "How to calculate insulin dosing", contentParent: "Diabetes Basics", contentHTML: "how_to_calculate_insulin_dosing", quizQuestions:["Rapid-acting insulin may be calculated using:"], quizAnswers: [["Insulin to carbohydrate ratio","Correction factor","Set dosing","Sliding scale"]],quizCorrectAnswer: [[0,1,2,3]]),
        Content(contentTitle: "How to give insulin shot", contentParent: "Diabetes Basics", contentHTML: "how_to_give_insulin_shot", quizQuestions:["Insulin may be given via: (check all that apply)"], quizAnswers: [["Intramuscular injection","Subcutaneous injection","Insulin pump","Central line"]],quizCorrectAnswer: [[1,2]]),
    ]

    let sectionTwo = [
        Content(contentTitle: "Types of food", contentParent: "Nutrition and Diabetes", contentHTML: "types_of_food", quizQuestions:["Examples of carbohydrates include:"], quizAnswers: [["Apples","Eggs","Seeds","Beans","Potatoes"]],quizCorrectAnswer: [[0,3,4]]),
        Content(contentTitle: "How to count carbs", contentParent: "Nutrition and Diabetes", contentHTML: "how_to_count_carbs", quizQuestions:["Placeholder Question"], quizAnswers: [["placeholder Answer"]],quizCorrectAnswer: [[0]]),
        Content(contentTitle: "Carb counting Apps", contentParent: "Nutrition and Diabetes", contentHTML: "cabs_counting_apps", quizQuestions:["Placeholder Question"], quizAnswers: [["Placeholder Answer"]],quizCorrectAnswer: [[0]]),
    ]

    let sectionThree = [
        Content(contentTitle: "Check for ketones", contentParent: "Diabetes Self-Management", contentHTML: "check_for_ketones", quizQuestions:["Ketones indicate:"], quizAnswers: [["BG is well managed","Diabetes is out of balance","BG is high","There is enough insulin to carry glucose (sugar) into cells"]],quizCorrectAnswer: [[1]]),
        Content(contentTitle: "Treatment of low blood sugar", contentParent: "Diabetes Self-Management", contentHTML: "treatment_for_low_blood_sugar", quizQuestions:["How is routine hypoglycemia best treated?"], quizAnswers: [["Rapid acting carbohydrates","Complex carbohydrates","You should not eat carbs until BG resolved","Glucagon"]],quizCorrectAnswer: [[0]]),
        Content(contentTitle: "When to call diabetes doctor", contentParent: "Diabetes Self-Management", contentHTML: "when_to_call_diabetes_doctor", quizQuestions:["When should you call the doctor?"], quizAnswers: [["Daily","Ketones are small","Consistently high or low BG","When sick"]],quizCorrectAnswer: [[2,3]])
    ]
}
