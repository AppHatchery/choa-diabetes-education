//
//  KnowYourCarbsViewController.swift
//  choa-diabetes-education
//
//  Created by Maxwell Kapezi Jr on 26/08/2026.
//

import UIKit
import SwiftUI
import Combine

class KnowYourCarbsViewController: UIViewController {

    private let searchController = UISearchController(searchResultsController: nil)
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let calculator = CarbsCalculatorManager.shared
    private var cancellables: Set<AnyCancellable> = []
    private weak var totalCarbsSheet: TotalCarbsSheetViewController?

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

        view.backgroundColor = .white
        navigationItem.backButtonDisplayMode = .minimal

        setupCategoryChips()
        setupDisclaimer()
        setupSearchController()
        setupTableView()
        observeTotalCarbs()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Restore the sheet when returning from the results screen, reflecting
        // any quantity changes made while away.
        updateTotalCarbsSheet(totalCarbs: calculator.totalCarbs)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dismissTotalCarbsSheet()
    }

    // MARK: - Setup

    private var chipsContainer: UIView!
    private var disclaimerContainer: UIView!
    private var disclaimerHostingController: UIHostingController<DisclaimerBanner>?
    private var tableViewTopConstraint: NSLayoutConstraint!

    private func setupCategoryChips() {
        let chipsView = CategoryChipsRow(categories: allCategories) { [weak self] index in
            self?.scrollToCategory(at: index)
        }
        let controller = UIHostingController(rootView: chipsView)
        controller.view.backgroundColor = .clear
        controller.view.translatesAutoresizingMaskIntoConstraints = false

        addChild(controller)
        view.addSubview(controller.view)
        controller.didMove(toParent: self)

        NSLayoutConstraint.activate([
            controller.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            controller.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            controller.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        chipsContainer = controller.view
    }

    private func setupDisclaimer() {
        let disclaimerView = DisclaimerBanner { [weak self] in
            self?.dismissDisclaimer()
        }
        let controller = UIHostingController(rootView: disclaimerView)
        controller.view.backgroundColor = .clear
        controller.view.translatesAutoresizingMaskIntoConstraints = false

        addChild(controller)
        view.addSubview(controller.view)
        controller.didMove(toParent: self)

        NSLayoutConstraint.activate([
            controller.view.topAnchor.constraint(equalTo: chipsContainer.bottomAnchor),
            controller.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            controller.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])

        disclaimerContainer = controller.view
        disclaimerHostingController = controller
    }

    private func dismissDisclaimer() {
        guard let controller = disclaimerHostingController else { return }

        tableViewTopConstraint.isActive = false
        tableViewTopConstraint = tableView.topAnchor.constraint(equalTo: chipsContainer.bottomAnchor, constant: 12)
        tableViewTopConstraint.isActive = true

        UIView.animate(withDuration: 0.25, animations: {
            controller.view.alpha = 0
            self.view.layoutIfNeeded()
        }, completion: { _ in
            controller.willMove(toParent: nil)
            controller.view.removeFromSuperview()
            controller.removeFromParent()
            self.disclaimerHostingController = nil
        })
    }

    private func observeTotalCarbs() {
        calculator.$totalCarbs
            .removeDuplicates()
            .sink { [weak self] totalCarbs in
                self?.updateTotalCarbsSheet(totalCarbs: totalCarbs)
            }
            .store(in: &cancellables)
    }

    /// The sheet belongs to this screen only — while another screen (e.g. the
    /// results screen) is on top, totals keep updating silently in the background.
    private var isCurrentlyVisible: Bool {
        viewIfLoaded?.window != nil && navigationController?.topViewController === self
    }

    private func updateTotalCarbsSheet(totalCarbs: Int) {
        guard totalCarbs > 0, isCurrentlyVisible else {
            dismissTotalCarbsSheet()
            return
        }

        guard totalCarbsSheet == nil, presentedViewController == nil else { return }

        let sheet = TotalCarbsSheetViewController { [weak self] in
            self?.presentResults()
        }
        totalCarbsSheet = sheet
        present(sheet, animated: true)
    }

    private func dismissTotalCarbsSheet(completion: (() -> Void)? = nil) {
        guard let sheet = totalCarbsSheet else {
            completion?()
            return
        }
        totalCarbsSheet = nil
        sheet.dismiss(animated: true, completion: completion)
    }

    private func presentResults() {
        dismissTotalCarbsSheet { [weak self] in
            let resultsVC = KnowYourCarbsResultViewController()
            resultsVC.hidesBottomBarWhenPushed = true
            self?.navigationController?.pushViewController(resultsVC, animated: true)
        }
    }

    private func scrollToCategory(at index: Int) {
        guard !isSearching, allCategories.indices.contains(index) else { return }
        searchController.isActive = false
        tableView.scrollToRow(at: IndexPath(row: 0, section: index), at: .top, animated: true)
    }

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

        tableViewTopConstraint = tableView.topAnchor.constraint(equalTo: disclaimerContainer.bottomAnchor, constant: 12)

        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableViewTopConstraint,
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
        cell.configure(with: food, parent: self)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension KnowYourCarbsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.font = .nunitoMedium20
            header.textLabel?.textColor = .primaryBlue
            header.textLabel?.lineBreakMode = .byWordWrapping
            header.contentView.backgroundColor = .white
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

// MARK: - Category Chips

private struct CategoryChipsRow: View {
    let categories: [CarbCategory]
    let onSelect: (Int) -> Void

    private let palette: [Color] = [
        Color(red: 0.98, green: 0.92, blue: 0.96),
        Color(red: 0.90, green: 0.96, blue: 1.0),
        Color(red: 1.0, green: 0.95, blue: 0.85),
        Color(red: 0.95, green: 0.92, blue: 1.0),
        Color(red: 0.92, green: 0.98, blue: 0.93),
        Color(red: 0.95, green: 0.92, blue: 1.0),
        Color(red: 1.0, green: 0.93, blue: 0.90),
        Color(red: 0.93, green: 0.96, blue: 0.90),
        Color(red: 0.90, green: 0.97, blue: 0.95)
    ]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 20) {
                ForEach(Array(categories.enumerated()), id: \.offset) { index, category in
                    CategoryChip(
                        category: category,
                        backgroundColor: palette[index % palette.count],
                        action: { onSelect(index) }
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 4)
        }
    }
}

private struct CategoryChip: View {
    let category: CarbCategory
    let backgroundColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(category.foods.first?.imageName ?? "")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 56, height: 56)
                    .background(backgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                Text(category.title)
                    .font(.custom("Nunito-Regular", size: 14))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(width: 64)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Disclaimer Banner

private struct DisclaimerBanner: View {
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(Color(.orangeTextColor))
                Text("Disclaimer")
                    .font(.custom("Nunito-Bold", size: 20))
                    .foregroundColor(Color(.orangeTextColor))
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(.orangeTextColor))
                }
                .buttonStyle(.plain)
            }

            (
                Text("Carb values are estimates based on common foods and popular brands. Actual values may vary slightly by brand, product, or serving size. For a more accurate value, tap ")
                    + Text("Add +").fontWeight(.bold)
                    + Text(" to enter a custom item.")
            )
            .font(.custom("Nunito-Regular", size: 16))
            .foregroundColor(.black)
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(Color(.sunsetOrangeColor100))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

