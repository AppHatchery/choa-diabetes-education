//
//  UIView+Extensions.swift
//  choa-diabetes-education
//
//  Created by Yago Arconada on 8/16/22.
//

import UIKit

extension UIView {
    
    func dropShadow() {
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 2.0
        layer.shadowColor = self.backgroundColor?.cgColor
        //        layer.cornerRadius = 2
        //        layer.masksToBounds = false
        //        layer.shadowColor = UIColor.black.cgColor
        //        layer.shadowOpacity = 0.5
        //        layer.shadowOffset = CGSize(width: 1, height: 1)
        //        layer.shadowRadius = 2
        //        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        //        layer.shouldRasterize = true
        //        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    func hwDropShadow() {
        layer.shadowOffset = CGSize(width: 0, height: 12)
        layer.shadowOpacity = 1.0
        layer.shadowRadius = 15.0
        layer.shadowColor = UIColor.shadowColor.cgColor
    }
    
    func detailedDropShadow(color: CGColor, blur: CGFloat,offset: Int,opacity: Float){
        layer.shadowOffset = CGSize(width: 0, height: offset)
        layer.shadowOpacity = opacity
        layer.shadowRadius = blur // Defines the blur of the shadow
        layer.shadowColor = color
        layer.masksToBounds = false
    }

	/// Rounds all corners with a fixed radius. iOS 26 manages view corners through
	/// `cornerConfiguration`, which overrides `layer.cornerRadius`.
	func applyCornerRadius(_ radius: CGFloat) {
		if #available(iOS 26.0, *) {
			cornerConfiguration = .corners(radius: .fixed(radius))
		} else {
			layer.cornerRadius = radius
		}
	}

	func roundedCorners(corners: UIRectCorner, radius: CGFloat) {
		let maskPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
		let shape = CAShapeLayer()
		shape.path = maskPath.cgPath
		layer.mask = shape
	}

	func updateViewForSelection() {
		self.backgroundColor = .answerSelectionColor
		self.layer.borderColor = UIColor.primaryBlue.cgColor
		self.layer.borderWidth = 1.0
		self.layer.cornerRadius = 8.0
		self.layer.masksToBounds = true
	}

	func updateViewForDeselection() {
		self.backgroundColor = .white
		self.layer.borderColor = UIColor.highlightedBlueColor.cgColor
		self.layer.borderWidth = 1.0
		self.layer.cornerRadius = 8.0
		self.layer.masksToBounds = true
	}

    // MARK: - load from nibs
    class func instantiateFromNib<T: UIView>(viewType: T.Type, owner: AnyObject!) -> T? {
        if let url = NSURL(string: NSStringFromClass(viewType)) {
            return Bundle(for: T.self).loadNibNamed((url.pathExtension)!, owner: owner, options: nil)!.first as? T
        } else {
            return nil
        }
    }

    class func instantiateFromNib() -> Self {
        return instantiateFromNib(viewType: self, owner: nil)!
    }

    class func instantiateFromNibWithOwner(owner: AnyObject!) -> Self {
        return instantiateFromNib(viewType: self, owner: owner)!
    }
    
    func setGradientBackground(colors: [UIColor],
                                   startPoint: CGPoint = CGPoint(x: 0.0, y: 0.5),
                                   endPoint: CGPoint = CGPoint(x: 1.0, y: 0.5),
                                   cornerRadius: CGFloat = 12) {
            // Remove any existing gradient layer to avoid stacking
            layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })

            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = bounds
            gradientLayer.colors = colors.map { $0.cgColor }
            gradientLayer.startPoint = startPoint
            gradientLayer.endPoint = endPoint
            gradientLayer.cornerRadius = cornerRadius
            layer.insertSublayer(gradientLayer, at: 0)
        }
}

extension UIViewController {

