//
//  CarbFoodTableViewCell.swift
//  choa-diabetes-education
//
//  Created by Maxwell Kapezi Jr on 26/08/2026.
//

import UIKit
import SwiftUI

class CarbFoodTableViewCell: UITableViewCell {
    static let reuseIdentifier = "CarbFoodTableViewCell"

    private var hostingController: UIHostingController<CarbFoodRowView>?

    override func prepareForReuse() {
        super.prepareForReuse()
        hostingController?.view.removeFromSuperview()
        hostingController = nil
    }

    func configure(with food: CarbFood) {
        selectionStyle = .none
        backgroundColor = .clear

        let rowView = CarbFoodRowView(food: food)
        let controller = UIHostingController(rootView: rowView)
        controller.view.backgroundColor = .clear
        controller.view.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(controller.view)
        NSLayoutConstraint.activate([
            controller.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            controller.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            controller.view.topAnchor.constraint(equalTo: contentView.topAnchor),
            controller.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])

        hostingController = controller
    }
}
