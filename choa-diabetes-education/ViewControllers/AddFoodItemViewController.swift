//
//  AddFoodItemViewController.swift
//  choa-diabetes-education
//
//  Created by Maxwell Kapezi Jr on 27/08/2026.
//

import UIKit

class AddFoodItemViewController: UIViewController {

    private let customFoods = CustomFoodsManager.shared

    private let scrollView = UIScrollView()
    private var addButtonBottomConstraint: NSLayoutConstraint!
    private weak var activeField: UITextField?

    private let nameField = UITextField()
    private let carbValueField = UITextField()
    private let portionSizeField = UITextField()
    private let categoryButton = UIButton(type: .system)
    private let categoryLabel = UILabel()
    private let nameTakenLabel = UILabel()
    private let addButton = UIButton(type: .system)

    private var categoryTitle: String? {
        didSet { categoryLabel.text = categoryTitle ?? "" }
    }

    private var carbGrams: Int? {
        Int((carbValueField.text ?? "").trimmingCharacters(in: .whitespaces))
    }

    private var nameIsTaken: Bool {
        let trimmed = (nameField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty && !customFoods.nameIsAvailable(trimmed)
    }

    private var canSubmit: Bool {
        !(nameField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !nameIsTaken
            && (carbGrams.map { $0 >= 0 } ?? false)
            && !(portionSizeField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && categoryTitle != nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        navigationItem.backButtonDisplayMode = .minimal

        let closeButton = UIBarButtonItem(
            image: UIImage(named: "close_black"),
            style: .plain,
            target: self,
            action: #selector(closeTapped)
        )
        
        closeButton.tintColor = .black
        navigationItem.rightBarButtonItem = closeButton

        setupForm()
        setupDismissKeyboardGesture()
        observeKeyboard()
        updateSubmitState()
    }

    // MARK: - Form

    private func setupForm() {
        let heading = UILabel()
        heading.text = "Add an Item"
        heading.font = .nunitoSemiBold20
        heading.textColor = .primaryBlue

        carbValueField.keyboardType = .numberPad

        for field in [nameField, carbValueField, portionSizeField] {
            field.font = .nunitoSemiBold20
            field.addTarget(self, action: #selector(fieldChanged), for: .editingChanged)
            field.addTarget(self, action: #selector(fieldBeganEditing), for: .editingDidBegin)
            field.tintColor = .choaGreenColor
        }

        nameTakenLabel.text = "An item with this name already exists."
        nameTakenLabel.font = UIFont(name: "Nunito-Regular", size: 13) ?? .nunito14
        nameTakenLabel.textColor = .errorRedColor
        nameTakenLabel.numberOfLines = 0
        nameTakenLabel.isHidden = true

        let gramsLabel = UILabel()
        gramsLabel.text = "g"
        gramsLabel.font = .nunitoSemiBold20
        gramsLabel.textColor = .black
        gramsLabel.setContentHuggingPriority(.required, for: .horizontal)

        let carbRow = UIStackView(arrangedSubviews: [carbValueField, gramsLabel])
        carbRow.axis = .horizontal
        carbRow.spacing = 8
        carbRow.alignment = .center

        let formStack = UIStackView(arrangedSubviews: [
            heading,
            makeIcon(),
            makeField(title: "Item name", content: nameField),
            nameTakenLabel,
            makeField(title: "Carb value", content: carbRow),
            makeField(title: "Portion size", content: portionSizeField),
            makeCategoryPicker()
        ])
        formStack.axis = .vertical
        formStack.spacing = 20
        formStack.alignment = .fill
        formStack.isLayoutMarginsRelativeArrangement = true
        formStack.layoutMargins = UIEdgeInsets(top: 8, left: 20, bottom: 24, right: 20)
        formStack.translatesAutoresizingMaskIntoConstraints = false

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.keyboardDismissMode = .interactive
        scrollView.addSubview(formStack)
        view.addSubview(scrollView)

        setupAddButton()

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -16),

            formStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            formStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            formStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            formStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            formStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
    }

    private func makeIcon() -> UIView {
        let imageView = UIImageView(image: UIImage(named: CustomFoodsManager.iconName))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false

        let badge = UIView()
        badge.backgroundColor = .sunsetOrangeColor100
        badge.layer.cornerRadius = 16
        badge.layer.cornerCurve = .continuous
        badge.translatesAutoresizingMaskIntoConstraints = false
        badge.addSubview(imageView)

        let holder = UIView()
        holder.addSubview(badge)

        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 56),
            imageView.heightAnchor.constraint(equalToConstant: 56),
            imageView.topAnchor.constraint(equalTo: badge.topAnchor, constant: 12),
            imageView.bottomAnchor.constraint(equalTo: badge.bottomAnchor, constant: -12),
            imageView.leadingAnchor.constraint(equalTo: badge.leadingAnchor, constant: 12),
            imageView.trailingAnchor.constraint(equalTo: badge.trailingAnchor, constant: -12),

            badge.topAnchor.constraint(equalTo: holder.topAnchor),
            badge.bottomAnchor.constraint(equalTo: holder.bottomAnchor),
            badge.centerXAnchor.constraint(equalTo: holder.centerXAnchor)
        ])
        return holder
    }

    private func makeField(title: String, content: UIView) -> UIView {
        let label = UILabel()
        label.text = title
        label.font = .nunitoSemiBold18
        label.textColor = .black

        let box = UIView()
        box.layer.cornerRadius = 8
        box.layer.cornerCurve = .continuous
        box.layer.borderWidth = 1
        box.layer.borderColor = UIColor.borderGrayColor.cgColor
        content.translatesAutoresizingMaskIntoConstraints = false
        box.addSubview(content)

        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: box.topAnchor, constant: 14),
            content.bottomAnchor.constraint(equalTo: box.bottomAnchor, constant: -14),
            content.leadingAnchor.constraint(equalTo: box.leadingAnchor, constant: 14),
            content.trailingAnchor.constraint(equalTo: box.trailingAnchor, constant: -14)
        ])

        let stack = UIStackView(arrangedSubviews: [label, box])
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .fill
        return stack
    }

    private func makeCategoryPicker() -> UIView {
        categoryLabel.font = .nunito16
        categoryLabel.textColor = .black

        let chevron = UIImageView(
            image: UIImage(
                systemName: "chevron.down",
                withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
            )
        )
        chevron.tintColor = .black
        chevron.setContentHuggingPriority(.required, for: .horizontal)

        let row = UIStackView(arrangedSubviews: [categoryLabel, chevron])
        row.axis = .horizontal
        row.alignment = .center
        row.isUserInteractionEnabled = false

        let field = makeField(title: "Item category", content: row)

        // A UIMenu on a button is the UIKit equivalent of SwiftUI's `Menu`.
        categoryButton.menu = UIMenu(children: customFoods.categoryTitles.map { title in
            UIAction(title: title) { [weak self] _ in
                self?.categoryTitle = title
                self?.updateSubmitState()
            }
        })
        categoryButton.showsMenuAsPrimaryAction = true
        categoryButton.translatesAutoresizingMaskIntoConstraints = false
        field.addSubview(categoryButton)

        NSLayoutConstraint.activate([
            categoryButton.topAnchor.constraint(equalTo: field.topAnchor),
            categoryButton.leadingAnchor.constraint(equalTo: field.leadingAnchor),
            categoryButton.trailingAnchor.constraint(equalTo: field.trailingAnchor),
            categoryButton.bottomAnchor.constraint(equalTo: field.bottomAnchor)
        ])
        return field
    }

    private func setupAddButton() {
        var config = UIButton.Configuration.plain()
        config.title = "Add item"
        config.baseForegroundColor = .white
        config.background.backgroundColor = .choaGreenColor
        config.background.cornerRadius = 12
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var out = incoming
            out.font = .nunitoBold20
            return out
        }
        addButton.configuration = config
        addButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(addButton)

        addButtonBottomConstraint = addButton.bottomAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.bottomAnchor,
            constant: -16
        )

        NSLayoutConstraint.activate([
            addButton.heightAnchor.constraint(equalToConstant: 47),
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButtonBottomConstraint
        ])
    }

    // MARK: - State

    @objc private func fieldChanged() {
        updateSubmitState()
    }

    private func updateSubmitState() {
        nameTakenLabel.isHidden = !nameIsTaken

        // Dimmed rather than `isEnabled = false`: the disabled state would also
        // grey the title, leaving it barely legible on the green fill.
        addButton.isUserInteractionEnabled = canSubmit
        addButton.alpha = canSubmit ? 1 : 0.5
    }

    // MARK: - Actions

    @objc private func addTapped() {
        guard let carbGrams, let categoryTitle else { return }

        customFoods.addFood(
            name: (nameField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines),
            carbGrams: carbGrams,
            servingSize: (portionSizeField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines),
            categoryTitle: categoryTitle
        )
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Keyboard

    private func observeKeyboard() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillChangeFrame),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc private func fieldBeganEditing(_ sender: UITextField) {
        activeField = sender
    }

    /// The Add button sits above the keyboard and the scroll view is pinned to
    /// its top, so lifting the button lifts the whole form with it.
    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }

        let overlap = max(0, view.bounds.maxY - view.convert(frame, from: nil).minY)
        // The button already clears the home indicator; only the extra height
        // the keyboard adds beyond that inset needs taking up.
        let lift = max(0, overlap - view.safeAreaInsets.bottom)

        animateAlongsideKeyboard(notification) {
            self.addButtonBottomConstraint.constant = -16 - lift
            self.view.layoutIfNeeded()
        } completion: {
            self.scrollActiveFieldIntoView()
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        animateAlongsideKeyboard(notification) {
            self.addButtonBottomConstraint.constant = -16
            self.view.layoutIfNeeded()
        } completion: {}
    }

    private func scrollActiveFieldIntoView() {
        guard let activeField, let container = activeField.superview else { return }
        // The bordered box, not the bare field, so its label and outline show too.
        let target = container.convert(container.bounds.insetBy(dx: 0, dy: -12), to: scrollView)
        scrollView.scrollRectToVisible(target, animated: true)
    }

    private func animateAlongsideKeyboard(
        _ notification: Notification,
        _ animations: @escaping () -> Void,
        completion: @escaping () -> Void
    ) {
        let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.25
        let curveRaw = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int ?? 7

        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: UIView.AnimationOptions(rawValue: UInt(curveRaw << 16)),
            animations: animations,
            completion: { _ in completion() }
        )
    }

    private func setupDismissKeyboardGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        // The carb-value field uses a number pad, which has no return key. The
        // touch is still delivered onward so the form's fields, category menu
        // and Add button keep responding to the same tap.
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func closeTapped() {
        navigationController?.popViewController(animated: true)
    }
}

#if DEBUG
import SwiftUI

private struct AddFoodItemViewControllerPreview: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UINavigationController {
        UINavigationController(rootViewController: AddFoodItemViewController())
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
}

struct AddFoodItemViewController_Previews: PreviewProvider {
    static var previews: some View {
        AddFoodItemViewControllerPreview()
    }
}
#endif
