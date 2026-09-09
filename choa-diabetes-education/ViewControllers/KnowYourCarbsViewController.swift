//
//  KnowYourCarbsViewController.swift
//  choa-diabetes-education
//
//  Created by Maxwell Kapezi Jr on 26/08/2026.
//

import UIKit
import Combine

class KnowYourCarbsViewController: UIViewController {

    // A plain search bar, not a `UISearchController`: an active search
    // controller presents itself over this screen, which blanked the whole page
    // as soon as the keyboard came up.
    private let searchBar = UISearchBar()
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let calculator = CarbsCalculatorManager.shared
    private var cancellables: Set<AnyCancellable> = []
    private weak var totalCarbsSheet: TotalCarbsSheetViewController?

    private let customFoods = CustomFoodsManager.shared
    private var filteredCategories: [CarbCategory] = []

    /// Category titles never wrap, so a header is one line plus its padding.
    private static let sectionHeaderHeight: CGFloat = {
        ceil(UIFont.nunitoMedium20.lineHeight)
            + CarbCategorySectionHeader.topInset
            + CarbCategorySectionHeader.bottomInset
    }()

    /// Built-in catalogue merged with the user's own items.
    private var allCategories: [CarbCategory] {
        customFoods.categories
    }

    private var isSearching: Bool {
        !(searchBar.text ?? "").trimmingCharacters(in: .whitespaces).isEmpty
    }

    private var displayedCategories: [CarbCategory] {
        isSearching ? filteredCategories : allCategories
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        navigationItem.backButtonDisplayMode = .minimal

        setupAddButton()
        setupSearchBar()
        setupCategoryChips()
        setupDisclaimer()
        setupTableView()
        observeTotalCarbs()
        observeCustomFoods()
        observeKeyboard()
        setupKeyboardDismissTap()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // The bar is driven manually from the table view's scrolling — see
        // `scrollViewDidScroll`. Always start the screen with it visible.
        lastScrollOffset = tableView.contentOffset.y
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Restore the sheet when returning from the results screen, reflecting
        // any quantity changes made while away.
        updateTotalCarbsSheet(totalCarbs: calculator.totalCarbs)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Leave the bar visible for whatever comes next, and never leave this
        // screen with a hidden bar the user cannot get back.
        navigationController?.setNavigationBarHidden(false, animated: animated)
        dismissTotalCarbsSheet()
    }

    /// Tapping anywhere outside the search field puts the keyboard away.
    private func setupKeyboardDismissTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        // Let the touch through as well, so rows and chips still respond to the
        // same tap that dismisses the keyboard.
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        // Dragging the list away is the other natural dismiss gesture.
        tableView.keyboardDismissMode = .onDrag
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    /// Keep the list scrollable clear of the keyboard while searching.
    private func observeKeyboard() {
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardFrameChanged),
                           name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        center.addObserver(self, selector: #selector(keyboardWillHide),
                           name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardFrameChanged(_ note: Notification) {
        guard let frame = note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let overlap = max(0, view.bounds.maxY - view.convert(frame, from: nil).minY)
        tableView.contentInset.bottom = overlap
        tableView.verticalScrollIndicatorInsets.bottom = overlap
    }

    @objc private func keyboardWillHide(_ note: Notification) {
        tableView.contentInset.bottom = 0
        tableView.verticalScrollIndicatorInsets.bottom = 0
    }

    // MARK: - Setup

    private var chipsContainer: UIView!
    private var disclaimerContainer: DisclaimerBannerView?
    private var tableViewTopConstraint: NSLayoutConstraint!

    /// Content offset at the last handled scroll event, used to derive the
    /// direction of travel.
    private var lastScrollOffset: CGFloat = 0
    /// Movement smaller than this is treated as noise, so the bar does not
    /// flicker on tiny finger adjustments.
    private static let barToggleThreshold: CGFloat = 24

    private func setupAddButton() {
        var config = UIButton.Configuration.plain()
        config.title = "Add"
        config.image = UIImage(
            systemName: "plus",
            withConfiguration: UIImage
                .SymbolConfiguration(pointSize: 12, weight: .bold)
        )
        config.imagePlacement = .trailing
        config.imagePadding = 4
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
        config.baseForegroundColor = .black
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var out = incoming
            out.font = .nunito16
            return out
        }

        let addButton = UIButton(configuration: config)
        addButton.addTarget(self, action: #selector(addItemTapped), for: .touchUpInside)

        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: addButton)
    }

