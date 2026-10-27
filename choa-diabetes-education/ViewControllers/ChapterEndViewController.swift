//
//  ChapterEndViewController.swift
//  choa-diabetes-education
//
//  Created by Yago Arconada on 8/31/22.
//

import UIKit
import Lottie

class ChapterEndViewController: UIViewController {
    
    // MARK: - Completion Tracking
    private struct CompletionStore {
        static let defaults = UserDefaults.standard
        static func key(for section: Int) -> String { "completed_chapters_section_\(section)" }
        
        static func completedIndices(for section: Int) -> Set<Int> {
            let key = key(for: section)
            let array = defaults.array(forKey: key) as? [Int] ?? []
            return Set(array)
        }
        
        static func markCompleted(section: Int, index: Int) {
            var set = completedIndices(for: section)
            set.insert(index)
            let array = Array(set).sorted()
            defaults.set(array, forKey: key(for: section))
        }
        
        static func completedCount(for section: Int) -> Int {
            return completedIndices(for: section).count
        }
    }
    
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var nextChapterButton: PrimaryButton!
    @IBOutlet weak var congratsLabel: UILabel!
    
    @IBOutlet weak var textBubbleImage: UIImageView!
    @IBOutlet weak var hopeOrWillImage: UIImageView!
    
    @IBOutlet weak var bottomStarsView: UIView!
    @IBOutlet weak var starsStackView: UIStackView!
    
    @IBOutlet weak var chaptersCompletedLabel: UILabel!
    
    @IBOutlet weak var rightStarsStackConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftStarsStackConstraint: NSLayoutConstraint!
    
    
    
    var contentIndex = 0
    var chapterEndTitle = ""
    var nextChapter = ""
    var nextChapterURL = ""
    var quizIndex = 0

    private var isShowingHalloweenBackground = false

    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.shadowColor = UIColor.clear
        
        appearance.buttonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        if contentIndex == 0 {
            appearance.backgroundColor = .diabetesBasicsColor
            mainView.backgroundColor = .diabetesBasicsColor
        } else if contentIndex == 1 {
            appearance.backgroundColor = .nutritionAndCarbColor
            mainView.backgroundColor = .nutritionAndCarbColor
        } else {
            appearance.backgroundColor = .diabetesSelfManagementColor
            mainView.backgroundColor = .diabetesSelfManagementColor
        }

        // Let the Halloween artwork show through the main view
        if isShowingHalloweenBackground {
            mainView.backgroundColor = .clear
        }

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        
        navigationController?.navigationBar.tintColor = .white
        navigationItem.backButtonDisplayMode = .minimal
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Track current chapter index for completion persistence
        var currentChapterIndex: Int? = nil
        
        navigationController?.navigationBar.tintColor = .white
        navigationItem.backButtonDisplayMode = .minimal
        
