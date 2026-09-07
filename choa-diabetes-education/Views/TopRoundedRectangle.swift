//
//  TopRoundedRectangle.swift
//  choa-diabetes-education
//
//  Created by Maxwell Kapezi Jr on 26/08/2026.
//

import UIKit

/// A view whose top two corners are rounded, leaving the bottom square so the
/// fill can run into the home-indicator inset.
///
/// Replaces the SwiftUI `TopRoundedRectangle: Shape` of the same purpose.
final class TopRoundedView: UIView {
    var cornerRadius: CGFloat = 24 {
        didSet { applyCorners() }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        applyCorners()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        applyCorners()
    }

    private func applyCorners() {
        layer.cornerRadius = cornerRadius
        layer.cornerCurve = .continuous
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
}

#if DEBUG
import SwiftUI

private struct TopRoundedViewPreview: UIViewRepresentable {
    func makeUIView(context: Context) -> TopRoundedView {
        let view = TopRoundedView()
        view.backgroundColor = .sunsetOrangeColor100
        return view
    }

    func updateUIView(_ uiView: TopRoundedView, context: Context) {}
}

struct TopRoundedView_Previews: PreviewProvider {
    static var previews: some View {
        TopRoundedViewPreview()
            .frame(width: 320, height: 120)
            .previewLayout(.sizeThatFits)
    }
}
#endif
