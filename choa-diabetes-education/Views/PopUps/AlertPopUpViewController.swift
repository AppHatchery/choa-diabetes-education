//
//  AlertPopUpViewController.swift
//  choa-diabetes-education
//

import UIKit

/// A custom alert shown as a card over the dimmed current screen, with a filled
/// primary action and a text-only secondary action.
class AlertPopUpViewController: UIViewController {

    private let titleText: String
    private let messageText: String
    private let primaryActionTitle: String
    private let secondaryActionTitle: String
    private let tintColor: UIColor
    private let cardColor: UIColor

    var onPrimaryAction: (() -> Void)?
    var onSecondaryAction: (() -> Void)?

    /// Dims the presenting screen so it stays visible behind the card
    private let dimmingView = UIView()
    private let cardView = UIView()

    /// Keeps the card a pop-up size on wide screens instead of stretching edge to edge
    private static let maxCardWidth: CGFloat = 400

    init(title: String,
         message: String,
         primaryActionTitle: String,
         secondaryActionTitle: String,
         tintColor: UIColor = .secondaryRedColor,
         cardColor: UIColor = .veryLightRed) {
        self.titleText = title
        self.messageText = message
        self.primaryActionTitle = primaryActionTitle
        self.secondaryActionTitle = secondaryActionTitle
        self.tintColor = tintColor
        self.cardColor = cardColor
        super.init(nibName: nil, bundle: nil)
        // Keep the presenting screen underneath; the dim and pop-in are animated here instead of by UIKit
        self.modalPresentationStyle = .overFullScreen
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupDimmingView()
        setupCardView()

        // Start hidden and slightly shrunk, then pop in once presented
        dimmingView.alpha = 0
        cardView.alpha = 0
        cardView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0.5) {
            self.dimmingView.alpha = 1
            self.cardView.alpha = 1
            self.cardView.transform = .identity
        }
    }

    // MARK: - Layout

    private func setupDimmingView() {
        dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        dimmingView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dimmingView)

        NSLayoutConstraint.activate([
            dimmingView.topAnchor.constraint(equalTo: view.topAnchor),
            dimmingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dimmingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimmingView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func setupCardView() {
        cardView.backgroundColor = cardColor
        cardView.layer.cornerRadius = 16
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.2
        cardView.layer.shadowRadius = 16
        cardView.layer.shadowOffset = CGSize(width: 0, height: 8)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        // Keep VoiceOver focus inside the alert while it's showing
        cardView.accessibilityViewIsModal = true
        view.addSubview(cardView)

        let titleLabel = UILabel()
        titleLabel.text = titleText
        titleLabel.font = scaledFont(name: "Nunito-SemiBold", size: 20, textStyle: .title3)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.textColor = tintColor
        titleLabel.numberOfLines = 0
        titleLabel.accessibilityTraits = .header

        let messageLabel = UILabel()
        messageLabel.text = messageText
        messageLabel.font = scaledFont(name: "Nunito-Regular", size: 16, textStyle: .body)
        messageLabel.adjustsFontForContentSizeCategory = true
        messageLabel.textColor = .black
        messageLabel.numberOfLines = 0

        let primaryButton = UIButton(type: .system)
        var primaryConfig = UIButton.Configuration.filled()
        primaryConfig.baseBackgroundColor = tintColor
        primaryConfig.baseForegroundColor = .white
        primaryConfig.cornerStyle = .fixed
        primaryConfig.background.cornerRadius = 12
        primaryConfig.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
        primaryConfig.attributedTitle = attributedTitle(primaryActionTitle)
        primaryButton.configuration = primaryConfig
        primaryButton.addTarget(self, action: #selector(primaryButtonTapped), for: .touchUpInside)

        let secondaryButton = UIButton(type: .system)
        var secondaryConfig = UIButton.Configuration.plain()
        secondaryConfig.baseForegroundColor = tintColor
        secondaryConfig.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
        secondaryConfig.attributedTitle = attributedTitle(secondaryActionTitle)
        secondaryButton.configuration = secondaryConfig
        secondaryButton.addTarget(self, action: #selector(secondaryButtonTapped), for: .touchUpInside)

        let textStack = UIStackView(arrangedSubviews: [titleLabel, messageLabel])
        textStack.axis = .vertical
        textStack.spacing = 16

        let buttonStack = UIStackView(arrangedSubviews: [primaryButton, secondaryButton])
        buttonStack.axis = .vertical
        buttonStack.spacing = 8

        let mainStack = UIStackView(arrangedSubviews: [textStack, buttonStack])
        mainStack.axis = .vertical
        mainStack.spacing = 32
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(mainStack)

        // Fills the width minus margins on phones, but never wider than the max on larger screens
        let preferredWidth = cardView.widthAnchor.constraint(equalToConstant: Self.maxCardWidth)
        preferredWidth.priority = .defaultHigh

        NSLayoutConstraint.activate([
            cardView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cardView.leadingAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            cardView.trailingAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            preferredWidth,
            cardView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cardView.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            cardView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),

            mainStack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 24),
            mainStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            mainStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -24),
            mainStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16),

            primaryButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 48)
        ])
    }

    private func scaledFont(name: String, size: CGFloat, textStyle: UIFont.TextStyle) -> UIFont {
        let font = UIFont(name: name, size: size) ?? .systemFont(ofSize: size)
        return UIFontMetrics(forTextStyle: textStyle).scaledFont(for: font)
    }

    private func attributedTitle(_ title: String) -> AttributedString {
        var attributed = AttributedString(title)
        attributed.font = scaledFont(name: "Nunito-Medium", size: 20, textStyle: .headline)
        return attributed
    }

    // MARK: - Presentation

    func appear(sender: UIViewController) {
        sender.present(self, animated: false)
    }

    private func hide(completion: (() -> Void)?) {
        UIView.animate(withDuration: 0.2, animations: {
            self.dimmingView.alpha = 0
            self.cardView.alpha = 0
            self.cardView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }, completion: { _ in
            self.dismiss(animated: false, completion: completion)
        })
    }

    // MARK: - Actions

    @objc private func primaryButtonTapped() {
        hide(completion: onPrimaryAction)
    }

    @objc private func secondaryButtonTapped() {
        hide(completion: onSecondaryAction)
    }
}

#Preview {
    AlertPopUpViewController(
        title: "Blood sugar is below 70",
        message: "That's too low to be a high blood sugar it might be hypoglycemia instead",
        primaryActionTitle: "Choose a different sysmptom",
        secondaryActionTitle: "Continue with hyperglycemia"
    )
}
