//
//  KnowYourCarbsResultViewController.swift
//  choa-diabetes-education
//
//  Created by Maxwell Kapezi Jr on 26/08/2026.
//

import UIKit
import Combine

class KnowYourCarbsResultViewController: UIViewController {

    private let infoPopup = InfoPopUpViewController()
    private let calculator = CarbsCalculatorManager.shared
    private var cancellables: Set<AnyCancellable> = []

    private let scrollView = UIScrollView()
    private let foodsStack = UIStackView()
    private let additionalCarbsField = UITextField()

    private let cardView = TopRoundedView()
    private let cardStack = UIStackView()
    private let breakdownRow = UIStackView()
    private let totalCarbsLabel = UILabel()
    private let carbRatioField = UITextField()
    private let insulinUnitsLabel = UILabel()

    private var showBreakdown = true

    /// Width of each breakdown column, and so of the rule beneath it.
    private static let columnWidth: CGFloat = 150

    private var carbRatio: Int {
        Int(carbRatioField.text ?? "") ?? 0
    }

    private var insulinUnits: Double {
        guard carbRatio > 0 else { return 0 }
        let raw = Double(calculator.totalCarbs) / Double(carbRatio)
        return (raw * 2).rounded(.down) / 2
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = ""
        view.backgroundColor = .white
        navigationItem.backButtonDisplayMode = .minimal

        setupCard()
        setupScrollView()
        setupDismissKeyboardGesture()

        loadCarbRatio()
        reloadFoods()
        refreshValues()

        calculator.$totalCarbs
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.refreshValues() }
            .store(in: &cancellables)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // No saved ratio: ask for one straight away instead of showing a dose
        // derived from a guess.
        if (carbRatioField.text ?? "").isEmpty {
            carbRatioField.becomeFirstResponder()
        }
    }

    // MARK: - Scrolling content

    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)

        foodsStack.axis = .vertical
        foodsStack.spacing = 4
        foodsStack.alignment = .fill
        foodsStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(foodsStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: cardView.topAnchor),

            foodsStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 8),
            foodsStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24),
            foodsStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16),
            foodsStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -16),
            foodsStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -32)
        ])
    }

    /// Rebuilt rather than diffed: the selection is short and only changes when
    /// a quantity drops to zero.
    private func reloadFoods() {
        foodsStack.arrangedSubviews.forEach {
            foodsStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        for entry in calculator.selectedFoods {
            let row = CarbFoodRowView()
            row.showsSeparator = false
            row.configure(with: entry.food)
            foodsStack.addArrangedSubview(row)
        }

        foodsStack.addArrangedSubview(makeAdditionalCarbsField())
    }

    private func makeAdditionalCarbsField() -> UIView {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 8
        container.alignment = .fill
        container.isLayoutMarginsRelativeArrangement = true
        container.layoutMargins = UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0)

        let title = UILabel()
        title.text = "Any additional carbs"
        title.font = .nunitoMedium16
        title.textColor = .black

        additionalCarbsField.placeholder = "0"
        additionalCarbsField.keyboardType = .numberPad
        additionalCarbsField.font = .nunito16
        additionalCarbsField.text = calculator.additionalCarbs > 0 ? "\(calculator.additionalCarbs)" : ""
        additionalCarbsField.addTarget(self, action: #selector(additionalCarbsChanged), for: .editingChanged)

        let unit = UILabel()
        unit.text = "g"
        unit.font = .nunito16
        unit.textColor = .black
        unit.setContentHuggingPriority(.required, for: .horizontal)

        let row = UIStackView(arrangedSubviews: [additionalCarbsField, unit])
        row.axis = .horizontal
        row.spacing = 8
        row.alignment = .center
        row.isLayoutMarginsRelativeArrangement = true
        row.layoutMargins = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        row.backgroundColor = .systemBackground
        row.layer.cornerRadius = 8
        row.layer.cornerCurve = .continuous
        row.layer.borderWidth = 1
        row.layer.borderColor = UIColor.borderGrayColor.cgColor

        container.addArrangedSubview(title)
        container.addArrangedSubview(row)
        return container
    }

    @objc private func additionalCarbsChanged() {
        calculator.additionalCarbs = Int(additionalCarbsField.text ?? "") ?? 0
    }

    // MARK: - Insulin card

    private func setupCard() {
        // The fill runs into the home-indicator inset so the card reaches the
        // bottom of the screen, while its contents stay clear of it.
        cardView.cornerRadius = 24
        cardView.backgroundColor = .sunsetOrangeColor100
        cardView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cardView)

        cardStack.axis = .vertical
        cardStack.spacing = 16
        cardStack.alignment = .fill
        cardStack.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(cardStack)

        cardStack.addArrangedSubview(makeHandle())
        cardStack.addArrangedSubview(makeBreakdownRow())
        cardStack.addArrangedSubview(makeInsulinPanel())
        cardStack.addArrangedSubview(makeExitButton())

        NSLayoutConstraint.activate([
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            cardStack.topAnchor.constraint(equalTo: cardView.topAnchor),
            cardStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            cardStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            cardStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
    }

    private func makeHandle() -> UIView {
        let capsule = UIView()
        capsule.backgroundColor = .black
        capsule.layer.cornerRadius = 2
        capsule.translatesAutoresizingMaskIntoConstraints = false

        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(toggleBreakdown), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(capsule)

        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 28),
            capsule.widthAnchor.constraint(equalToConstant: 40),
            capsule.heightAnchor.constraint(equalToConstant: 4),
            capsule.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            capsule.centerYAnchor.constraint(equalTo: button.centerYAnchor)
        ])
        return button
    }

    @objc private func toggleBreakdown() {
        showBreakdown.toggle()
        UIView.animate(withDuration: 0.2) {
            self.breakdownRow.isHidden = !self.showBreakdown
            self.breakdownRow.alpha = self.showBreakdown ? 1 : 0
            self.view.layoutIfNeeded()
        }
    }

    private func makeBreakdownRow() -> UIView {
        totalCarbsLabel.font = .nunitoSemiBold32
        totalCarbsLabel.textColor = .black
        totalCarbsLabel.textAlignment = .center

        let totalColumn = makeColumn(
            valueView: totalCarbsLabel,
            title: "Total Carbs",
            action: #selector(showTotalCarbsInfo)
        )

        let slash = UILabel()
        slash.text = "/"
        slash.font = .nunitoBold32
        slash.textColor = .label
        slash.setContentHuggingPriority(.required, for: .horizontal)

        let slashHolder = UIView()
        slash.translatesAutoresizingMaskIntoConstraints = false
        slashHolder.addSubview(slash)
        
        // Bounded rather than pinned: pinning both edges fixes the label to the
        // holder's full width, which left the glyph sitting at its leading edge
        // and made `centerXAnchor` a no-op.
        NSLayoutConstraint.activate([
            slash.topAnchor.constraint(equalTo: slashHolder.topAnchor, constant: 8),
            slash.leadingAnchor.constraint(greaterThanOrEqualTo: slashHolder.leadingAnchor),
            slash.trailingAnchor.constraint(lessThanOrEqualTo: slashHolder.trailingAnchor),
            slash.centerXAnchor.constraint(equalTo: slashHolder.centerXAnchor),
            slash.bottomAnchor.constraint(lessThanOrEqualTo: slashHolder.bottomAnchor)
        ])

        carbRatioField.font = .nunitoSemiBold32
        carbRatioField.textColor = .black
        carbRatioField.tintColor = .choaGreenColor
        carbRatioField.keyboardType = .numberPad
        carbRatioField.textAlignment = .center
        carbRatioField.placeholder = "0"
        carbRatioField.addTarget(self, action: #selector(carbRatioChanged), for: .editingChanged)

        let ratioColumn = makeColumn(
            valueView: carbRatioField,
            title: "Carb Ratio",
            action: #selector(showCarbRatioInfo)
        )

        breakdownRow.axis = .horizontal
        breakdownRow.spacing = 12
        breakdownRow.alignment = .top
        breakdownRow.distribution = .fill
        breakdownRow.isLayoutMarginsRelativeArrangement = true
        breakdownRow.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        breakdownRow.addArrangedSubview(totalColumn)
        breakdownRow.addArrangedSubview(slashHolder)
        breakdownRow.addArrangedSubview(ratioColumn)

        // Each column is exactly as wide as its rule, so the holder between them
        // is the one view that stretches — which is what centres the slash
        // between the two columns.
        slashHolder.setContentHuggingPriority(.defaultLow, for: .horizontal)
        slashHolder.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        for column in [totalColumn, ratioColumn] {
            column.setContentHuggingPriority(.required, for: .horizontal)
            column.setContentCompressionResistancePriority(.required, for: .horizontal)
            column.widthAnchor.constraint(equalToConstant: Self.columnWidth).isActive = true
        }

        return breakdownRow
    }

    private func makeColumn(valueView: UIView, title: String, action: Selector) -> UIView {
        let rule = UIView()
        rule.backgroundColor = .black
        rule.layer.cornerRadius = 5 / 2
        rule.translatesAutoresizingMaskIntoConstraints = false
        rule.heightAnchor.constraint(equalToConstant: 5).isActive = true

        var config = UIButton.Configuration.plain()
        config.title = title
        config.image = UIImage(named: "ic_info")
        config.imagePlacement = .trailing
        config.imagePadding = 4
        config.contentInsets = .zero
        config.baseForegroundColor = .black
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var out = incoming
            out.font = .nunitoSemiBold18
            return out
        }
        
        let titleButton = UIButton(configuration: config)
        titleButton.addTarget(self, action: action, for: .touchUpInside)

        let column = UIStackView(arrangedSubviews: [valueView, rule, titleButton])
        column.axis = .vertical
        column.spacing = 6
        column.alignment = .fill
        return column
    }

    private func makeInsulinPanel() -> UIView {
        var config = UIButton.Configuration.plain()
        config.title = "Insulin for food"
        config.image = UIImage(named: "ic_info")
        config.imagePlacement = .trailing
        config.imagePadding = 6
        config.contentInsets = .zero
        config.baseForegroundColor = .white
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var out = incoming
            out.font = .nunitoSemiBold20
            return out
        }
        let titleButton = UIButton(configuration: config)
        titleButton.contentHorizontalAlignment = .leading
        titleButton.addTarget(self, action: #selector(showInsulinInfo), for: .touchUpInside)

        insulinUnitsLabel.font = .nunitoBold32
        insulinUnitsLabel.textColor = .white

        let stack = UIStackView(arrangedSubviews: [titleButton, insulinUnitsLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .leading
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        stack.backgroundColor = .sunsetOrangeColor400
        stack.layer.cornerRadius = 16
        stack.layer.cornerCurve = .continuous

        let holder = UIView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        holder.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: holder.topAnchor),
            stack.bottomAnchor.constraint(equalTo: holder.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: holder.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: holder.trailingAnchor, constant: -20)
        ])
        return holder
    }

    private func makeExitButton() -> UIView {
        var config = UIButton.Configuration.plain()
        config.title = "Exit"
        config.image = UIImage(named: "close_black")
        config.imagePlacement = .trailing
        config.imagePadding = 6
        config.baseForegroundColor = .black
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var out = incoming
            out.font = .nunitoBold16
            return out
        }
        let button = UIButton(configuration: config)
        button.addTarget(self, action: #selector(exitTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 47).isActive = true
        return button
    }

    // MARK: - Values

    /// Left empty when nothing has been saved, rather than assuming a ratio:
    /// a made-up default would silently produce a real-looking insulin dose.
    /// `viewDidAppear` focuses the field instead so the user supplies it.
    private func loadCarbRatio() {
        let saved = CalculatorConstantsManager.shared.carbRatio
        carbRatioField.text = saved > 0 ? String(saved) : ""
    }

    @objc private func carbRatioChanged() {
        if let ratio = Int(carbRatioField.text ?? ""), ratio > 0 {
            CalculatorConstantsManager.shared.carbRatio = ratio
        }
        refreshValues()
    }

    private func refreshValues() {
        totalCarbsLabel.text = "\(calculator.totalCarbs)"
        // `insulinUnits` already guards against a zero ratio, but "0 units"
        // reads as a real answer — show a dash until there is a ratio to divide by.
        insulinUnitsLabel.text = carbRatio > 0 ? "\(insulinUnits.cleanCarbString) units" : "— units"
    }

    // MARK: - Actions

    @objc private func showTotalCarbsInfo() { show(.totalCarbs) }
    @objc private func showCarbRatioInfo() { show(.carbRatio) }
    @objc private func showInsulinInfo() { show(.insulinForFood) }

    private func show(_ topic: CarbsInfoTopic) {
        infoPopup.appear(sender: self, title: topic.title, details: topic.details)
    }

    @objc private func exitTapped() {
        navigationController?.popToRootViewController(animated: true)
    }

    private func setupDismissKeyboardGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        // The carb-ratio field uses a number pad, which has no return key. The
        // touch is still delivered onward so the buttons keep responding to the
        // same tap.
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - Info Topics