// MARK: - Total Carbs Bottom Sheet

final class TotalCarbsSheetViewController: UIViewController {
    private let onCalculateInsulin: () -> Void

    init(onCalculateInsulin: @escaping () -> Void) {
        self.onCalculateInsulin = onCalculateInsulin
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .sunsetOrangeColor100

        let contentView = TotalCarbsSheetContent(onCalculateInsulin: onCalculateInsulin)
        let controller = UIHostingController(rootView: contentView)
        controller.view.backgroundColor = .clear
        controller.view.translatesAutoresizingMaskIntoConstraints = false

        addChild(controller)
        view.addSubview(controller.view)
        controller.didMove(toParent: self)

        NSLayoutConstraint.activate([
            controller.view.topAnchor.constraint(equalTo: view.topAnchor),
            controller.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            controller.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            controller.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        if let sheet = sheetPresentationController {
            if #available(iOS 16.0, *) {
                let totalCarbsDetentId = UISheetPresentationController.Detent.Identifier("totalCarbs")
                sheet.detents = [.custom(identifier: totalCarbsDetentId) { _ in 100 }]
                sheet.largestUndimmedDetentIdentifier = totalCarbsDetentId
            } else {
                sheet.detents = [.medium()]
                sheet.largestUndimmedDetentIdentifier = .medium
            }
            sheet.prefersGrabberVisible = false
            sheet.preferredCornerRadius = 24
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
        }
        isModalInPresentation = false
    }
}

private struct TotalCarbsSheetContent: View {
    @ObservedObject private var calculator = CarbsCalculatorManager.shared
    let onCalculateInsulin: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Total Carbs")
                    .font(.custom("Nunito-Regular", size: 15))
                    .foregroundColor(Color(.orangeTextColor))
                Text("\(calculator.totalCarbs)g")
                    .font(.custom("Nunito-Bold", size: 28))
                    .foregroundColor(Color(.orangeTextColor))
            }

            Spacer()

            Button(action: onCalculateInsulin) {
                HStack(spacing: 8) {
                    Text("Calculate insulin")
                        .font(.custom("Nunito-Bold", size: 16))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(Color(.sunsetOrangeColor400))
                .cornerRadius(12)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 0)
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
