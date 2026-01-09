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
        Content(contentTitle: "What is Diabetes?", contentParent: "Diabetes Basics", contentHTML: "1_1_1_whatisdiabetes", contentSubheader: "Types, causes, and symptoms of diabetes", quizQuestions:["Diabetes is best described as:"], quizAnswers: [["The body’s lack of ability to produce insulin","Eating too much sugar","The body’s inability to regulate blood glucose with insulin resulting in high blood sugars"]], quizCorrectAnswer: [[0,2]]),
        Content(contentTitle: "Blood Sugar Checks", contentParent: "Diabetes Basics", contentHTML: "1_2_1_when_to_check_bg",contentSubheader: "Key times to check blood sugar and how to do it properly.", quizQuestions:["How often should BG be checked in Type 1 Diabetes?"], quizAnswers: [["Hourly","Every 5 minutes","Before meals, before bed, and before exercise","Fasting and 2 hours after largest meal"]],quizCorrectAnswer: [[2]]),
        Content(contentTitle: "Types of Insulin", contentParent: "Diabetes Basics", contentHTML: "1_3_1_types_of_insulin", contentSubheader: "Insulin types, storage guidelines, and proper injection sites.", quizQuestions:["Long-acting insulin should be given:"], quizAnswers: [["Once a day","With every meal"," Weekly","Only at bedtime"]],quizCorrectAnswer: [[0]]),
        Content(contentTitle: "Insulin Administration", contentParent: "Diabetes Basics", contentHTML: "1_4_1_with_pen", contentSubheader: "Steps for insulin pen, syringe, and site rotation.", quizQuestions:["Insulin may be administered in each of the following areas: (check all that apply)"], quizAnswers: [["Stomach","Buttocks","Fingers","Legs"]],quizCorrectAnswer: [[0,1,3]]),
        Content(contentTitle: "Check for Ketones", contentParent: "Diabetes Basics", contentHTML: "1_5_1_managing_ketones", contentSubheader: "Symptoms, testing times, and steps to check ketones.", quizQuestions:["Ketones indicate:"], quizAnswers: [["BG is well managed","Diabetes is out of balance","BG is high","There is enough insulin to carry glucose (sugar) into cells"]],quizCorrectAnswer: [[1]]),
    ]
    
    let sectionTwo = [
        Content(contentTitle: "Nutritional Food Groups", contentParent: "Nutrition and Diabetes", contentHTML: "2_1_1_nutritonal_food_groups", contentSubheader: "Carbohydrates, fats, and proteins and their effects on blood sugar.", quizQuestions:["Examples of carbohydrates include:"], quizAnswers: [["Apples","Eggs","Seeds","Beans","Potatoes"]],quizCorrectAnswer: [[0,3,4]]),
        Content(contentTitle: "How to Count Carbohydrates", contentParent: "Nutrition and Diabetes", contentHTML: "2_2_1_how_to_count_carbs", contentSubheader: "Methods for counting carbs using food lists and nutrition labels.", quizQuestions:[""], quizAnswers: [[""]],quizCorrectAnswer: [[0]]),
        Content(contentTitle: "How to Calculate Insulin Dosages", contentParent: "Nutrition and Diabetes", contentHTML: "2_3_1_how_to_calculate_insulin_dosages", contentSubheader: "Long-acting doses and rapid-acting for meals and highs.", quizQuestions:["Rapid-acting insulin may be calculated using:"], quizAnswers: [["Insulin to carbohydrate ratio","Correction factor","Set dosing","Sliding scale"]],quizCorrectAnswer: [[0,1,2,3]]),
    ]
    
    let sectionThree = [
        Content(contentTitle: "Managing Low Blood Sugar", contentParent: "Diabetes Self-Management", contentHTML: "3_1_1_managing_low_blood_sugar", contentSubheader: "Symptoms, step-by-step treatment, and glucagon use.", quizQuestions:["How is routine hypoglycemia best treated?"], quizAnswers: [["Rapid acting carbohydrates","Complex carbohydrates","You should not eat carbs until BG resolved","Glucagon"]],quizCorrectAnswer: [[0]]),
        Content(contentTitle: "When to Call the Doctor", contentParent: "Diabetes Self-Management", contentHTML: "3_2_1_when_to_call_a_doctor", contentSubheader: "Situations for urgent or routine doctor contact.", quizQuestions:["When should you call the doctor?"], quizAnswers: [["Daily","Ketones are small","Consistently high or low BG","When sick"]],quizCorrectAnswer: [[2,3]])
    ]
}
