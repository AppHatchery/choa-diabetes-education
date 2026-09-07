//
//  CarbFoodTableViewCell.swift
//  choa-diabetes-education
//
//  Created by Maxwell Kapezi Jr on 26/08/2026.
//

import UIKit
import Combine
import SwiftUI

/// A plain UIKit row. It was previously a `CarbFoodRowView` in a hosting
/// controller, which has no intrinsic content size of its own — the self-sizing
/// cell had nothing to measure, so rows kept their estimated height while the
/// content drew at full size and spilled onto the row below. Ordinary labels
/// report their own height, so the cell simply sizes to its constraints.
class CarbFoodTableViewCell: UITableViewCell {
    static let reuseIdentifier = "CarbFoodTableViewCell"

    /// Horizontal inset applied to the row's content inside the cell, each side.
    static let horizontalInset: CGFloat = 16

    /// Width the stepper always occupies, whatever its state, so that a
    /// quantity appearing never changes how the name wraps.
    private static let stepperWidth: CGFloat = 104

    private static let verticalInset: CGFloat = 12
    private static let thumbnailSize: CGFloat = 64

    private let thumbnail = UIImageView()
    private let nameLabel = UILabel()
    private let servingLabel = UILabel()
    private let carbsLabel = UILabel()
    private let separator = UIView()

    private let stepperContainer = UIView()
    private let stepperStack = UIStackView()
    private let minusButton = UIButton(type: .system)
    private let plusButton = UIButton(type: .system)
    private let quantityLabel = UILabel()

    private var food: CarbFood?
    private var cancellable: AnyCancellable?

