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

    /// Reuses a single hosting controller per cell and only swaps its `rootView`.
    /// Rebuilding it on every reuse — and never parenting it — left SwiftUI's
    /// update loop detached, so taps registered late or not at all.
    func configure(with food: CarbFood, parent: UIViewController) {
        selectionStyle = .none
        backgroundColor = .clear

        let rowView = CarbFoodRowView(food: food)

        if let controller = hostingController {
            controller.rootView = rowView
            if controller.parent !== parent {
                attach(controller, to: parent)
            }
            return
        }

        let controller = UIHostingController(rootView: rowView)
        controller.view.backgroundColor = .clear
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController = controller

        contentView.addSubview(controller.view)
        NSLayoutConstraint.activate([
            controller.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            controller.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            controller.view.topAnchor.constraint(equalTo: contentView.topAnchor),
            controller.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])

        attach(controller, to: parent)
    }

    private func attach(_ controller: UIHostingController<CarbFoodRowView>, to parent: UIViewController) {
        controller.willMove(toParent: nil)
        controller.removeFromParent()
        parent.addChild(controller)
        controller.didMove(toParent: parent)
    }
}