        bottomStarsView.layer.cornerRadius = 20
        bottomStarsView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        
        switch contentIndex {
        case 0:
            if let chapterEndTitleIndex = ContentChapter().sectionOne.firstIndex(where: { $0.contentTitle == chapterEndTitle }) {
                if chapterEndTitleIndex < ContentChapter().sectionOne.count - 1 {
                    nextChapter = ContentChapter().sectionOne[chapterEndTitleIndex + 1].contentTitle
                    nextChapterURL = ContentChapter().sectionOne[chapterEndTitleIndex + 1].contentHTML
                }
                quizIndex = chapterEndTitleIndex
                currentChapterIndex = chapterEndTitleIndex
                
                // Update text bubble image for Section One based on the completed chapter index
                if chapterEndTitleIndex == 0 {
                    congratsLabel.text = "Congratulatory1".localized()
                    textBubbleImage.image = UIImage(named: "diabetes_basics_text_bubble_1")
                } else if chapterEndTitleIndex == 1 {
                    congratsLabel.text = "Congratulatory2".localized()
                    textBubbleImage.image = UIImage(named: "diabetes_basics_text_bubble_2")
                    hopeOrWillImage.image = UIImage(named: "will_pump")
                } else if chapterEndTitleIndex == 2 {
                    congratsLabel.text = "Congratulatory3".localized()
                    textBubbleImage.image = UIImage(named: "diabetes_basics_text_bubble_3")
                    hopeOrWillImage.image = UIImage(named: "hope_basics")
                } else if chapterEndTitleIndex == 3 {
                    congratsLabel.text = "Congratulatory4".localized()
                    textBubbleImage.image = UIImage(named: "diabetes_basics_text_bubble_4")
                    hopeOrWillImage.image = UIImage(named: "will_pen")
                } else {
                    congratsLabel.text = "Congratulatory5".localized()
                    textBubbleImage.image = UIImage(named: "diabetes_basics_text_bubble_5")
                    hopeOrWillImage.image = UIImage(named: "will_pen")
                }
            }
        case 1:
            if let chapterEndTitleIndex = ContentChapter().sectionTwo.firstIndex(where: { $0.contentTitle == chapterEndTitle }) {
                if chapterEndTitleIndex < ContentChapter().sectionTwo.count - 1 {
                    nextChapter = ContentChapter().sectionTwo[chapterEndTitleIndex + 1].contentTitle
                    nextChapterURL = ContentChapter().sectionTwo[chapterEndTitleIndex + 1].contentHTML
                }
                quizIndex = chapterEndTitleIndex
                currentChapterIndex = chapterEndTitleIndex
                
                if chapterEndTitleIndex == 0 {
                    congratsLabel.text = "Congratulatory1".localized()
                    textBubbleImage.image = UIImage(named: "nutrition_carb_text_bubble_1")
                    hopeOrWillImage.image = UIImage(named: "will_nutrition_food")
                } else if chapterEndTitleIndex == 1 {
                    congratsLabel.text = "Congratulatory2".localized()
                    textBubbleImage.image = UIImage(named: "nutrition_carb_text_bubble_2")
                    hopeOrWillImage.image = UIImage(named: "hope_burger")
                } else {
                    congratsLabel.text = "Congratulatory6".localized()
                    textBubbleImage.image = UIImage(named: "nutrition_carb_text_bubble_3")
                    hopeOrWillImage.image = UIImage(named: "will_nutrition")
                }
                
                // Extra logic for section 2 with chapters that don't contain a quiz
                if chapterEndTitleIndex == 1 || chapterEndTitleIndex == 3 {
                    // quiz disabled for these indices
                }
            }
        case 2:
            if let chapterEndTitleIndex = ContentChapter().sectionThree.firstIndex(where: { $0.contentTitle == chapterEndTitle }) {
                if chapterEndTitleIndex < ContentChapter().sectionThree.count - 1 {
                    nextChapter = ContentChapter().sectionThree[chapterEndTitleIndex + 1].contentTitle
                    nextChapterURL = ContentChapter().sectionThree[chapterEndTitleIndex + 1].contentHTML
                }
                quizIndex = chapterEndTitleIndex
                currentChapterIndex = chapterEndTitleIndex
                
                if chapterEndTitleIndex == 0 {
                    congratsLabel.text = "Congratulatory1".localized()
                    textBubbleImage.image = UIImage(named: "self_managment_text_bubble_1")
                    hopeOrWillImage.image = UIImage(named: "will_nutrition_food")
                } else {
                    congratsLabel.text = "Congratulatory6".localized()
                    textBubbleImage.image = UIImage(named: "self_managment_text_bubble_2")
                    hopeOrWillImage.image = UIImage(named: "hope_on_call")
                }
            }
        default:
            print("error where index doesn't match")
        }
        
        // Persist completion for this chapter (idempotent)
        if let idx = currentChapterIndex {
            CompletionStore.markCompleted(section: contentIndex, index: idx)

            if RemoteConfigManager.shared.isHalloweenThemeEnabled {
                applyHalloweenBackground(chapterIndex: idx)
            }
        }