    private let calculator = CarbsCalculatorManager.shared

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// `parent` is unused now that the row is UIKit — no hosting controller
    /// needs adopting — but it is kept so the call site stays unchanged.
    func configure(with food: CarbFood, parent: UIViewController) {
        self.food = food

        thumbnail.image = UIImage(named: food.imageName)
        nameLabel.text = food.name
        servingLabel.text = food.servingSize
        carbsLabel.text = "\(food.carbGrams)g"

        updateStepper()

        // The stepper reflects shared state, so it has to follow changes made
        // anywhere else — the results screen included.
        cancellable = calculator.$quantities
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateStepper()
            }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        cancellable = nil
        food = nil
        thumbnail.image = nil
    }

    // MARK: - Setup

    private func setupViews() {
        selectionStyle = .none
        backgroundColor = .clear

        thumbnail.contentMode = .scaleAspectFill
        thumbnail.clipsToBounds = true
        thumbnail.layer.cornerRadius = 12
        thumbnail.layer.cornerCurve = .continuous
        thumbnail.translatesAutoresizingMaskIntoConstraints = false

        nameLabel.font = .nunitoBold16
        nameLabel.textColor = .black
        nameLabel.numberOfLines = 0

        servingLabel.font = .nunito14
        servingLabel.textColor = .contentBlackColor
        servingLabel.numberOfLines = 0

        carbsLabel.font = .nunitoBold20
        carbsLabel.textColor = .primaryBlue
        carbsLabel.numberOfLines = 1

        let textStack = UIStackView(arrangedSubviews: [nameLabel, servingLabel, carbsLabel])
        textStack.axis = .vertical
        textStack.spacing = 2
        textStack.alignment = .leading
        textStack.translatesAutoresizingMaskIntoConstraints = false

        // The labels, not the image or the stepper, decide how tall the row is.
        textStack.setContentCompressionResistancePriority(.required, for: .vertical)
        textStack.setContentHuggingPriority(.defaultHigh, for: .vertical)

        setupStepper()

        separator.backgroundColor = .systemGray5
        separator.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(thumbnail)
        contentView.addSubview(textStack)
        contentView.addSubview(stepperContainer)
        contentView.addSubview(separator)

        let inset = Self.horizontalInset
        let vertical = Self.verticalInset

        // Each column is centred and merely required to fit within the vertical
        // insets; the tallest one therefore sets the cell's height.
        NSLayoutConstraint.activate([
            thumbnail.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: inset),
            thumbnail.widthAnchor.constraint(equalToConstant: Self.thumbnailSize),
            thumbnail.heightAnchor.constraint(equalToConstant: Self.thumbnailSize),
            thumbnail.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            thumbnail.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: vertical),
            thumbnail.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -vertical),

            textStack.leadingAnchor.constraint(equalTo: thumbnail.trailingAnchor, constant: 16),
            textStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            textStack.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: vertical),
            textStack.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -vertical),

            stepperContainer.leadingAnchor.constraint(equalTo: textStack.trailingAnchor, constant: 16),
            stepperContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -inset),
            stepperContainer.widthAnchor.constraint(equalToConstant: Self.stepperWidth),
            stepperContainer.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            stepperContainer.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: vertical),
            stepperContainer.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -vertical),

            separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: inset),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -inset),
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1)
        ])
    }

    private func setupStepper() {
        stepperContainer.translatesAutoresizingMaskIntoConstraints = false

        stepperStack.axis = .horizontal
        stepperStack.alignment = .center
        stepperStack.translatesAutoresizingMaskIntoConstraints = false
        stepperStack.backgroundColor = .systemGray6
        stepperStack.layer.cornerRadius = 6
        stepperStack.layer.cornerCurve = .continuous
        stepperStack.clipsToBounds = true
        stepperStack.isLayoutMarginsRelativeArrangement = true

        quantityLabel.font = .systemFont(ofSize: 17, weight: .bold)
        quantityLabel.textColor = .primaryBlue
        quantityLabel.textAlignment = .center

        configure(stepperButton: minusButton, systemName: "minus", action: #selector(decrementTapped))
        configure(stepperButton: plusButton, systemName: "plus", action: #selector(incrementTapped))

        stepperStack.addArrangedSubview(minusButton)
        stepperStack.addArrangedSubview(quantityLabel)
        stepperStack.addArrangedSubview(plusButton)

        stepperContainer.addSubview(stepperStack)

        // Pinned trailing so the control keeps its right edge as it grows.
        NSLayoutConstraint.activate([
            stepperStack.trailingAnchor.constraint(equalTo: stepperContainer.trailingAnchor),
            stepperStack.topAnchor.constraint(equalTo: stepperContainer.topAnchor),
            stepperStack.bottomAnchor.constraint(equalTo: stepperContainer.bottomAnchor),
            stepperStack.leadingAnchor.constraint(greaterThanOrEqualTo: stepperContainer.leadingAnchor),
            quantityLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 16)
        ])
    }

    private func configure(stepperButton button: UIButton, systemName: String, action: Selector) {
        button.setImage(
            UIImage(systemName: systemName, withConfiguration: UIImage.SymbolConfiguration(pointSize: 15, weight: .bold)),
            for: .normal
        )
        button.tintColor = .contentBlackColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: action, for: .touchUpInside)

        // The glyphs (especially "minus") are far smaller than a usable tap
        // target, so give every stepper button the same square area.
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 18),
            button.heightAnchor.constraint(equalToConstant: 18)
        ])
    }

    // MARK: - Stepper state

    private func updateStepper() {
        guard let food else { return }
        let quantity = calculator.quantity(for: food)

        if quantity > 0 {
            minusButton.isHidden = false
            quantityLabel.isHidden = false
            quantityLabel.text = "\(quantity)"
            stepperStack.spacing = 10
            stepperStack.layoutMargins = UIEdgeInsets(top: 6, left: 8, bottom: 6, right: 8)
        } else {
            minusButton.isHidden = true
            quantityLabel.isHidden = true
            stepperStack.spacing = 0
            stepperStack.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        }
    }

    @objc private func incrementTapped() {
        guard let food else { return }
        calculator.increment(food)
    }

    @objc private func decrementTapped() {
        guard let food else { return }
        calculator.decrement(food)
    }
}

#if DEBUG
private struct CarbFoodTableViewCellPreview: UIViewRepresentable {
    func makeUIView(context: Context) -> UITableViewCell {
        let cell = CarbFoodTableViewCell(style: .default, reuseIdentifier: nil)
        let previewFood = CarbFood(
            name: "Banana and mashed banana potatoes",
            servingSize: "1 medium",
            carbGrams: 27,
            imageName: "im_banana"
        )

        cell.configure(with: previewFood, parent: UIViewController())
        return cell
    }

    func updateUIView(_ uiView: UITableViewCell, context: Context) {}
}

struct CarbFoodTableViewCell_Previews: PreviewProvider {
    static var previews: some View {
        CarbFoodTableViewCellPreview()
            .previewLayout(.sizeThatFits)
    }
}
#endif
