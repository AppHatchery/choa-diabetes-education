//
//  KnowYourCarbsViewController.swift
//  choa-diabetes-education
//
//  Created by Maxwell Kapezi Jr on 26/08/2026.
//

import UIKit
import SwiftUI

class KnowYourCarbsViewController: UIViewController {

    private let searchController = UISearchController(searchResultsController: nil)
    private let tableView = UITableView(frame: .zero, style: .plain)

    private let allCategories = KnowYourCarbsData.categories
    private var filteredCategories: [CarbCategory] = []

    private var isSearching: Bool {
        let text = searchController.searchBar.text ?? ""
        return searchController.isActive && !text.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private var displayedCategories: [CarbCategory] {
        isSearching ? filteredCategories : allCategories
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Nutrition Facts"
        view.backgroundColor = .white

        setupDisclaimer()
        setupSearchController()
        setupTableView()
    }

    // MARK: - Setup

    private func setupDisclaimer() {
        let disclaimerLabel = UILabel()
        disclaimerLabel.translatesAutoresizingMaskIntoConstraints = false
        disclaimerLabel.numberOfLines = 0
        disclaimerLabel.font = .nunito16
        disclaimerLabel.textColor = .label
        disclaimerLabel.text = "Carb values are estimates based on common foods and popular brands. Actual values can vary. This is a simple guide, not medical advice."

        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .sunsetOrangeColor100
        container.layer.cornerRadius = 12
        container.addSubview(disclaimerLabel)

        NSLayoutConstraint.activate([
            disclaimerLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            disclaimerLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12),
            disclaimerLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            disclaimerLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12)
        ])

        view.addSubview(container)
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])

        disclaimerContainer = container
    }

    private var disclaimerContainer: UIView!

    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search foods"
        searchController.searchBar.tintColor = .choaGreenColor
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.register(CarbFoodTableViewCell.self, forCellReuseIdentifier: CarbFoodTableViewCell.reuseIdentifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 68
        tableView.sectionHeaderTopPadding = 0

        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: disclaimerContainer.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - Filtering

    private func filterContent(for query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespaces).lowercased()
        guard !trimmed.isEmpty else {
            filteredCategories = []
            return
        }

        filteredCategories = allCategories.compactMap { category in
            let matches = category.foods.filter { $0.name.lowercased().contains(trimmed) }
            guard !matches.isEmpty else { return nil }
            return CarbCategory(title: category.title, foods: matches)
        }
    }
}

// MARK: - UITableViewDataSource

extension KnowYourCarbsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        displayedCategories.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        displayedCategories[section].foods.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        displayedCategories[section].title
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CarbFoodTableViewCell.reuseIdentifier, for: indexPath) as! CarbFoodTableViewCell
        let food = displayedCategories[indexPath.section].foods[indexPath.row]
        cell.configure(with: food)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension KnowYourCarbsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.font = .nunitoBold14
            header.textLabel?.textColor = .grayColor
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UISearchResultsUpdating

extension KnowYourCarbsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContent(for: searchController.searchBar.text ?? "")
        tableView.reloadData()
    }
}

#if DEBUG
private struct KnowYourCarbsViewControllerPreview: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UINavigationController {
        UINavigationController(rootViewController: KnowYourCarbsViewController())
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
    }
}

struct KnowYourCarbsViewController_Previews: PreviewProvider {
    static var previews: some View {
        KnowYourCarbsViewControllerPreview()
    }
}
#endif
