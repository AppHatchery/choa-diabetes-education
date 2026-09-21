//
//  CarbFoodRowView.swift
//  choa-diabetes-education
//
//  Created by Maxwell Kapezi Jr on 26/08/2026.
//

import UIKit
import Combine

/// One food row: thumbnail, name/serving/carbs, and a quantity stepper.
///
/// This was a SwiftUI `View` hosted in a `UIHostingController`. A hosting view
/// reports no intrinsic content size, so a self-sizing cell had nothing to
/// measure: rows kept their estimated height while the content drew at full
/// size and spilled onto the row below. Ordinary UIKit views report their own
/// height, so the row simply sizes to its constraints.
final class CarbFoodRowView: UIView {

    /// Horizontal inset applied to the row inside its container, on each side.
    static let horizontalInset: CGFloat = 16

    /// Width the stepper always occupies, whatever its state, so a quantity
    /// appearing never changes how the name wraps.
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

    /// The food list draws a divider under every row; the results screen does not.
    var showsSeparator: Bool = true {
        didSet { separator.isHidden = !showsSeparator }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    func configure(with food: CarbFood) {
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

    func prepareForReuse() {
        cancellable = nil
        food = nil
        thumbnail.image = nil
    }

    // MARK: - Setup

    private func setupViews() {
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

        addSubview(thumbnail)
        addSubview(textStack)
        addSubview(stepperContainer)
        addSubview(separator)

        let vertical = Self.verticalInset

        // Each column is centred and merely required to fit within the vertical
        // insets, so the tallest one sets the row's height.
        NSLayoutConstraint.activate([
            thumbnail.leadingAnchor.constraint(equalTo: leadingAnchor),
            thumbnail.widthAnchor.constraint(equalToConstant: Self.thumbnailSize),
            thumbnail.heightAnchor.constraint(equalToConstant: Self.thumbnailSize),
            thumbnail.centerYAnchor.constraint(equalTo: centerYAnchor),
            thumbnail.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: vertical),
            thumbnail.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -vertical),

            textStack.leadingAnchor.constraint(equalTo: thumbnail.trailingAnchor, constant: 16),
            textStack.centerYAnchor.constraint(equalTo: centerYAnchor),
            textStack.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: vertical),
            textStack.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -vertical),

            stepperContainer.leadingAnchor.constraint(equalTo: textStack.trailingAnchor, constant: 16),
            stepperContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            stepperContainer.widthAnchor.constraint(equalToConstant: Self.stepperWidth),
            stepperContainer.centerYAnchor.constraint(equalTo: centerYAnchor),
            stepperContainer.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: vertical),
            stepperContainer.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -vertical),

            separator.leadingAnchor.constraint(equalTo: leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1)
        ])
    }

    private func setupStepper() {
        stepperContainer.translatesAutoresizingMaskIntoConstraints = false

        stepperStack.axis = .horizontal
        stepperStack.alignment = .center
        stepperStack.translatesAutoresizingMaskIntoConstraints = false
        stepperStack.backgroundColor = .blue050
        stepperStack.layer.cornerRadius = 4
        stepperStack.layer.cornerCurve = .continuous
        stepperStack.clipsToBounds = true
        stepperStack.isLayoutMarginsRelativeArrangement = true

        quantityLabel.font = .nunitoSemiBold20
        quantityLabel.textColor = .primaryBlue
        quantityLabel.textAlignment = .center

        configure(stepperButton: minusButton, image: "minus", action: #selector(decrementTapped))
        configure(stepperButton: plusButton, image: "plus", action: #selector(incrementTapped))

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

    private func configure(stepperButton button: UIButton, image: String, action: Selector) {
        button.setImage(
            UIImage(
                systemName: image,
                withConfiguration: UIImage
                    .SymbolConfiguration(pointSize: 16, weight: .semibold)
            ),
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
        triggerLightHaptic()
        calculator.increment(food)
    }

    @objc private func decrementTapped() {
        guard let food else { return }
        triggerLightHaptic()
        calculator.decrement(food)
    }

    private func triggerLightHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred(intensity: 0.4)
    }
}

// MARK: - Category Header

/// Category heading above each group of foods.
final class CarbCategoryHeaderView: UIView {
    private let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .backgroundColor

        titleLabel.font = .nunitoMedium20
        titleLabel.textColor = .primaryBlue
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(title: String) {
        titleLabel.text = title.uppercased()
    }
}

#if DEBUG
import SwiftUI

/// Previews are the one place SwiftUI remains: it is the only way Xcode renders
/// a canvas preview, and this wrapper is compiled out of release builds.
private struct CarbFoodRowViewPreview: UIViewRepresentable {
    let food: CarbFood

    func makeUIView(context: Context) -> CarbFoodRowView {
        let view = CarbFoodRowView()
        view.configure(with: food)
        return view
    }

    func updateUIView(_ uiView: CarbFoodRowView, context: Context) {}
}

struct CarbFoodRowView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {
            CarbFoodRowViewPreview(
                food: CarbFood(
                    name: "Bread",
                    servingSize: "per slice",
                    carbGrams: 15,
                    imageName: "im_white_bread"
                )
            )
            CarbFoodRowViewPreview(
                food: CarbFood(
                    name: "Homemade Banana and Mashed Sweet Potato Breakfast Casserole",
                    servingSize: "1 large serving dish portion",
                    carbGrams: 47,
                    imageName: "croissant"
                )
            )
        }
        .padding(.horizontal, CarbFoodRowView.horizontalInset)
        .previewLayout(.sizeThatFits)
    }
}
#endif
