//
//  KnowYourCarbsResultViewController.swift
//  choa-diabetes-education
//
//  Created by Maxwell Kapezi Jr on 26/08/2026.
//

import UIKit
import SwiftUI

class KnowYourCarbsResultViewController: UIViewController {

    private let infoPopup = InfoPopUpViewController()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = ""
        view.backgroundColor = .white
        navigationItem.backButtonDisplayMode = .minimal

        let rootView = KnowYourCarbsResultView(
            onExit: { [weak self] in
                self?.navigationController?.popToRootViewController(animated: true)
            },
            onShowInfo: { [weak self] topic in
                guard let self else { return }
                self.infoPopup.appear(sender: self, title: topic.title, details: topic.details)
            }
        )
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

        setupDismissKeyboardGesture()
    }

    private func setupDismissKeyboardGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        // The carb-ratio field uses a number pad, which has no return key. The
        // touch is still delivered onward so the hosted SwiftUI buttons keep
        // responding to the same tap.
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

// MARK: - Result View

private struct KnowYourCarbsResultView: View {
    @ObservedObject private var calculator = CarbsCalculatorManager.shared
    let onExit: () -> Void
    let onShowInfo: (CarbsInfoTopic) -> Void

    @State private var carbRatioText: String = "15"
    @State private var showBreakdown = true

    private var carbRatio: Int {
        Int(carbRatioText) ?? 0
    }

    private var insulinUnits: Double {
        guard carbRatio > 0 else { return 0 }
        let raw = Double(calculator.totalCarbs) / Double(carbRatio)
        return (raw * 2).rounded(.down) / 2
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(calculator.selectedFoods, id: \.food.name) { entry in
                        CarbFoodRowView(food: entry.food)
                    }

                    additionalCarbsField
                        .padding(.top, 16)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }

            insulinCard
        }
        .onAppear(perform: loadCarbRatio)
        .onChange(of: carbRatioText, perform: saveCarbRatio)
    }

    private func loadCarbRatio() {
        let constantsManager = CalculatorConstantsManager.shared
        carbRatioText = constantsManager.carbRatio > 0 ? String(constantsManager.carbRatio) : "15"
    }

    private func saveCarbRatio(_ newValue: String) {
        guard let ratio = Int(newValue), ratio > 0 else { return }
        CalculatorConstantsManager.shared.carbRatio = ratio
    }

    private var additionalCarbsField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Any additional carbs")
                .font(.custom("Nunito-Medium", size: 16))
                .foregroundColor(.black)

            HStack {
                TextField("0", value: $calculator.additionalCarbs, format: .number)
                    .keyboardType(.numberPad)
                    .font(.custom("Nunito-Regular", size: 16))

                Text("g")
                    .font(.custom("Nunito-Regular", size: 16))
                    .foregroundColor(Color(.black))
            }
            .padding(12)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(Color(.separator), lineWidth: 1)
            )
        }
    }

    private var insulinCard: some View {
        VStack(spacing: 16) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showBreakdown.toggle()
                }
            } label: {
                Capsule()
                    .fill(Color.black)
                    .frame(width: 40, height: 4)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if showBreakdown {
                HStack(alignment: .top, spacing: 12) {
                    carbRatioColumn(
                        value: Text("\(calculator.totalCarbs)")
                            .font(.custom("Nunito-Medium", size: 32))
                            .foregroundColor(.black),
                        title: "Total Carbs",
                        onInfoTap: { onShowInfo(.totalCarbs) }
                    )

                    Text("/")
                        .font(.system(size: 32))
                        .foregroundColor(Color(.black))
                        .padding(.top, 8)

                    carbRatioColumn(
                        value: TextField("0", text: $carbRatioText)
                            .keyboardType(.numberPad)
                            .font(.custom("Nunito-Medium", size: 32))
                            .foregroundColor(.black)
                            .tint(Color(.choaGreenColor))
                            .fixedSize(),
                        title: "Carb Ratio",
                        onInfoTap: { onShowInfo(.carbRatio) }
                    )

                    Spacer()
                }
                .padding(.horizontal, 16)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }

            VStack(alignment: .leading, spacing: 4) {
                Button {
                    onShowInfo(.insulinForFood)
                } label: {
                    HStack(spacing: 6) {
                        Text("Insulin for food")
                            .font(.custom("Nunito-Bold", size: 16))
                        Image("ic_info")
                            .resizable()
                            .frame(width: 20, height: 20)
                    }
                    .foregroundColor(.white)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                Text("\(insulinUnits.cleanCarbString) units")
                    .font(.custom("Nunito-Bold", size: 32))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(Color(.sunsetOrangeColor400))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .padding(.horizontal, 20)

            Button(action: onExit) {
                HStack(spacing: 6) {
                    Text("Exit")
                    Image("close_black")
                        .resizable()
                        .frame(width: 20, height: 20)
                }
                .font(.custom("Nunito-Bold", size: 16))
                .foregroundColor(.black)
            }
            .frame(height: 47)
            .buttonStyle(.plain)
            .padding(.bottom, 10)
        }
        // The fill runs into the home-indicator inset so the card reaches the
        // bottom of the screen, while its contents stay clear of it.
        .background(
            TopRoundedRectangle(radius: 24)
                .fill(Color(.sunsetOrangeColor100))
                .ignoresSafeArea(edges: .bottom)
        )
    }

    private func carbRatioColumn(
        value: some View,
        title: String,
        onInfoTap: @escaping () -> Void
    ) -> some View {
        VStack(alignment: .center, spacing: 6) {
            value
                .font(.custom("Nunito-Bold", size: 32))

            Rectangle()
                .fill(Color(.black))
                .frame(height: 3)
                .cornerRadius(20)

            Button(action: onInfoTap) {
                HStack(spacing: 4) {
                    Text(title)
                        .font(.custom("Nunito-Medium", size: 16))
                        .foregroundColor(Color(.black))
                    Image("ic_info")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(Color(.black))
                }
            }
        }
    }
}

private extension Double {
    var cleanCarbString: String {
        truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(format: "%.1f", self)
    }
}

#if DEBUG
private struct KnowYourCarbsResultViewControllerPreview: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UINavigationController {
        UINavigationController(rootViewController: KnowYourCarbsResultViewController())
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
    }
}

struct KnowYourCarbsResultViewController_Previews: PreviewProvider {
    static var previews: some View {
        KnowYourCarbsResultViewControllerPreview()
    }
}
#endif