    @objc private func addItemTapped() {
        dismissTotalCarbsSheet { [weak self] in
            let addVC = AddFoodItemViewController()
            addVC.hidesBottomBarWhenPushed = true
            self?.navigationController?.pushViewController(addVC, animated: true)
        }
    }

    private func observeCustomFoods() {
        customFoods.$categories
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                if self.isSearching {
                    self.filterContent(for: self.searchBar.text ?? "")
                }
                self.tableView.reloadData()
            }
            .store(in: &cancellables)
    }

    private func setupCategoryChips() {
        let chipsView = CategoryChipsView(categories: allCategories) { [weak self] index in
            self?.scrollToCategory(at: index)
        }
        chipsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(chipsView)

        NSLayoutConstraint.activate([
            chipsView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            chipsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chipsView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        chipsContainer = chipsView
    }

    private func setupDisclaimer() {
        let banner = DisclaimerBannerView { [weak self] in
            self?.dismissDisclaimer()
        }
        banner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(banner)

        NSLayoutConstraint.activate([
            banner.topAnchor.constraint(equalTo: chipsContainer.bottomAnchor),
            banner.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            banner.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])

        disclaimerContainer = banner
    }

    private func dismissDisclaimer() {
        guard let banner = disclaimerContainer else { return }

        tableViewTopConstraint.isActive = false
        tableViewTopConstraint = tableView.topAnchor.constraint(equalTo: chipsContainer.bottomAnchor, constant: 12)
        tableViewTopConstraint.isActive = true

        UIView.animate(withDuration: 0.25, animations: {
            banner.alpha = 0
            self.view.layoutIfNeeded()
        }, completion: { _ in
            banner.removeFromSuperview()
            self.disclaimerContainer = nil
        })
    }

    private func observeTotalCarbs() {
        calculator.$totalCarbs
            .removeDuplicates()
            // `@Published` emits in `willSet`, so during a synchronous sink the
            // stored `totalCarbs` is still the previous value. Presenting the
            // sheet from there meant its own subscription immediately read that
            // stale value — which is why the first tap of a stepper showed 0g.
            // Delivering on the next main-queue turn lets the assignment land
            // first.
            .receive(on: DispatchQueue.main)
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
        // Jumping to a category is a deliberate re-orientation — bring the bar
        // back rather than leaving it collapsed.
        navigationController?.setNavigationBarHidden(false, animated: true)
        searchBar.resignFirstResponder()
        tableView.scrollToRow(at: IndexPath(row: 0, section: index), at: .top, animated: true)
    }

    private func setupSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = "Search foods"
        searchBar.tintColor = .choaGreenColor
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundColor = .white
        searchBar.returnKeyType = .search
        searchBar.enablesReturnKeyAutomatically = false

        // The search bar lives in the view rather than in `navigationItem` so
        // that collapsing the nav bar on scroll leaves search reachable.
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8)
        ])
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.register(CarbFoodTableViewCell.self, forCellReuseIdentifier: CarbFoodTableViewCell.reuseIdentifier)
        tableView.register(
            CarbCategorySectionHeader.self,
            forHeaderFooterViewReuseIdentifier: CarbCategorySectionHeader.reuseIdentifier
        )
        // Rows size themselves from their own Auto Layout constraints.
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 88
        tableView.sectionHeaderHeight = Self.sectionHeaderHeight
        tableView.estimatedSectionHeaderHeight = Self.sectionHeaderHeight
        tableView.sectionFooterHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.sectionHeaderTopPadding = 0

        let topAnchorView: UIView = disclaimerContainer ?? chipsContainer
        tableViewTopConstraint = tableView.topAnchor.constraint(equalTo: topAnchorView.bottomAnchor, constant: 12)

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

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CarbFoodTableViewCell.reuseIdentifier, for: indexPath) as! CarbFoodTableViewCell
        let food = displayedCategories[indexPath.section].foods[indexPath.row]
        cell.configure(with: food, parent: self)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension KnowYourCarbsViewController: UITableViewDelegate {
    /// A purpose-built header, rather than restyling the stock `textLabel` in
    /// `willDisplayHeaderView` — that measures the header with the system font
    /// and only then applies the larger one, so the height never matches.
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: CarbCategorySectionHeader.reuseIdentifier
        ) as? CarbCategorySectionHeader
        header?.configure(title: displayedCategories[section].title)
        return header
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        Self.sectionHeaderHeight
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        Self.sectionHeaderHeight
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    /// Only user-created items can be removed; the built-in catalogue is fixed.
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let food = displayedCategories[indexPath.section].foods[indexPath.row]
        guard food.isCustom else { return nil }

        let delete = UIContextualAction(style: .destructive, title: "Delete") { _, _, completion in
            CustomFoodsManager.shared.removeFood(named: food.name)
            completion(true)
        }

        return UISwipeActionsConfiguration(actions: [delete])
    }

    // MARK: - Nav bar hiding

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        lastScrollOffset = scrollView.contentOffset.y
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Only react to the user's own dragging: programmatic scrolls (chip
        // taps, keyboard insets) should not move the bar.
        guard scrollView.isDragging || scrollView.isDecelerating else { return }

        let offset = scrollView.contentOffset.y
        let topInset = -scrollView.adjustedContentInset.top
        let delta = offset - lastScrollOffset

        // Bounce past either end is not a direction the user is choosing.
        let maxOffset = max(topInset, scrollView.contentSize.height - scrollView.bounds.height + scrollView.adjustedContentInset.bottom)
        guard offset > topInset, offset < maxOffset else {
            if offset <= topInset { setBarHidden(false) }
            return
        }

        guard abs(delta) > Self.barToggleThreshold else { return }
        lastScrollOffset = offset
        setBarHidden(delta > 0)
    }

    private func setBarHidden(_ hidden: Bool) {
        guard let nav = navigationController, nav.isNavigationBarHidden != hidden else { return }
        // Never hide the bar out from under an active search.
        guard !hidden || !searchBar.isFirstResponder else { return }
        nav.setNavigationBarHidden(hidden, animated: true)
    }
}

