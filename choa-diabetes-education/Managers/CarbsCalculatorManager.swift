//
//  CarbsCalculatorManager.swift
//  choa-diabetes-education
//
//  Created by Maxwell Kapezi Jr on 26/08/2026.
//

import Foundation
import Combine

final class CarbsCalculatorManager: ObservableObject {
    static let shared = CarbsCalculatorManager()

    @Published private(set) var quantities: [String: Int] = [:] {
        didSet { recalculateTotal() }
    }

    @Published var additionalCarbs: Int = 0 {
        didSet { recalculateTotal() }
    }

    /// Stored rather than computed so subscribers receive the up-to-date value.
    /// `@Published` emits in `willSet`, so reading a computed total from inside a
    /// sink would always be one change behind.
    @Published private(set) var totalCarbs: Int = 0

    private let allFoods: [CarbFood] = KnowYourCarbsData.categories.flatMap { $0.foods }

    private init() {}

    private func recalculateTotal() {
        totalCarbs = totalCarbsFromFoods + additionalCarbs
    }

    func quantity(for food: CarbFood) -> Int {
        quantities[food.name] ?? 0
    }

    func setQuantity(_ quantity: Int, for food: CarbFood) {
        if quantity <= 0 {
            quantities.removeValue(forKey: food.name)
        } else {
            quantities[food.name] = quantity
        }
    }

    func increment(_ food: CarbFood) {
        setQuantity(quantity(for: food) + 1, for: food)
    }

    func decrement(_ food: CarbFood) {
        setQuantity(max(0, quantity(for: food) - 1), for: food)
    }

    var selectedFoods: [(food: CarbFood, quantity: Int)] {
        allFoods.compactMap { food in
            guard let quantity = quantities[food.name], quantity > 0 else { return nil }
            return (food, quantity)
        }
    }

    var totalCarbsFromFoods: Int {
        selectedFoods.reduce(0) { $0 + $1.food.carbGrams * $1.quantity }
    }

    func reset() {
        quantities = [:]
        additionalCarbs = 0
    }
}
