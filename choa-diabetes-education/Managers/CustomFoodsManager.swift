//
//  CustomFoodsManager.swift
//  choa-diabetes-education
//
//  Created by Maxwell Kapezi Jr on 27/08/2026.
//

import Foundation
import Combine

/// Owns the user's own food items and publishes them merged into the built-in
/// catalogue, so the food list only ever has one source to read from.
final class CustomFoodsManager: ObservableObject {
    static let shared = CustomFoodsManager()

    /// Custom items have no artwork of their own, so they all share this icon.
    static let iconName = "croissant"

    private struct StoredFood: Codable {
        let name: String
        let servingSize: String
        let carbGrams: Int
        let categoryTitle: String
    }

    /// Built-in categories with each user item appended to its chosen category.
    @Published private(set) var categories: [CarbCategory] = []

    private var storedFoods: [StoredFood] = []

    private let defaults = UserDefaults.standard
    private let storageKey = "know_your_carbs_custom_foods"

    var categoryTitles: [String] {
        KnowYourCarbsData.categories.map { $0.title }
    }

    private init() {
        storedFoods = loadStoredFoods()
        rebuildCategories()
    }

    // MARK: - Mutations

    func addFood(name: String, carbGrams: Int, servingSize: String, categoryTitle: String) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }

        storedFoods.append(
            StoredFood(
                name: trimmedName,
                servingSize: servingSize.trimmingCharacters(in: .whitespacesAndNewlines),
                carbGrams: carbGrams,
                categoryTitle: categoryTitle
            )
        )

        persist()
        rebuildCategories()
    }

    func removeFood(named name: String) {
        guard storedFoods.contains(where: { $0.name == name }) else { return }

        storedFoods.removeAll { $0.name == name }
        persist()
        rebuildCategories()

        // Drop any quantity the deleted item contributed to the running total.
        CarbsCalculatorManager.shared.clearQuantity(forFoodNamed: name)
    }

    /// Names are the identity used by the calculator, so they have to stay unique.
    func nameIsAvailable(_ name: String) -> Bool {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmed.isEmpty else { return false }
        return !categories
            .flatMap { $0.foods }
            .contains { $0.name.lowercased() == trimmed }
    }

    // MARK: - Storage

    private func rebuildCategories() {
        categories = KnowYourCarbsData.categories.map { category in
            let custom = storedFoods
                .filter { $0.categoryTitle == category.title }
                .map {
                    CarbFood(
                        name: $0.name,
                        servingSize: $0.servingSize,
                        carbGrams: $0.carbGrams,
                        imageName: Self.iconName,
                        isCustom: true
                    )
                }

            return CarbCategory(title: category.title, foods: category.foods + custom)
        }
    }

    private func loadStoredFoods() -> [StoredFood] {
        guard let data = defaults.data(forKey: storageKey) else { return [] }
        return (try? JSONDecoder().decode([StoredFood].self, from: data)) ?? []
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(storedFoods) else { return }
        defaults.set(data, forKey: storageKey)
    }
}