// MARK: - UISearchBarDelegate

extension KnowYourCarbsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterContent(for: searchText)
        tableView.reloadData()
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        // The nav bar stays put while typing; only the cancel affordance changes.
        searchBar.setShowsCancelButton(true, animated: true)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
        filterContent(for: "")
        tableView.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
}

// MARK: - Section Header

private final class CarbCategorySectionHeader: UITableViewHeaderFooterView {
    static let reuseIdentifier = "CarbCategorySectionHeader"
    static let topInset: CGFloat = 12
    static let bottomInset: CGFloat = 8

    private let titleLabel = UILabel()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        let background = UIView()
        background.backgroundColor = .white
        backgroundView = background

        titleLabel.font = .nunitoSemiBold20
        titleLabel.textColor = .primaryBlue
        titleLabel.numberOfLines = 1
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)

        // The height is dictated by the table, so this must not be required.
        let bottom = titleLabel.bottomAnchor.constraint(
            equalTo: contentView.bottomAnchor,
            constant: -Self.bottomInset
        )
        bottom.priority = .required - 1

        // The header is laid out at zero width in an early pass, where this
        // cannot hold alongside the leading inset. Below required, it is simply
        // dropped for that pass instead of being reported as a conflict.
        let trailing = titleLabel.trailingAnchor.constraint(
            equalTo: contentView.trailingAnchor,
            constant: -16
        )
        trailing.priority = .required - 1

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            trailing,
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Self.topInset),
            bottom
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(title: String) {
        titleLabel.text = title
    }
}

// MARK: - Category Chips

/// Horizontally scrolling row of category shortcuts.
private final class CategoryChipsView: UIView {
    private static let palette: [UIColor] = [
        UIColor(red: 0.98, green: 0.92, blue: 0.96, alpha: 1),
        UIColor(red: 0.90, green: 0.96, blue: 1.00, alpha: 1),
        UIColor(red: 1.00, green: 0.95, blue: 0.85, alpha: 1),
        UIColor(red: 0.95, green: 0.92, blue: 1.00, alpha: 1),
        UIColor(red: 0.92, green: 0.98, blue: 0.93, alpha: 1),
        UIColor(red: 0.95, green: 0.92, blue: 1.00, alpha: 1),
        UIColor(red: 1.00, green: 0.93, blue: 0.90, alpha: 1),
        UIColor(red: 0.93, green: 0.96, blue: 0.90, alpha: 1),
        UIColor(red: 0.90, green: 0.97, blue: 0.95, alpha: 1)
    ]

