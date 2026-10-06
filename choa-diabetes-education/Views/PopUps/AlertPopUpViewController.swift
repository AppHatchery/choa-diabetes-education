//
//  AlertPopUpViewController.swift
//  choa-diabetes-education
//

import UIKit

/// A custom alert shown over a blurred background with a filled primary
/// action and a text-only secondary action.
class AlertPopUpViewController: UIViewController {

    private let titleText: String
    private let messageText: String
    private let primaryActionTitle: String
    private let secondaryActionTitle: String
    private let tintColor: UIColor
    private let cardColor: UIColor

    var onPrimaryAction: (() -> Void)?
    var onSecondaryAction: (() -> Void)?

    private let blurView = UIVisualEffectView(effect: nil)
    private let cardView = UIView()

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
        self.modalPresentationStyle = .overFullScreen
        self.modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupBlurView()
        setupCardView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIView.animate(withDuration: 0.25) {
            self.blurView.effect = UIBlurEffect(style: .light)
        }
    }

    // MARK: - Layout

    private func setupBlurView() {
        blurView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(blurView)

        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: view.topAnchor),
            blurView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            blurView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func setupCardView() {
        cardView.backgroundColor = cardColor
        cardView.layer.cornerRadius = 12
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

        NSLayoutConstraint.activate([
            cardView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            cardView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
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
        sender.present(self, animated: true)
    }

    private func hide(completion: (() -> Void)?) {
        UIView.animate(withDuration: 0.2) {
            self.blurView.effect = nil
        }
        dismiss(animated: true, completion: completion)
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
