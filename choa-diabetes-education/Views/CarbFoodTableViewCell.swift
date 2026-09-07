//
//  CarbFoodTableViewCell.swift
//  choa-diabetes-education
//
//  Created by Maxwell Kapezi Jr on 26/08/2026.
//

import UIKit

/// Hosts a `CarbFoodRowView` and lets Auto Layout size the cell from it.
class CarbFoodTableViewCell: UITableViewCell {
    static let reuseIdentifier = "CarbFoodTableViewCell"

    private let rowView = CarbFoodRowView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none
        backgroundColor = .clear

        rowView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(rowView)

        let inset = CarbFoodRowView.horizontalInset
        NSLayoutConstraint.activate([
            rowView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: inset),
            rowView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -inset),
            rowView.topAnchor.constraint(equalTo: contentView.topAnchor),
            rowView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// `parent` is unused now that the row is UIKit — no hosting controller
    /// needs adopting — but it is kept so the call site stays unchanged.
    func configure(with food: CarbFood, parent: UIViewController) {
        rowView.configure(with: food)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        rowView.prepareForReuse()
    }
}

#if DEBUG
import SwiftUI

private struct CarbFoodTableViewCellPreview: UIViewRepresentable {
    let food: CarbFood

    func makeUIView(context: Context) -> CarbFoodTableViewCell {
        let cell = CarbFoodTableViewCell(
            style: .default,
            reuseIdentifier: CarbFoodTableViewCell.reuseIdentifier
        )
        cell.configure(with: food, parent: UIViewController())
        return cell
    }

    func updateUIView(_ uiView: CarbFoodTableViewCell, context: Context) {}
}

struct CarbFoodTableViewCell_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {
            CarbFoodTableViewCellPreview(
                food: CarbFood(
                    name: "Bagel",
                    servingSize: "1/2 piece",
                    carbGrams: 30,
                    imageName: "im_bagel"
                )
            )
            CarbFoodTableViewCellPreview(
                food: CarbFood(
                    name: "Peanut Butter & Jelly Sandwich on Thick Sliced Wholegrain Bread",
                    servingSize: "1 pc",
                    carbGrams: 45,
                    imageName: "im_peanut_butter_jelly_sandwich"
                )
            )
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif
