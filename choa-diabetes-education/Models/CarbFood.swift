//
//  CarbFood.swift
//  choa-diabetes-education
//
//  Created by Maxwell Kapezi Jr on 26/08/2026.
//

import Foundation

struct CarbFood {
    let name: String
    let servingSize: String
    let carbGrams: Int
    let imageName: String
    /// User-created items are deletable and share a single icon.
    var isCustom: Bool = false
}

struct CarbCategory {
    let title: String
    let foods: [CarbFood]
}

enum KnowYourCarbsData {
    static let categories: [CarbCategory] = [
        CarbCategory(title: "Grains", foods: [
            CarbFood(name: "Bread", servingSize: "per slice", carbGrams: 15, imageName: "im_white_bread"),
            CarbFood(name: "Bagel", servingSize: "1/2 piece", carbGrams: 30, imageName: "im_bagel"),
            CarbFood(name: "Hamburger / Hot Dog Bun", servingSize: "per bun", carbGrams: 30, imageName: "im_bread_roll"),
            CarbFood(name: "English Muffin", servingSize: "per muffin", carbGrams: 30, imageName: "im_english_muffin"),
            CarbFood(name: "Tortilla (6\")", servingSize: "per tortilla", carbGrams: 15, imageName: "im_tortilla"),
            CarbFood(name: "Corn Bread", servingSize: "per 4\" cube", carbGrams: 30, imageName: "im_cornbread"),
            CarbFood(name: "Pancake", servingSize: "per 4\" pancake", carbGrams: 15, imageName: "im_pancake"),
            CarbFood(name: "Oatmeal / Grits", servingSize: "1 cup | cooked", carbGrams: 30, imageName: "im_oatmeal"),
            CarbFood(name: "Unsweetened Cereal", servingSize: "3/4 cup", carbGrams: 15, imageName: "im_cheerios"),
            CarbFood(name: "Sweetened Cereal", servingSize: "1 cup", carbGrams: 30, imageName: "im_fruit_loops"),
            CarbFood(name: "Pasta", servingSize: "1 cup | cooked", carbGrams: 45, imageName: "im_penne_pasta"),
            CarbFood(name: "Rice", servingSize: "1 cup | cooked", carbGrams: 45, imageName: "im_white_rice"),
            CarbFood(name: "Waffle (Frozen / Heated)", servingSize: "per waffle", carbGrams: 15, imageName: "im_waffle"),
            CarbFood(name: "Dinner Roll", servingSize: "per roll", carbGrams: 15, imageName: "im_dinner_roll")
        ]),
        CarbCategory(title: "Milk", foods: [
            CarbFood(name: "Regular Milk", servingSize: "1 cup", carbGrams: 12, imageName: "im_milk"),
            CarbFood(name: "Chocolate Milk", servingSize: "1 cup", carbGrams: 24, imageName: "im_chocolate_milk"),
            CarbFood(name: "Flavored Soy / Almond Milk", servingSize: "1 cup", carbGrams: 15, imageName: "im_strawberry_milk"),
            CarbFood(name: "Almond Milk", servingSize: "1 cup", carbGrams: 8, imageName: "im_almond_milk"),
            CarbFood(name: "Chobani Kids Yogurt Tube", servingSize: "1 stick", carbGrams: 7, imageName: "im_yogurt_tube"),
            CarbFood(name: "Light Yogurt", servingSize: "6 oz", carbGrams: 15, imageName: "im_light_yogurt"),
            CarbFood(name: "Regular Yogurt", servingSize: "6 oz", carbGrams: 30, imageName: "im_regular_yogurt")
        ]),
        CarbCategory(title: "Starchy Vegetables", foods: [
            CarbFood(name: "Baked Potato", servingSize: "1 small potato", carbGrams: 30, imageName: "im_baked_potato"),
            CarbFood(name: "Mashed Potato", servingSize: "1 cup", carbGrams: 15, imageName: "im_mashed_potatoes"),
            CarbFood(name: "Fast Food French Fries", servingSize: "small size", carbGrams: 30, imageName: "im_french_fries"),
            CarbFood(name: "Sweet Potato", servingSize: "1/2 cup", carbGrams: 15, imageName: "im_sweet_potato"),
            CarbFood(name: "Green Peas", servingSize: "1/2 cup", carbGrams: 15, imageName: "im_green_peas"),
            CarbFood(name: "Corn", servingSize: "1/2 cup | 1 small corn on cob", carbGrams: 15, imageName: "im_corn_on_the_cob"),
            CarbFood(name: "Black / Pinto Beans", servingSize: "1/2 cup", carbGrams: 15, imageName: "im_black_beans"),
            CarbFood(name: "Baked Beans", servingSize: "1/2 cup", carbGrams: 25, imageName: "im_pinto_beans"),
            CarbFood(name: "Lima Beans", servingSize: "1/2 cup", carbGrams: 15, imageName: "im_soybeans"),
            CarbFood(name: "Black-Eyed Peas", servingSize: "1/2 cup", carbGrams: 15, imageName: "im_black_eyed_peas"),
            CarbFood(name: "Lentils", servingSize: "1/2 cup | cooked", carbGrams: 15, imageName: "im_kidney_beans"),
            CarbFood(name: "Butternut Squash", servingSize: "1 cup | cooked", carbGrams: 25, imageName: "im_butternut_squash"),
            CarbFood(name: "Chickpeas", servingSize: "1 cup | cooked", carbGrams: 20, imageName: "im_chickpeas"),
            CarbFood(name: "Tater Tots", servingSize: "9 pieces", carbGrams: 20, imageName: "im_tater_tots")
        ]),
        CarbCategory(title: "Fruits", foods: [
            CarbFood(name: "Orange", servingSize: "small orange", carbGrams: 30, imageName: "im_orange"),
            CarbFood(name: "Apple", servingSize: "small apple", carbGrams: 15, imageName: "im_apple"),
            CarbFood(name: "Banana", servingSize: "medium banana", carbGrams: 30, imageName: "im_banana"),
            CarbFood(name: "Clementines", servingSize: "2 small", carbGrams: 15, imageName: "im_tangerines"),
            CarbFood(name: "Grapes", servingSize: "15-17 grapes | 1/2 cup", carbGrams: 15, imageName: "im_cherries"),
            CarbFood(name: "Pear", servingSize: "1 large pear", carbGrams: 15, imageName: "im_pear"),
            CarbFood(name: "Strawberries", servingSize: "1 1/4 cup", carbGrams: 15, imageName: "im_strawberries"),
            CarbFood(name: "Watermelon", servingSize: "1 1/4 cup", carbGrams: 25, imageName: "im_watermelon"),
            CarbFood(name: "Dried Fruit (Raisins)", servingSize: "2 tbsp", carbGrams: 15, imageName: "im_raisins"),
            CarbFood(name: "Fruit Cup in Light Syrup", servingSize: "1/2 cup", carbGrams: 15, imageName: "im_fruit_cocktail"),
            CarbFood(name: "Unsweetened Applesauce", servingSize: "1/2 cup | cooked", carbGrams: 15, imageName: "im_applesauce"),
            CarbFood(name: "Orange / Apple Juice", servingSize: "1/2 cup", carbGrams: 25, imageName: "im_orange_juice"),
            CarbFood(name: "Blueberries", servingSize: "3/4 cup", carbGrams: 20, imageName: "im_blueberries"),
            CarbFood(name: "Melon Cup", servingSize: "1 cup", carbGrams: 20, imageName: "im_melon")
        ]),
        CarbCategory(title: "Snacks", foods: [
            CarbFood(name: "Popcorn", servingSize: "3 cups", carbGrams: 15, imageName: "im_popcorn"),
            CarbFood(name: "Pretzel Sticks", servingSize: "30 thin sticks", carbGrams: 15, imageName: "im_pretzel_sticks"),
            CarbFood(name: "Goldfish", servingSize: "1/2 cup | 45 pcs", carbGrams: 15, imageName: "im_goldfish_crackers"),
            CarbFood(name: "Potato Chips", servingSize: "1 oz bag", carbGrams: 15, imageName: "im_potato_chips"),
            CarbFood(name: "Lance Whole Grain Cheese/PB Sand", servingSize: "1 pkt", carbGrams: 25, imageName: "im_whole_grain_crackers"),
            CarbFood(name: "Nature's Valley Protein Chewy Bar", servingSize: "1 bar", carbGrams: 15, imageName: "im_protein_bar"),
            CarbFood(name: "Graham Cracker Squares", servingSize: "3 pcs", carbGrams: 15, imageName: "im_graham_crackers"),
            CarbFood(name: "Rice Cake", servingSize: "1 pc", carbGrams: 12, imageName: "im_rice_cake"),
            CarbFood(name: "Animal Crackers", servingSize: "16", carbGrams: 25, imageName: "im_animal_crackers"),
            CarbFood(name: "Chex Mix", servingSize: "1/2 cup", carbGrams: 20, imageName: "im_snack_mix"),
            CarbFood(name: "Apple Chips", servingSize: "1/4 cup", carbGrams: 15, imageName: "im_apple_chips"),
            CarbFood(name: "Wheat Thins", servingSize: "11 pcs", carbGrams: 21, imageName: "im_cheese_crackers"),
            CarbFood(name: "Cheese-It Crackers", servingSize: "23 pcs", carbGrams: 15, imageName: "im_cheese_cubes"),
            CarbFood(name: "Vanilla Wafers", servingSize: "5 pcs", carbGrams: 13, imageName: "im_vanilla_wafers")
        ]),
        CarbCategory(title: "Combination Foods", foods: [
            CarbFood(name: "Pizza", servingSize: "1 slice (1/8 of 14\")", carbGrams: 35, imageName: "im_pepperoni_pizza"),
            CarbFood(name: "Meat & Cheese Taco", servingSize: "1 taco", carbGrams: 15, imageName: "im_taco"),
            CarbFood(name: "Chicken Nuggets", servingSize: "5 pcs", carbGrams: 15, imageName: "im_chicken_nuggets"),
            CarbFood(name: "Macaroni & Cheese", servingSize: "1 cup", carbGrams: 45, imageName: "im_mac_and_cheese"),
            CarbFood(name: "Spaghetti with Sauce", servingSize: "1 cup", carbGrams: 50, imageName: "im_spaghetti_meat_sauce"),
            CarbFood(name: "Fried Chicken Legs", servingSize: "2 pcs", carbGrams: 15, imageName: "im_fried_chicken"),
            CarbFood(name: "Sausage Biscuit", servingSize: "1 pc", carbGrams: 25, imageName: "im_sausage_biscuit"),
            CarbFood(name: "Grilled Cheese Sandwich", servingSize: "1 pc", carbGrams: 30, imageName: "im_grilled_cheese_sandwich"),
            CarbFood(name: "Soup", servingSize: "1 cup", carbGrams: 15, imageName: "im_chicken_noodle_soup"),
            CarbFood(name: "Sub Sandwich", servingSize: "6\" sub", carbGrams: 45, imageName: "im_submarine_sandwich"),
            CarbFood(name: "Corndog", servingSize: "1 pc", carbGrams: 25, imageName: "im_corn_dog"),
            CarbFood(name: "Peanut Butter & Jelly Sandwich", servingSize: "1 pc", carbGrams: 45, imageName: "im_peanut_butter_jelly_sandwich"),
            CarbFood(name: "Cheese Quesadilla", servingSize: "1 pc", carbGrams: 30, imageName: "im_quesadilla"),
            CarbFood(name: "Popcorn Shrimp", servingSize: "3/4 cup", carbGrams: 25, imageName: "im_cheese_puffs")
        ]),
        CarbCategory(title: "Desserts & Sweets", foods: [
            CarbFood(name: "Oreo / Choco Cookies", servingSize: "2 small cookies", carbGrams: 15, imageName: "im_cookies"),
            CarbFood(name: "Frosted cake", servingSize: "1 taco", carbGrams: 30, imageName: "im_birthday_cake"),
            CarbFood(name: "Regular Ice Cream", servingSize: "1/2 cup", carbGrams: 15, imageName: "im_vanilla_ice_cream"),
            CarbFood(name: "Regular Frozen Yogurt", servingSize: "1/2 cup", carbGrams: 15, imageName: "im_strawberry_soft_serve"),
            CarbFood(name: "Sugar-Free Pudding", servingSize: "1/2 cup", carbGrams: 15, imageName: "im_chocolate_pudding"),
            CarbFood(name: "Mini Candy Bars", servingSize: "3 bars", carbGrams: 15, imageName: "im_mini_candy_bars"),
            CarbFood(name: "Welch's Fruit Snacks", servingSize: "0.9 oz pouch", carbGrams: 20, imageName: "im_fruit_snacks")
        ]),
        CarbCategory(title: "Condiments", foods: [
            CarbFood(name: "Pancake Syrup", servingSize: "1 tbsp", carbGrams: 35, imageName: "im_pancake_syrup"),
            CarbFood(name: "Light Pancake Syrup", servingSize: "2 tbsp", carbGrams: 15, imageName: "im_light_pancake_syrup"),
            CarbFood(name: "Sugar-Free Pancake Syrup", servingSize: "2 tbsp", carbGrams: 5, imageName: "im_sugar_free_pancake_syrup"),
            CarbFood(name: "Ketchup", servingSize: "1 tbsp", carbGrams: 5, imageName: "im_ketchup"),
            CarbFood(name: "Sugar, Honey or Jelly", servingSize: "1 tbsp", carbGrams: 15, imageName: "im_honey"),
            CarbFood(name: "BBQ Sauce", servingSize: "1 tbsp", carbGrams: 7, imageName: "im_bbq_sauce")
        ]),
        CarbCategory(title: "Low-Carb Foods", foods: [
            CarbFood(name: "Raw Veggies", servingSize: "1 tbsp", carbGrams: 5, imageName: "im_veggie_tray"),
            CarbFood(name: "Salad with Dressing", servingSize: "2 tbsp", carbGrams: 5, imageName: "im_garden_salad"),
            CarbFood(name: "Broccoli, Cabbage, Carrots, Celery, Collards, Cucumber, Green Beans, Salad Greens.", servingSize: "1/2 cup cooked | 1 cup raw", carbGrams: 5, imageName: "im_mixed_vegetables"),
            CarbFood(name: "Dill Pickles", servingSize: "2 tbsp", carbGrams: 5, imageName: "im_pickles"),
            CarbFood(name: "String Cheese / Eggs / Deli Meats", servingSize: "1 tbsp", carbGrams: 5, imageName: "im_protein_plate"),
            CarbFood(name: "Nuts", servingSize: "1 tbsp", carbGrams: 5, imageName: "im_mixed_nuts"),
            CarbFood(name: "Sunflower Seeds", servingSize: "1 tbsp", carbGrams: 5, imageName: "im_peanuts"),
            CarbFood(name: "Sugar-Free Jello", servingSize: "1 tbsp", carbGrams: 5, imageName: "im_jello"),
            CarbFood(name: "Sugar-Free Popsicles", servingSize: "1 tbsp", carbGrams: 5, imageName: "im_popsicle"),
            CarbFood(name: "Low-Carb Yogurt", servingSize: "1 tbsp", carbGrams: 5, imageName: "im_strawberry_yogurt")
        ])
    ]
}