    private let onSelect: (Int) -> Void

    init(categories: [CarbCategory], onSelect: @escaping (Int) -> Void) {
        self.onSelect = onSelect
        super.init(frame: .zero)

        backgroundColor = .clear

        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 20
        stack.alignment = .top
        stack.translatesAutoresizingMaskIntoConstraints = false

        for (index, category) in categories.enumerated() {
            let chip = CategoryChipView(
                category: category,
                backgroundColor: Self.palette[index % Self.palette.count]
            )
            chip.tag = index
            chip.addTarget(self, action: #selector(chipTapped), for: .touchUpInside)
            stack.addArrangedSubview(chip)
        }

        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stack)
        addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            stack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 12),
            stack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -4),
            stack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -16),
            stack.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor, constant: -16)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func chipTapped(_ sender: UIControl) {
        onSelect(sender.tag)
    }
}

private final class CategoryChipView: UIControl {
    init(category: CarbCategory, backgroundColor chipColor: UIColor) {
        super.init(frame: .zero)

        let imageView = UIImageView(image: UIImage(named: category.foods.first?.imageName ?? ""))
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = chipColor
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 14
        imageView.layer.cornerCurve = .continuous
        imageView.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = category.title
        label.font = .nunito14
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false

        addSubview(imageView)
        addSubview(label)

        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 56),
            imageView.heightAnchor.constraint(equalToConstant: 56),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),

            label.widthAnchor.constraint(equalToConstant: 64),
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Subviews are decorative; the chip itself takes the touch.
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        bounds.contains(point) ? self : nil
    }
}

// MARK: - Disclaimer Banner

private final class DisclaimerBannerView: UIView {
    private let onDismiss: () -> Void

    init(onDismiss: @escaping () -> Void) {
        self.onDismiss = onDismiss
        super.init(frame: .zero)

        backgroundColor = .sunsetOrangeColor100
        layer.cornerRadius = 16
        layer.cornerCurve = .continuous

        let icon = UIImageView(
            image: UIImage(
                systemName: "exclamationmark.triangle.fill",
                withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .regular)
            )
        )
        icon.tintColor = .orangeTextColor
        icon.setContentHuggingPriority(.required, for: .horizontal)

        let title = UILabel()
        title.text = "Disclaimer"
        title.font = .nunitoBold20
        title.textColor = .orangeTextColor