    /// Moves `contentView` into a vertical scroll view so its fields can always be scrolled into sight, while
    /// `bottomView` (the result card and the Next or Exit button) stays fixed at the bottom of the screen outside it.
    /// With the keyboard down the scroll view ends at the top of `bottomView`. With it up, the scroll view runs down
    /// to the keyboard and covers `bottomView`, as the keyboard did before, so the fields get all the room above it.
    /// `lastScrollingView` is the lowest view left in `contentView`; the scrolling content ends `spacing` below it.
    /// The scroll view spans the whole width, so the margins scroll too, while `contentView` keeps to the safe
    /// area, and so to the capped column on wide screens. Call it before `extendBackgroundToScreenEdges(of:)`.
    func embedInKeyboardAwareScrollView(
        _ contentView: UIView,
        lastScrollingView: UIView,
        pinnedToBottom bottomView: UIView,
        spacing: CGFloat = 20,
        sideInset: CGFloat = 20
    ) {
        guard let container = contentView.superview else { return }

        let scrollView = KeyboardAwareScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        // Opaque, so the fixed bottom view doesn't show through while the scroll view covers it
        scrollView.backgroundColor = view.backgroundColor ?? .systemBackground
        // The scroll view already stops at the safe area, the bottom view or the keyboard, so needs no insets of its own
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.showsHorizontalScrollIndicator = false
        container.insertSubview(scrollView, belowSubview: contentView)

        // Leaving their old superviews drops the storyboard's constraints pinning them to the safe area and each other
        contentView.removeFromSuperview()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        bottomView.removeFromSuperview()
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(bottomView, belowSubview: scrollView)

        let safeArea = view.safeAreaLayoutGuide

        // When everything fits, the content fills the scroll view rather than ending short of it
        let fillsScrollView = contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        fillsScrollView.priority = .defaultLow

        scrollView.stopsAtBottomView = scrollView.bottomAnchor.constraint(equalTo: bottomView.topAnchor)
        scrollView.stopsAtKeyboard = scrollView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.stopsAtBottomView!,

            // Top and bottom set the scrollable height; the width comes from the safe area as before
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            contentView.bottomAnchor.constraint(greaterThanOrEqualTo: lastScrollingView.bottomAnchor, constant: spacing),
            contentView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.heightAnchor),
            fillsScrollView,

            bottomView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: sideInset),
            bottomView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -sideInset),
            bottomView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ])
    }

    /// Paints `band`'s background colour across the whole width of the screen behind it.
    /// Content is capped to a centred column on wide screens (an unfolded iPhone Duo), so a coloured
    /// header pinned to the safe area would otherwise stop short and leave white margins either side.
    /// Inside a scroll view the fill is added to the scroll view, so it scrolls along with the band.
    func extendBackgroundToScreenEdges(of band: UIView) {
        // The band's outermost container below the screen's view or a scroll view
        var host = band
        while let parent = host.superview, parent !== view, !(parent is UIScrollView) {
            host = parent
        }
        guard let parent = host.superview else { return }

        let fill = UIView()
        fill.backgroundColor = band.backgroundColor
        fill.isUserInteractionEnabled = false
        fill.translatesAutoresizingMaskIntoConstraints = false
        if parent === view {
            parent.insertSubview(fill, at: 0)
        } else {
            parent.insertSubview(fill, belowSubview: host)
        }

        NSLayoutConstraint.activate([
            fill.topAnchor.constraint(equalTo: band.topAnchor),
            fill.bottomAnchor.constraint(equalTo: band.bottomAnchor),
            fill.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            fill.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

/// Scroll view that ends at the fixed bottom view while the keyboard is down, and at the keyboard while it's up.
/// Set up by `embedInKeyboardAwareScrollView(_:lastScrollingView:pinnedToBottom:spacing:sideInset:)`.
final class KeyboardAwareScrollView: UIScrollView {

    var stopsAtBottomView: NSLayoutConstraint?
    var stopsAtKeyboard: NSLayoutConstraint?

    override init(frame: CGRect) {
        super.init(frame: frame)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        guard let screenView = superview,
              let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }

        // A hardware keyboard leaves only a short bar or nothing on screen, which the bottom view can stay above
        let overlap = screenView.bounds.maxY - screenView.convert(frame, from: nil).minY
        coverBottomView(overlap > screenView.safeAreaInsets.bottom, alongside: notification)
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        coverBottomView(false, alongside: notification)
    }

    private func coverBottomView(_ covers: Bool, alongside notification: Notification) {
        guard let stopsAtBottomView, let stopsAtKeyboard, stopsAtKeyboard.isActive != covers else { return }

        // Deactivate before activating so the two are never both required
        if covers {
            stopsAtBottomView.isActive = false
            stopsAtKeyboard.isActive = true
        } else {
            stopsAtKeyboard.isActive = false
            stopsAtBottomView.isActive = true
        }

        let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.25
        UIView.animate(withDuration: duration) {
            self.superview?.layoutIfNeeded()
        }
    }
}
