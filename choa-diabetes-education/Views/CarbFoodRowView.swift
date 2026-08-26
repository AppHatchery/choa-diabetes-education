//
//  CarbFoodRowView.swift
//  choa-diabetes-education
//
//  Created by Maxwell Kapezi Jr on 26/08/2026.
//

import SwiftUI

struct CarbFoodRowView: View {
    let food: CarbFood

    @State private var quantity: Int = 0

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

            Spacer()

            if quantity > 0 {
                HStack(spacing: 10) {
                    stepperButton(systemName: "minus") {
                        quantity -= 1
                    }

                    Text("\(quantity)")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(accentColor)
                        .frame(minWidth: 16)

                    stepperButton(systemName: "plus") {
                        quantity += 1
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(controlBackground)
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            } else {
                stepperButton(systemName: "plus") {
                    quantity += 1
                }
                .padding(8)
                .background(controlBackground)
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            }
        }
        .padding(.vertical, 12)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color(.systemGray5))
                .frame(height: 1)
        }
    }

    private func stepperButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(Color(.contentBlackColor))
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
    CarbFoodRowView(food: .init(name: "Banana", servingSize: "1 medium", carbGrams: 27, imageName: "im_banana"))
}
