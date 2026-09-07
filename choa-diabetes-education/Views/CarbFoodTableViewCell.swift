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
    private var foodName: String?

    /// Reuses a single hosting controller per cell and only swaps its `rootView`.
    /// Rebuilding it on every reuse — and never parenting it — left SwiftUI's
    /// update loop detached, so taps registered late or not at all.
    func configure(with food: CarbFood, parent: UIViewController) {
        selectionStyle = .none
        backgroundColor = .clear

        guard let controller = hostingController else {
            makeHostingController(for: food, parent: parent)
            foodName = food.name
            return
        }

        if controller.parent !== parent {
            attach(controller, to: parent)
        }

        // Re-assigning an identical rootView forces a SwiftUI re-layout on every
        // dequeue, which resizes the cell mid-scroll. Names are unique, so they
        // are enough to tell whether anything actually changed.
        guard foodName != food.name else { return }
        foodName = food.name
        controller.rootView = CarbFoodRowView(food: food)

        // SwiftUI would otherwise render the new food on a later pass, leaving
        // the previous row's content visible in a cell already resized for this
        // one — which reads as the row adjusting itself as it scrolls in.
        controller.view.setNeedsLayout()
        controller.view.layoutIfNeeded()
    }

    private func makeHostingController(for food: CarbFood, parent: UIViewController) {
        let controller = UIHostingController(rootView: CarbFoodRowView(food: food))
        controller.view.backgroundColor = .clear
        controller.view.translatesAutoresizingMaskIntoConstraints = false

        hostingController = controller

        contentView.addSubview(controller.view)

        // The row height is dictated by the table, so the hosting view must
        // simply fill it. A required bottom pin would contend with whatever
        // height SwiftUI reports for itself.
        let bottom = controller.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        bottom.priority = .required - 1

        NSLayoutConstraint.activate([
            controller.view.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: CarbFoodRowView.horizontalInset
            ),
            controller.view.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -CarbFoodRowView.horizontalInset
            ),
            controller.view.topAnchor.constraint(equalTo: contentView.topAnchor),
            bottom
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