/// Titles are matched by `InfoPopUpViewController` to pick its bold phrases,
/// so they must stay the localized values it switches on.
private enum CarbsInfoTopic {
    case totalCarbs
    case carbRatio
    case insulinForFood

    var title: String {
        switch self {
        case .totalCarbs: return "PopupInfo.TotalCarbs.title".localized()
        case .carbRatio: return "PopupInfo.CarbRatio.title".localized()
        case .insulinForFood: return "PopupInfo.InsulinForFood.title".localized()
        }
    }

    var details: String {
        switch self {
        case .totalCarbs: return "PopupInfo.TotalCarbs.text".localized()
        case .carbRatio: return "PopupInfo.CarbRatio.text".localized()
        case .insulinForFood: return "PopupInfo.InsulinForFood.text".localized()
        }
    }
}

private extension Double {
    var cleanCarbString: String {
        truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(format: "%.1f", self)
    }
}

#if DEBUG
import SwiftUI

private struct KnowYourCarbsResultViewControllerPreview: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UINavigationController {
        UINavigationController(rootViewController: KnowYourCarbsResultViewController())
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
}

struct KnowYourCarbsResultViewController_Previews: PreviewProvider {
    static var previews: some View {
        KnowYourCarbsResultViewControllerPreview()
    }
}
#endif
