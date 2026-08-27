//
//  AddFoodItemViewController.swift
//  choa-diabetes-education
//
//  Created by Maxwell Kapezi Jr on 27/08/2026.
//

import UIKit
import SwiftUI

class AddFoodItemViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        navigationItem.backButtonDisplayMode = .minimal
        
        let navigationBar = UINavigationBar()
        navigationBar.scrollEdgeAppearance = navigationController?.navigationBar.standardAppearance
        navigationBar.isTranslucent = false
        
        

        let closeButton = UIBarButtonItem(
            image: UIImage(named: "close_black"),
            style: .plain,
            target: self,
            action: #selector(closeTapped)
        )
        closeButton.tintColor = .choaGreenColor
        navigationItem.rightBarButtonItem = closeButton

        let rootView = AddFoodItemForm { [weak self] name, carbGrams, portionSize, categoryTitle in
            CustomFoodsManager.shared.addFood(
                name: name,
                carbGrams: carbGrams,
                servingSize: portionSize,
                categoryTitle: categoryTitle
            )
            self?.navigationController?.popViewController(animated: true)
        }

        let controller = UIHostingController(rootView: rootView)
        controller.view.backgroundColor = .clear
        controller.view.translatesAutoresizingMaskIntoConstraints = false

        addChild(controller)
        view.addSubview(controller.view)
        controller.didMove(toParent: self)

        NSLayoutConstraint.activate([
            controller.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            controller.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            controller.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            controller.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    @objc private func closeTapped() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Form

private struct AddFoodItemForm: View {
    /// (name, carbGrams, portionSize, categoryTitle)
    let onAdd: (String, Int, String, String) -> Void

    @ObservedObject private var customFoods = CustomFoodsManager.shared

    @State private var name = ""
    @State private var carbValue = ""
    @State private var portionSize = ""
    @State private var categoryTitle: String?

    private var carbGrams: Int? {
        Int(carbValue.trimmingCharacters(in: .whitespaces))
    }

    private var nameIsTaken: Bool {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty && !customFoods.nameIsAvailable(trimmed)
    }

    private var canSubmit: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !nameIsTaken
            && (carbGrams.map { $0 >= 0 } ?? false)
            && !portionSize.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && categoryTitle != nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Add an Item")
                        .font(.custom("Nunito-Medium", size: 20))
                        .foregroundColor(Color(.primaryBlue))

                    HStack {
                        Spacer()
                        
                        icon
                        
                        Spacer()
                    }

                    field(title: "Item name") {
                        TextField("", text: $name)
                            .font(.custom("Nunito-Regular", size: 16))
                    }

                    if nameIsTaken {
                        Text("An item with this name already exists.")
                            .font(.custom("Nunito-Regular", size: 13))
                            .foregroundColor(Color(.errorRedColor))
                    }

                    field(title: "Carb value") {
                        HStack {
                            TextField("", text: $carbValue)
                                .keyboardType(.numberPad)
                                .font(.custom("Nunito-Regular", size: 16))

                            Text("g")
                                .font(.custom("Nunito-Regular", size: 16))
                                .foregroundColor(.black)
                        }
                    }

                    field(title: "Portion size") {
                        TextField("", text: $portionSize)
                            .font(.custom("Nunito-Regular", size: 16))
                    }

                    categoryPicker
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }

            addButton
        }
    }

    private var icon: some View {
        Image(CustomFoodsManager.iconName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 56, height: 56)
            .padding(12)
            .background(Color(.sunsetOrangeColor100))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func field<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.custom("Nunito-Regular", size: 16))
                .foregroundColor(.black)

            content()
                .padding(.horizontal, 14)
                .padding(.vertical, 14)
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
        }
    }

    private var categoryPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Item category")
                .font(.custom("Nunito-Regular", size: 16))
                .foregroundColor(.black)

            Menu {
                ForEach(customFoods.categoryTitles, id: \.self) { title in
                    Button(title) { categoryTitle = title }
                }
            } label: {
                HStack {
                    Text(categoryTitle ?? "")
                        .font(.custom("Nunito-Regular", size: 16))
                        .foregroundColor(.black)

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.black)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 14)
                .contentShape(Rectangle())
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
            }
        }
    }

    private var addButton: some View {
        Button {
            guard let carbGrams, let categoryTitle else { return }
            onAdd(
                name.trimmingCharacters(in: .whitespacesAndNewlines),
                carbGrams,
                portionSize.trimmingCharacters(in: .whitespacesAndNewlines),
                categoryTitle
            )
        } label: {
            Text("Add item")
                .font(.custom("Nunito-Bold", size: 18))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(Color(.choaGreenColor))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(!canSubmit)
        .opacity(canSubmit ? 1 : 0.5)
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }
}

#if DEBUG
private struct AddFoodItemViewControllerPreview: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UINavigationController {
        UINavigationController(rootViewController: AddFoodItemViewController())
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
    }
}

struct AddFoodItemViewController_Previews: PreviewProvider {
    static var previews: some View {
        AddFoodItemViewControllerPreview()
    }
}
#endif
