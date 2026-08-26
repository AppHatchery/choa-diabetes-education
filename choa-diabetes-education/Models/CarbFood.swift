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
}

struct CarbCategory {
    let title: String
    let foods: [CarbFood]
}

enum KnowYourCarbsData {
    static let categories: [CarbCategory] = [
        CarbCategory(title: "Grains", foods: [
            CarbFood(name: "Bread Roll", servingSize: "1 small roll", carbGrams: 15, imageName: "im_bread_roll"),
            CarbFood(name: "Cheerios", servingSize: "3/4 cup", carbGrams: 15, imageName: "im_cheerios"),
            CarbFood(name: "Corn Bread", servingSize: "1 piece (2\"x2\")", carbGrams: 15, imageName: "im_cornbread"),
            CarbFood(name: "Dinner Roll", servingSize: "1 roll", carbGrams: 15, imageName: "im_dinner_roll"),
            CarbFood(name: "English Muffin", servingSize: "1/2 muffin", carbGrams: 15, imageName: "im_english_muffin"),
            CarbFood(name: "Fruit Loops", servingSize: "3/4 cup", carbGrams: 15, imageName: "im_fruit_loops"),
            CarbFood(name: "Oatmeal", servingSize: "1/2 cup cooked", carbGrams: 15, imageName: "im_oatmeal"),
            CarbFood(name: "Pancake", servingSize: "1 (4\" pancake)", carbGrams: 15, imageName: "im_pancake"),
            CarbFood(name: "Penne Pasta", servingSize: "1/3 cup cooked", carbGrams: 15, imageName: "im_penne_pasta"),
            CarbFood(name: "Tortilla", servingSize: "1 (6\" tortilla)", carbGrams: 15, imageName: "im_tortilla"),
            CarbFood(name: "Waffle (Frozen/Homemade)", servingSize: "1 (4\" waffle)", carbGrams: 15, imageName: "im_waffle"),
            CarbFood(name: "White Bread", servingSize: "1 slice", carbGrams: 15, imageName: "im_white_bread"),
            CarbFood(name: "White Rice", servingSize: "1/3 cup cooked", carbGrams: 15, imageName: "im_white_rice")
        ]),
        CarbCategory(title: "Milk", foods: [
            CarbFood(name: "Almond Milk", servingSize: "1 cup", carbGrams: 3, imageName: "im_almond_milk"),
            CarbFood(name: "Chocolate Milk", servingSize: "1 cup", carbGrams: 26, imageName: "im_chocolate_milk"),
            CarbFood(name: "Light Yogurt", servingSize: "6 oz", carbGrams: 15, imageName: "im_light_yogurt"),
            CarbFood(name: "Milk", servingSize: "1 cup", carbGrams: 12, imageName: "im_milk"),
            CarbFood(name: "Regular Yogurt", servingSize: "6 oz", carbGrams: 15, imageName: "im_regular_yogurt"),
            CarbFood(name: "Strawberry Milk", servingSize: "1 cup", carbGrams: 26, imageName: "im_strawberry_milk"),
            CarbFood(name: "Yogurt Tube", servingSize: "1 tube", carbGrams: 10, imageName: "im_yogurt_tube")
        ]),
        CarbCategory(title: "Starchy Vegetables", foods: [
            CarbFood(name: "Baked Potato", servingSize: "1/2 medium", carbGrams: 15, imageName: "im_baked_potato"),
            CarbFood(name: "Black Beans", servingSize: "1/2 cup", carbGrams: 15, imageName: "im_black_beans"),
            CarbFood(name: "Black Eyed Peas", servingSize: "1/2 cup", carbGrams: 15, imageName: "im_black_eyed_peas"),
            CarbFood(name: "Butternut Squash", servingSize: "1 cup", carbGrams: 15, imageName: "im_butternut_squash"),
            CarbFood(name: "Chickpeas", servingSize: "1/2 cup", carbGrams: 15, imageName: "im_chickpeas"),
            CarbFood(name: "Corn on the Cob", servingSize: "1/2 cob", carbGrams: 15, imageName: "im_corn_on_the_cob"),
            CarbFood(name: "French Fries", servingSize: "10 fries", carbGrams: 15, imageName: "im_french_fries"),
            CarbFood(name: "Green Peas", servingSize: "1/2 cup", carbGrams: 15, imageName: "im_green_peas"),
            CarbFood(name: "Kidney Beans", servingSize: "1/2 cup", carbGrams: 15, imageName: "im_kidney_beans"),
            CarbFood(name: "Mashed Potatoes", servingSize: "1/2 cup", carbGrams: 15, imageName: "im_mashed_potatoes"),
            CarbFood(name: "Pinto Beans", servingSize: "1/2 cup", carbGrams: 15, imageName: "im_pinto_beans"),
            CarbFood(name: "Soybeans", servingSize: "1 cup", carbGrams: 15, imageName: "im_soybeans"),
            CarbFood(name: "Sweet Potato", servingSize: "1/2 cup", carbGrams: 15, imageName: "im_sweet_potato"),
            CarbFood(name: "Tater Tots", servingSize: "9 pieces", carbGrams: 15, imageName: "im_tater_tots")
        ]),
        CarbCategory(title: "Fruits", foods: [
            CarbFood(name: "Apple", servingSize: "1 small", carbGrams: 15, imageName: "im_apple"),
            CarbFood(name: "Applesauce", servingSize: "1/2 cup", carbGrams: 15, imageName: "im_applesauce"),
            CarbFood(name: "Banana", servingSize: "1 small", carbGrams: 15, imageName: "im_banana"),
            CarbFood(name: "Blueberries", servingSize: "3/4 cup", carbGrams: 15, imageName: "im_blueberries"),
            CarbFood(name: "Cherries", servingSize: "12 cherries", carbGrams: 15, imageName: "im_cherries"),
            CarbFood(name: "Fruit Cocktail", servingSize: "1/2 cup", carbGrams: 15, imageName: "im_fruit_cocktail"),
            CarbFood(name: "Melon", servingSize: "1 cup cubed", carbGrams: 15, imageName: "im_melon"),
            CarbFood(name: "Orange", servingSize: "1 small", carbGrams: 15, imageName: "im_orange"),
            CarbFood(name: "Orange Juice", servingSize: "1/2 cup", carbGrams: 15, imageName: "im_orange_juice"),
            CarbFood(name: "Pear", servingSize: "1 small", carbGrams: 15, imageName: "im_pear"),
            CarbFood(name: "Pineapple", servingSize: "3/4 cup", carbGrams: 15, imageName: "im_pineapple"),
            CarbFood(name: "Raisins", servingSize: "2 tbsp", carbGrams: 15, imageName: "im_raisins"),
            CarbFood(name: "Strawberries", servingSize: "1 1/4 cup", carbGrams: 15, imageName: "im_strawberries"),
            CarbFood(name: "Tangerines", servingSize: "2 small", carbGrams: 15, imageName: "im_tangerines"),
            CarbFood(name: "Watermelon", servingSize: "1 1/4 cup", carbGrams: 15, imageName: "im_watermelon")
        ]),
        CarbCategory(title: "Snacks", foods: [
            CarbFood(name: "Animal Crackers", servingSize: "8 crackers", carbGrams: 15, imageName: "im_animal_crackers"),
            CarbFood(name: "Apple Chips", servingSize: "1 oz", carbGrams: 15, imageName: "im_apple_chips"),
            CarbFood(name: "Cheese Crackers", servingSize: "15 crackers", carbGrams: 15, imageName: "im_cheese_crackers"),
            CarbFood(name: "Cheese Cubes", servingSize: "1 oz", carbGrams: 1, imageName: "im_cheese_cubes"),
            CarbFood(name: "Goldfish Crackers", servingSize: "30 crackers", carbGrams: 15, imageName: "im_goldfish_crackers"),
            CarbFood(name: "Graham Crackers", servingSize: "3 squares", carbGrams: 15, imageName: "im_graham_crackers"),
            CarbFood(name: "Popcorn", servingSize: "3 cups popped", carbGrams: 15, imageName: "im_popcorn"),
            CarbFood(name: "Potato Chips", servingSize: "15 chips", carbGrams: 15, imageName: "im_potato_chips"),
            CarbFood(name: "Pretzel Sticks", servingSize: "20 sticks", carbGrams: 15, imageName: "im_pretzel_sticks"),
            CarbFood(name: "Protein Bar", servingSize: "1 bar", carbGrams: 20, imageName: "im_protein_bar"),
            CarbFood(name: "Rice Cake", servingSize: "2 cakes", carbGrams: 15, imageName: "im_rice_cake"),
            CarbFood(name: "Snack Mix", servingSize: "1/2 cup", carbGrams: 15, imageName: "im_snack_mix"),
            CarbFood(name: "Vanilla Wafers", servingSize: "8 wafers", carbGrams: 15, imageName: "im_vanilla_wafers"),
            CarbFood(name: "Whole Grain Crackers", servingSize: "6 crackers", carbGrams: 15, imageName: "im_whole_grain_crackers")
        ]),
        CarbCategory(title: "Combination Foods", foods: [
            CarbFood(name: "Cheese Puffs", servingSize: "1 cup", carbGrams: 15, imageName: "im_cheese_puffs"),
            CarbFood(name: "Chicken Noodle Soup", servingSize: "1 cup", carbGrams: 15, imageName: "im_chicken_noodle_soup"),
            CarbFood(name: "Chicken Nuggets", servingSize: "6 pieces", carbGrams: 15, imageName: "im_chicken_nuggets"),
            CarbFood(name: "Corn Dog", servingSize: "1 corn dog", carbGrams: 25, imageName: "im_corn_dog"),
            CarbFood(name: "Fried Chicken", servingSize: "2 pieces", carbGrams: 5, imageName: "im_fried_chicken"),
            CarbFood(name: "Grilled Cheese Sandwich", servingSize: "1 sandwich", carbGrams: 30, imageName: "im_grilled_cheese_sandwich"),
            CarbFood(name: "Mac and Cheese", servingSize: "1 cup", carbGrams: 30, imageName: "im_mac_and_cheese"),
            CarbFood(name: "Peanut Butter & Jelly Sandwich", servingSize: "1 sandwich", carbGrams: 30, imageName: "im_peanut_butter_jelly_sandwich"),
            CarbFood(name: "Pepperoni Pizza", servingSize: "2 slices", carbGrams: 30, imageName: "im_pepperoni_pizza"),
            CarbFood(name: "Quesadilla", servingSize: "1 quesadilla", carbGrams: 30, imageName: "im_quesadilla"),
            CarbFood(name: "Sausage Biscuit", servingSize: "1 biscuit", carbGrams: 25, imageName: "im_sausage_biscuit"),
            CarbFood(name: "Spaghetti with Meat Sauce", servingSize: "1 cup", carbGrams: 45, imageName: "im_spaghetti_meat_sauce"),
            CarbFood(name: "Submarine Sandwich", servingSize: "6 inch sub", carbGrams: 45, imageName: "im_submarine_sandwich"),
            CarbFood(name: "Taco", servingSize: "1 taco", carbGrams: 15, imageName: "im_taco")
        ]),
        CarbCategory(title: "Desserts & Sweets", foods: [
            CarbFood(name: "Birthday Cake", servingSize: "1 slice", carbGrams: 35, imageName: "im_birthday_cake"),
            CarbFood(name: "Chocolate Pudding", servingSize: "1/2 cup", carbGrams: 20, imageName: "im_chocolate_pudding"),
            CarbFood(name: "Cookies", servingSize: "2 small cookies", carbGrams: 15, imageName: "im_cookies"),
            CarbFood(name: "Fruit Snacks", servingSize: "1 pouch", carbGrams: 15, imageName: "im_fruit_snacks"),
            CarbFood(name: "Mini Candy Bars", servingSize: "3 pieces", carbGrams: 15, imageName: "im_mini_candy_bars"),
            CarbFood(name: "Strawberry Soft Serve", servingSize: "1/2 cup", carbGrams: 30, imageName: "im_strawberry_soft_serve"),
            CarbFood(name: "Vanilla Ice Cream", servingSize: "1/2 cup", carbGrams: 15, imageName: "im_vanilla_ice_cream")
        ]),
        CarbCategory(title: "Condiments", foods: [
            CarbFood(name: "BBQ Sauce", servingSize: "3 tbsp", carbGrams: 15, imageName: "im_bbq_sauce"),
            CarbFood(name: "Honey", servingSize: "1 tbsp", carbGrams: 15, imageName: "im_honey"),
            CarbFood(name: "Ketchup", servingSize: "4 tbsp", carbGrams: 15, imageName: "im_ketchup"),
            CarbFood(name: "Light Pancake Syrup", servingSize: "3 tbsp", carbGrams: 15, imageName: "im_light_pancake_syrup"),
            CarbFood(name: "Pancake Syrup", servingSize: "1 tbsp", carbGrams: 15, imageName: "im_pancake_syrup"),
            CarbFood(name: "Sugar-Free Pancake Syrup", servingSize: "1/4 cup", carbGrams: 0, imageName: "im_sugar_free_pancake_syrup")
        ]),
        CarbCategory(title: "Low-Carb Foods", foods: [
            CarbFood(name: "Bagel", servingSize: "1/2 bagel", carbGrams: 15, imageName: "im_bagel"),
            CarbFood(name: "Garden Salad", servingSize: "2 cups", carbGrams: 5, imageName: "im_garden_salad"),
            CarbFood(name: "Jello (Sugar-Free)", servingSize: "1/2 cup", carbGrams: 0, imageName: "im_jello"),
            CarbFood(name: "Mixed Nuts", servingSize: "1/4 cup", carbGrams: 5, imageName: "im_mixed_nuts"),
            CarbFood(name: "Mixed Vegetables", servingSize: "1/2 cup", carbGrams: 5, imageName: "im_mixed_vegetables"),
            CarbFood(name: "Peanuts", servingSize: "1/4 cup", carbGrams: 5, imageName: "im_peanuts"),
            CarbFood(name: "Pickles", servingSize: "1 cup", carbGrams: 1, imageName: "im_pickles"),
            CarbFood(name: "Popsicle (Sugar-Free)", servingSize: "1 popsicle", carbGrams: 5, imageName: "im_popsicle"),
            CarbFood(name: "Protein Plate", servingSize: "1 plate", carbGrams: 5, imageName: "im_protein_plate"),
            CarbFood(name: "Strawberry Yogurt (Light)", servingSize: "6 oz", carbGrams: 15, imageName: "im_strawberry_yogurt"),
            CarbFood(name: "Veggie Tray", servingSize: "1 cup", carbGrams: 5, imageName: "im_veggie_tray")
        ])
    ]
}
