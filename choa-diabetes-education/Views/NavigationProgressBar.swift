//
//  NavigationProgressBar.swift
//  choa-diabetes-education
//
//  Created by Maxwell Kapezi Jr on 07/09/2026.
//

import UIKit

/// A progress bar sized to sit in a navigation bar's `titleView`, showing how far
/// through a chapter or a question flow the user currently is.
///
/// Assign it as the `titleView` and call `updateWidth(for:)` from
/// `viewDidLayoutSubviews` so it keeps fitting the bar as it lays out:
///
///     navigationItem.titleView = progressBar
///     progressBar.updateWidth(for: navigationController?.navigationBar)
///
/// Progress changes animate by default; pass `animatesProgressChanges: false` (or set
/// the property) for a bar that should jump straight to its value.
final class NavigationProgressBar: UIView {
    
    private enum Metrics {
        static let barHeight: CGFloat = 8
        static let horizontalInset: CGFloat = 8
        static let height: CGFloat = 20
        /// Share of the navigation bar the bar aims to take up
        static let navigationBarWidthShare: CGFloat = 0.7
        /// Rough allowance for the back and close buttons either side of the title
        static let navigationBarButtonsWidth: CGFloat = 120
        static let minimumWidth: CGFloat = 160
        static let initialWidth: CGFloat = 200
    }
    
    private let progressView = UIProgressView(progressViewStyle: .default)
    private var widthConstraint: NSLayoutConstraint!
    
    /// Whether `setProgress(_:)` animates. Flows that show one step per pushed view
    /// controller are better off without it — each screen brings a fresh bar, so the
    /// animation would run up from empty every time.
    var animatesProgressChanges = true
    
    var progress: Float {
        progressView.progress
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    convenience init(animatesProgressChanges: Bool) {
        self.init(frame: .zero)
        self.animatesProgressChanges = animatesProgressChanges
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.progressTintColor = .orangeTextColor
        progressView.trackTintColor = .systemGray5
        progressView.layer.cornerRadius = Metrics.barHeight / 2
        progressView.clipsToBounds = true
        progressView.setProgress(0.0, animated: false)
        
        addSubview(progressView)
        
        // The width is driven by the navigation bar, which isn't measured yet, so it
        // starts at a sensible value and is revised in updateWidth(for:)
        widthConstraint = widthAnchor.constraint(equalToConstant: Metrics.initialWidth)
        
        NSLayoutConstraint.activate([
            widthConstraint,
            heightAnchor.constraint(equalToConstant: Metrics.height),
            progressView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metrics.horizontalInset),
            progressView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metrics.horizontalInset),
            progressView.centerYAnchor.constraint(equalTo: centerYAnchor),
            progressView.heightAnchor.constraint(equalToConstant: Metrics.barHeight)
        ])
    }
    
    /// Sets the progress, animating it or not per `animatesProgressChanges`
    func setProgress(_ progress: Float) {
        setProgress(progress, animated: animatesProgressChanges)
    }
    
    func setProgress(_ progress: Float, animated: Bool) {
        progressView.setProgress(progress, animated: animated)
    }
    
    /// Fits the bar to the navigation bar hosting it, leaving room for the buttons
    /// on either side of the title
    func updateWidth(for navigationBar: UINavigationBar?) {
        guard let navigationBar else { return }
        
        let availableWidth = navigationBar.bounds.width
        var targetWidth = availableWidth * Metrics.navigationBarWidthShare
        
        let maximumWidth = availableWidth - Metrics.navigationBarButtonsWidth
        if targetWidth > maximumWidth {
            targetWidth = max(Metrics.minimumWidth, maximumWidth)
        }
        
        guard widthConstraint.constant != targetWidth else { return }
        
        widthConstraint.constant = targetWidth
        
        // Force layout so the new width applies to the title view immediately
        setNeedsLayout()
        layoutIfNeeded()
    }
}