        let close = UIButton(type: .system)
        close.setImage(
            UIImage(
                systemName: "xmark",
                withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)
            ),
            for: .normal
        )
        close.tintColor = .orangeTextColor
        close.setContentHuggingPriority(.required, for: .horizontal)
        close.addTarget(self, action: #selector(dismissTapped), for: .touchUpInside)

        let headerRow = UIStackView(arrangedSubviews: [icon, title, UIView(), close])
        headerRow.axis = .horizontal
        headerRow.spacing = 8
        headerRow.alignment = .center

        let body = UILabel()
        body.numberOfLines = 0
        body.attributedText = Self.bodyText()

        let stack = UIStackView(arrangedSubviews: [headerRow, body])
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .fill
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// "Add +" is bold in the middle of an otherwise regular sentence.
    private static func bodyText() -> NSAttributedString {
        let text = NSMutableAttributedString(
            string: "Carb values are estimates based on common foods and popular brands. "
                + "Actual values may vary slightly by brand, product, or serving size. "
                + "For a more accurate value, tap ",
            attributes: [.font: UIFont.nunito16, .foregroundColor: UIColor.black]
        )
        text.append(NSAttributedString(
            string: "Add +",
            attributes: [.font: UIFont.nunitoBold16, .foregroundColor: UIColor.black]
        ))
        text.append(NSAttributedString(
            string: " to enter a custom item.",
            attributes: [.font: UIFont.nunito16, .foregroundColor: UIColor.black]
        ))
        return text
    }

    @objc private func dismissTapped() {
        onDismiss()
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

        let contentView = TotalCarbsSheetContentView(onCalculateInsulin: onCalculateInsulin)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentView)

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: view.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        if let sheet = sheetPresentationController {
            if #available(iOS 16.0, *) {
                let totalCarbsDetentId = UISheetPresentationController.Detent.Identifier("totalCarbs")
                sheet.detents = [
                    .custom(identifier: totalCarbsDetentId) { _ in
                        100 + TotalCarbsSheetContentView.topPadding
                    }
                ]
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

private final class TotalCarbsSheetContentView: UIView {
    /// Breathing room above the content; the sheet's detent includes it.
    static let topPadding: CGFloat = 16

    private let onCalculateInsulin: () -> Void
    private let totalLabel = UILabel()
    private var cancellable: AnyCancellable?

    init(onCalculateInsulin: @escaping () -> Void) {
        self.onCalculateInsulin = onCalculateInsulin
        super.init(frame: .zero)

        backgroundColor = .clear

        let caption = UILabel()
        caption.text = "Total Carbs"
        caption.font = UIFont(name: "Nunito-Regular", size: 15) ?? .nunito16
        caption.textColor = .orangeTextColor

        totalLabel.font = UIFont(name: "Nunito-Bold", size: 28) ?? .nunitoBold24
        totalLabel.textColor = .orangeTextColor

        let textStack = UIStackView(arrangedSubviews: [caption, totalLabel])
        textStack.axis = .vertical
        textStack.spacing = 2
        textStack.alignment = .leading

        var config = UIButton.Configuration.plain()
        config.title = "Calculate insulin"
        config.image = UIImage(
            systemName: "arrow.right",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .bold)
        )
        config.imagePlacement = .trailing
        config.imagePadding = 8
        config.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 20, bottom: 14, trailing: 20)
        config.baseForegroundColor = .white
        config.background.backgroundColor = .sunsetOrangeColor400
        config.background.cornerRadius = 12
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var out = incoming
            out.font = .nunitoBold16
            return out
        }
        let button = UIButton(configuration: config)
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.addTarget(self, action: #selector(calculateTapped), for: .touchUpInside)

        let row = UIStackView(arrangedSubviews: [textStack, UIView(), button])
        row.axis = .horizontal
        row.spacing = 16
        row.alignment = .center
        row.isLayoutMarginsRelativeArrangement = true
        row.layoutMargins = UIEdgeInsets(top: Self.topPadding, left: 20, bottom: 0, right: 20)
        row.translatesAutoresizingMaskIntoConstraints = false
        addSubview(row)

        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: topAnchor),
            row.leadingAnchor.constraint(equalTo: leadingAnchor),
            row.trailingAnchor.constraint(equalTo: trailingAnchor),
            row.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        // Seeded from the current value as well as subscribed, so the sheet is
        // never blank for a frame no matter when it is constructed.
        totalLabel.text = "\(CarbsCalculatorManager.shared.totalCarbs)g"

        cancellable = CarbsCalculatorManager.shared.$totalCarbs
            .receive(on: DispatchQueue.main)
            .sink { [weak self] total in
                self?.totalLabel.text = "\(total)g"
            }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func calculateTapped() {
        onCalculateInsulin()
    }
}

#if DEBUG
import SwiftUI

private struct KnowYourCarbsViewControllerPreview: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UINavigationController {
        UINavigationController(rootViewController: KnowYourCarbsViewController())
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
}

struct KnowYourCarbsViewController_Previews: PreviewProvider {
    static var previews: some View {
        KnowYourCarbsViewControllerPreview()
    }
}

private struct TotalCarbsSheetViewControllerPreview: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> TotalCarbsSheetViewController {
        TotalCarbsSheetViewController(onCalculateInsulin: {})
    }

    func updateUIViewController(_ uiViewController: TotalCarbsSheetViewController, context: Context) {}
}

struct TotalCarbsSheetViewController_Previews: PreviewProvider {
    static var previews: some View {
        TotalCarbsSheetViewControllerPreview()
            .frame(height: 100)
            .previewLayout(.sizeThatFits)
    }
}
#endif