        updateStarsUI()
    }

    /// The section's Halloween scene fills the screen behind a see-through nav bar, and the
    /// character art (which has the text bubble drawn in) takes the place of the bubble and character views
    private func applyHalloweenBackground(chapterIndex: Int) {
        let characterName: String
        switch contentIndex {
        case 0: characterName = "halloween_chapter_complete_basics_\(min(chapterIndex, 4) + 1)_character"
        case 1: characterName = "halloween_chapter_complete_nutrition_\(min(chapterIndex, 2) + 1)_character"
        case 2: characterName = "halloween_chapter_complete_self_management_\(min(chapterIndex, 1) + 1)_character"
        default: return
        }
        guard let backgroundImage = UIImage(named: "halloween_chapter_complete_\(contentIndex + 1)"),
              let characterImage = UIImage(named: characterName) else { return }

        let backgroundImageView = UIImageView(image: backgroundImage)
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(backgroundImageView, at: 0)
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        // The stars card stops at the safe area, so continue its white down through the home indicator area
        let bottomFillView = UIView()
        bottomFillView.backgroundColor = bottomStarsView.backgroundColor
        bottomFillView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(bottomFillView, aboveSubview: backgroundImageView)
        NSLayoutConstraint.activate([
            bottomFillView.topAnchor.constraint(equalTo: bottomStarsView.centerYAnchor),
            bottomFillView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomFillView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomFillView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        // The character art carries its own bubble, so the bubble view collapses out of the images stack
        textBubbleImage.isHidden = true
        hopeOrWillImage.image = characterImage

        // Size the art from its width like the regular bubble and character, and let it shrink
        // rather than push the congrats label up under the nav bar on shorter screens
        hopeOrWillImage.constraints
            .filter { $0.firstAttribute == .height && $0.relation == .equal }
            .forEach { $0.isActive = false }
        hopeOrWillImage.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        let aspectConstraint = hopeOrWillImage.heightAnchor.constraint(
            equalTo: hopeOrWillImage.widthAnchor,
            multiplier: characterImage.size.height / characterImage.size.width
        )
        aspectConstraint.priority = .defaultHigh - 1
        NSLayoutConstraint.activate([
            aspectConstraint,
            congratsLabel.topAnchor.constraint(greaterThanOrEqualTo: mainView.topAnchor, constant: 16)
        ])

        // Leaves (stars for self management) fall over the whole screen, stars card and buttons included, without blocking taps
        let fallingAnimationName = contentIndex == 2 ? "falling-stars" : "falling-leaves"
        let fallingView = LottieAnimationView(name: fallingAnimationName)
        fallingView.contentMode = .scaleAspectFill
        fallingView.loopMode = .playOnce
        fallingView.backgroundBehavior = .pauseAndRestore
        fallingView.isUserInteractionEnabled = false
        fallingView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(fallingView)

        NSLayoutConstraint.activate([
            fallingView.topAnchor.constraint(equalTo: view.topAnchor),
            fallingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            fallingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            fallingView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        fallingView.play()

        // Scoped to this screen so the rest of the stack keeps its colored bar
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactAppearance = appearance

        isShowingHalloweenBackground = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        navigationController?.navigationBar.tintColor = .white
        navigationItem.backButtonDisplayMode = .minimal
        
        // Hide next button if the end of the section
        if nextChapter != "" {
            // there is a next chapter, keep button as-is
            nextChapterButton
                .setTitleWithStyle(
                    "Next Chapter",
                    font: .nunitoBold20,
                    image: nil
                )
        } else {
            // final chapter in section
            nextChapterButton
                .setTitleWithStyle(
                    "Done",
                    font: .nunitoBold20,
                    image: nil
                )
            
            nextChapterButton.setImage(nil, for: .normal)
            nextChapterButton.setImage(nil, for: .highlighted)
            nextChapterButton.setImage(nil, for: .selected)
            nextChapterButton.setImage(nil, for: .disabled)
            if #available(iOS 15.0, *) {
                nextChapterButton.configuration?.image = nil
            }
        }
        
        // Refresh stars in case the view reappears
        updateStarsUI()
    }
    
    @IBAction func nextChapter(_ sender: UIButton){
        // If this is the final chapter in the section, launch the quiz instead of going to next chapter
        if nextChapter.isEmpty {
            for controller in self.navigationController!.viewControllers as Array {
                if controller.isKind(of: HomeViewController.self) {
                    self.navigationController!.popToViewController(controller, animated: true)
                    break
                }
            }
        } else {
            performSegue(withIdentifier: "SegueToChapterViewController", sender: nil)
        }
    }
    
    @IBAction func launchQuiz(_ sender: UIButton){
        performSegue(withIdentifier: "SegueToQuizIntroViewController", sender: nil)
    }
    
    @IBAction func backToChapterList(_ sender: UIButton){
        // Go back to the list view controller
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: HandbookViewController.self) {
                self.navigationController!.popToViewController(controller, animated: true)
                break
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let chapterViewController = segue.destination as? ChapterViewController {
            chapterViewController.contentIndex = contentIndex
            chapterViewController.contentURL = nextChapterURL
            chapterViewController.titleURL = nextChapter
        }
        if let quizViewController = segue.destination as? QuizIntroViewController {
            quizViewController.quizSubchapter = quizIndex
            quizViewController.quizChapter = contentIndex
            quizViewController.quizTitle = chapterEndTitle
        }
    }
}

// MARK: - Stars helpers
private extension ChapterEndViewController {
    func totalChaptersCount(for section: Int) -> Int {
        switch section {
        case 0: return ContentChapter().sectionOne.count
        case 1: return ContentChapter().sectionTwo.count
        case 2: return ContentChapter().sectionThree.count
        default: return 0
        }
    }
    
    func updateStarsUI() {
        let totalCount = totalChaptersCount(for: contentIndex)
        let completedSet = CompletionStore.completedIndices(for: contentIndex)
        let completedCount = min(totalCount, completedSet.count)
        
        chaptersCompletedLabel.text = "\(completedCount) of \(totalCount) chapters completed"
        
        // Clear existing stars
        starsStackView.arrangedSubviews.forEach { sub in
            starsStackView.removeArrangedSubview(sub)
            sub.removeFromSuperview()
        }
        
        starsStackView.alignment = .center
        
        if totalCount == 5 {
            starsStackView.distribution = .fillEqually
            starsStackView.spacing = 8
            
            rightStarsStackConstraint.constant = 50
            leftStarsStackConstraint.constant = 50
        } else {
            starsStackView.spacing = 0
            starsStackView.distribution = .fillEqually
            rightStarsStackConstraint.constant = 100
            leftStarsStackConstraint.constant = 100
        }
        
        for i in 0..<totalCount {
            let isCompleted = i < completedCount
            let starView = makeStarImageView(completed: isCompleted)
            if isCompleted {
                starView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            }
            starsStackView.addArrangedSubview(starView)
        }

        animateCompletedStars(count: completedCount)
    }

    func animateCompletedStars(count: Int) {
        let starViews = starsStackView.arrangedSubviews
        for i in 0..<count {
            guard i < starViews.count else { break }
            UIView.animate(
                withDuration: 1.26,
                delay: Double(i) * 0.2,
                usingSpringWithDamping: 0.5,
                initialSpringVelocity: 0.8,
                options: [],
                animations: { starViews[i].transform = .identity }
            )
        }
    }
    
    func makeStarImageView(completed: Bool) -> UIImageView {
        let assetName = completed ? "star_completed" : "star_uncompleted"
        let image = UIImage(named: assetName)?.withRenderingMode(.alwaysOriginal)
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        // The stack view's leading/trailing insets and .fillEqually distribution
        // determine each star's width, so a required 40pt width would conflict.
        // Keep it as a preference; aspect-fit + fixed height keeps the star 40x40.
        let widthConstraint = imageView.widthAnchor.constraint(equalToConstant: 40)
        widthConstraint.priority = .defaultHigh
        NSLayoutConstraint.activate([
            widthConstraint,
            imageView.heightAnchor.constraint(equalToConstant: 40)
        ])
        return imageView
    }
}

