//
//  KnowYourCarbsResultViewController.swift
//  choa-diabetes-education
//
//  Created by Maxwell Kapezi Jr on 26/08/2026.
//

import UIKit
import SwiftUI

class KnowYourCarbsResultViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        title = ""
        view.backgroundColor = .white
        navigationItem.backButtonDisplayMode = .minimal

        let rootView = KnowYourCarbsResultView { [weak self] in
            self?.navigationController?.popToRootViewController(animated: true)
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
}

// MARK: - Result View

private struct KnowYourCarbsResultView: View {
    @ObservedObject private var calculator = CarbsCalculatorManager.shared
    let onExit: () -> Void

    @State private var carbRatioText: String = ""
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
        if constantsManager.hasStoredConstants, constantsManager.carbRatio > 0 {
            carbRatioText = String(constantsManager.carbRatio)
        }
    }

    private func saveCarbRatio(_ newValue: String) {
        guard let ratio = Int(newValue), ratio > 0 else { return }
        CalculatorConstantsManager.shared.carbRatio = ratio
    }

    private var additionalCarbsField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Any additional carbs")
                .font(.custom("Nunito-Bold", size: 16))
                .foregroundColor(.black)

            HStack {
                TextField("0", value: $calculator.additionalCarbs, format: .number)
                    .keyboardType(.numberPad)
                    .font(.custom("Nunito-Regular", size: 16))

                Text("g")
                    .font(.custom("Nunito-Regular", size: 16))
                    .foregroundColor(Color(.grayColor))
            }
            .padding(12)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
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
                        onInfoTap: nil
                    )

                    Text("/")
                        .font(.system(size: 24))
                        .foregroundColor(Color(.grayColor))
                        .padding(.top, 8)

                    carbRatioColumn(
                        value: TextField("0", text: $carbRatioText)
                            .keyboardType(.numberPad)
                            .font(.custom("Nunito-Medium", size: 32))
                            .foregroundColor(.black)
                            .fixedSize(),
                        title: "Carb Ratio",
                        onInfoTap: nil
                    )

                    Spacer()
                }
                .padding(.horizontal, 16)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text("Insulin for food")
                        .font(.custom("Nunito-Bold", size: 16))
                    Image(systemName: "info.circle")
                        .font(.system(size: 13))
                }
                .foregroundColor(.white)
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
                    Image(systemName: "xmark")
                }
                .font(.custom("Nunito-Bold", size: 16))
                .foregroundColor(.black)
            }
            .buttonStyle(.plain)
            .padding(.bottom, 16)
        }
        .background(Color(.sunsetOrangeColor100))
        .clipShape(TopRoundedRectangle(radius: 24))
    }

    private func carbRatioColumn(value: some View, title: String, onInfoTap: (() -> Void)?) -> some View {
        VStack(alignment: .center, spacing: 6) {
            value
                .font(.custom("Nunito-Bold", size: 32))

            Rectangle()
                .fill(Color(.systemGray4))
                .frame(height: 1)

            HStack(spacing: 4) {
                Text(title)
                    .font(.custom("Nunito-Medium", size: 16))
                    .foregroundColor(Color(.black))
                Image(systemName: "info.circle")
                    .font(.system(size: 11))
                    .foregroundColor(Color(.black))
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
