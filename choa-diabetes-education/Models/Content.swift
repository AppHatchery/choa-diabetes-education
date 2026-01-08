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
    var contentSubheader = ""
    var quizQuestions = [String]()
    var quizAnswers = [[String]]()
    var quizCorrectAnswer = [[Int]]()
}

class ContentChapter {
    // Populate with all the content
    let sectionTitles = ["Home.SectionOne.Subtitle".localized(),
                         "Home.SectionTwo.Subtitle".localized(),
                         "Home.SectionThree.Subtitle".localized()]
    let sectionSubtitles = ["Diabetes.Description".localized(), "NutritionAndCarbsCounting.Description".localized(), "DiabetesSelfManagement.Description".localized()]
    
    let sectionOne = [
        Content(contentTitle: "What is Diabetes?", contentParent: "Diabetes Basics", contentHTML: "basics_whatisdiabetes", contentSubheader: "Types of diabetes, signs and symptoms, and treatment", quizQuestions:["Diabetes is best described as:"], quizAnswers: [["The body’s lack of ability to produce insulin","Eating too much sugar","The body’s inability to regulate blood glucose with insulin resulting in high blood sugars"]], quizCorrectAnswer: [[0,2]]),
        Content(contentTitle: "Blood sugar monitoring", contentParent: "Diabetes Basics", contentHTML: "when_to_check_bg",contentSubheader: "When and how to check blood sugar", quizQuestions:["How often should BG be checked in Type 1 Diabetes?"], quizAnswers: [["Hourly","Every 5 minutes","Before meals, before bed, and before exercise","Fasting and 2 hours after largest meal"]],quizCorrectAnswer: [[2]]),
        Content(contentTitle: "Types of insulin", contentParent: "Diabetes Basics", contentHTML: "insulin", contentSubheader: "Types of insulin, storage, and where to give an injection", quizQuestions:["Long-acting insulin should be given:"], quizAnswers: [["Once a day","With every meal"," Weekly","Only at bedtime"]],quizCorrectAnswer: [[0]]),
        Content(contentTitle: "Insulin Administration", contentParent: "Diabetes Basics", contentHTML: "how_to_give_insulin_shot", contentSubheader: "Insulin injection technique and importance of site rotation", quizQuestions:["Insulin may be administered in each of the following areas: (check all that apply)"], quizAnswers: [["Stomach","Buttocks","Fingers","Legs"]],quizCorrectAnswer: [[0,1,3]]),
        Content(contentTitle: "Check for ketones", contentParent: "Diabetes Basics", contentHTML: "check_for_ketones", contentSubheader: "Symptoms of hyperglycemia, when and how to check for ketones", quizQuestions:["Ketones indicate:"], quizAnswers: [["BG is well managed","Diabetes is out of balance","BG is high","There is enough insulin to carry glucose (sugar) into cells"]],quizCorrectAnswer: [[1]]),
    ]
    
    let sectionTwo = [
        Content(contentTitle: "Types of food", contentParent: "Nutrition and Diabetes", contentHTML: "types_of_food", contentSubheader: "Carbs, fat, and protein and importance of each in diet", quizQuestions:["Examples of carbohydrates include:"], quizAnswers: [["Apples","Eggs","Seeds","Beans","Potatoes"]],quizCorrectAnswer: [[0,3,4]]),
        Content(contentTitle: "How to count carbohydrates", contentParent: "Nutrition and Diabetes", contentHTML: "how_to_count_carbs", contentSubheader: "Importance of accurate carb counting and how to count carbs: nutrition fact labels and food lists", quizQuestions:[""], quizAnswers: [[""]],quizCorrectAnswer: [[0]]),
        Content(contentTitle: "How to calculate insulin dosages", contentParent: "Nutrition and Diabetes", contentHTML: "how_to_calculate_insulin_dosing", contentSubheader: "Long and rapid acting insulin; ways to calculate insulin for food and for blood sugar", quizQuestions:["Rapid-acting insulin may be calculated using:"], quizAnswers: [["Insulin to carbohydrate ratio","Correction factor","Set dosing","Sliding scale"]],quizCorrectAnswer: [[0,1,2,3]]),
        Content(contentTitle: "Carb counting Apps", contentParent: "Nutrition and Diabetes", contentHTML: "cabs_counting_apps", contentSubheader: "Resources to help with carb counting on-the-go", quizQuestions:[""], quizAnswers: [[""]],quizCorrectAnswer: [[0]]),
    ]
    
    let sectionThree = [
        Content(contentTitle: "Treatment of low blood sugar", contentParent: "Diabetes Self-Management", contentHTML: "treatment_for_low_blood_sugar", contentSubheader: "Symptoms hypoglycemia, how to treat mild and severe low blood sugar, glucagon administration", quizQuestions:["How is routine hypoglycemia best treated?"], quizAnswers: [["Rapid acting carbohydrates","Complex carbohydrates","You should not eat carbs until BG resolved","Glucagon"]],quizCorrectAnswer: [[0]]),
        Content(contentTitle: "When to call diabetes doctor", contentParent: "Diabetes Self-Management", contentHTML: "when_to_call_diabetes_doctor", contentSubheader: "Sick day, missed insulin dose, ketones or other challenges", quizQuestions:["When should you call the doctor?"], quizAnswers: [["Daily","Ketones are small","Consistently high or low BG","When sick"]],quizCorrectAnswer: [[2,3]])
    ]
}
