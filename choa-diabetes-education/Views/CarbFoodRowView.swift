//
//  CarbFoodRowView.swift
//  choa-diabetes-education
//
//  Created by Maxwell Kapezi Jr on 26/08/2026.
//

import SwiftUI

struct CarbFoodRowView: View {
    let food: CarbFood

    @ObservedObject private var calculator = CarbsCalculatorManager.shared

    private var quantity: Int {
        calculator.quantity(for: food)
    }

    private var controlBackground: Color {
        Color(.systemGray6)
    }

    private var accentColor: Color {
        Color(.primaryBlue)
    }

    var body: some View {
        HStack(spacing: 16) {
            Image(food.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 64, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(food.name)
                    .font(.custom("Nunito-Bold", size: 16))
                    .foregroundColor(Color(.black))
                Text(food.servingSize)
                    .font(.custom("Nunito-Regular", size: 14))
                    .foregroundColor(Color(.contentBlack))
                Text("\(food.carbGrams)g")
                    .font(.custom("Nunito-Bold", size: 20))
                    .foregroundColor(accentColor)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Reserved at a constant width: letting the control grow when a
            // quantity appears would change how the name wraps, and with it the
            // row's height.
            stepper
                .frame(width: Self.stepperWidth, alignment: .trailing)
        }
        .padding(.vertical, 12)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color(.systemGray5))
                .frame(height: 1)
        }
    }

    /// Width the stepper always occupies, whatever its state.
    static let stepperWidth: CGFloat = 104

    /// Horizontal inset applied to the row inside its cell, on each side.
    static let horizontalInset: CGFloat = 16

    @ViewBuilder
    private var stepper: some View {
        if quantity > 0 {
            HStack(spacing: 10) {
                stepperButton(systemName: "minus") {
                    calculator.decrement(food)
                }

                Text("\(quantity)")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(accentColor)
                    .frame(minWidth: 16)

                stepperButton(systemName: "plus") {
                    calculator.increment(food)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(controlBackground)
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
        } else {
            stepperButton(systemName: "plus") {
                calculator.increment(food)
            }
            .padding(8)
            .background(controlBackground)
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
        }
    }

    private func stepperButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(Color(.contentBlackColor))
                // The glyphs (especially "minus") are far smaller than a usable
                // tap target, so give every stepper button the same square area.
                .frame(width: 18 , height: 18)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct CarbCategoryHeaderView: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.custom("Nunito-Medium", size: 20))
            .foregroundColor(Color(.primaryBlue))
            .textCase(.uppercase)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(Color(.backgroundColor))
    }
}

#Preview {
    CarbFoodRowView(food: .init(name: "Banana and mashed banana potatoes", servingSize: "1 medium", carbGrams: 27, imageName: "im_banana"))
}
