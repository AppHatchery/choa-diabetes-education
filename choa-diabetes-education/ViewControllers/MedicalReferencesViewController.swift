//
//  MedicalReferencesViewController.swift
//  choa-diabetes-education
//
//  Created by Cursor on 2/9/26.
//

import UIKit

class MedicalReferencesViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Medical References"
        view.backgroundColor = .systemBackground
        
        setupContent()
    }
    
    private func setupContent() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        let contentStack = UIStackView()
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.alignment = .center
        contentStack.spacing = 0
        scrollView.addSubview(contentStack)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 24),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -30),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -40)
        ])
        
        // --- TypeU App Logo ---
        let appLogoImageView = UIImageView(image: UIImage(named: "typeULogo"))
        appLogoImageView.translatesAutoresizingMaskIntoConstraints = false
        appLogoImageView.contentMode = .scaleAspectFit
        appLogoImageView.layer.cornerRadius = 20
        appLogoImageView.clipsToBounds = true
        contentStack.addArrangedSubview(appLogoImageView)
        NSLayoutConstraint.activate([
            appLogoImageView.widthAnchor.constraint(equalToConstant: 100),
            appLogoImageView.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        contentStack.setCustomSpacing(24, after: appLogoImageView)
        
        // --- Main text content ---
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        
        let baseAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 15),
            .foregroundColor: UIColor.label,
            .paragraphStyle: paragraphStyle
        ]
        
        let headerAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "GothamRounded-Medium", size: 16) ?? UIFont.boldSystemFont(ofSize: 16),
            .foregroundColor: UIColor(named: "primaryBlue") ?? UIColor.label,
            .paragraphStyle: paragraphStyle
        ]
        
        let attributedString = NSMutableAttributedString(
            string: "All medical recommendations contained on this app are derived from the following sources:\n\n",
            attributes: baseAttributes
        )
        
        // ISPAD section
        attributedString.append(NSAttributedString(string: "Sick Day Management\n", attributes: headerAttributes))
        attributedString.append(NSAttributedString(
            string: "International Society for Pediatric and Adolescent Diabetes (ISPAD) guidelines on sick day management in children and adolescents with diabetes.\n\n",
            attributes: baseAttributes
        ))
        attributedString.append(NSAttributedString(
            string: "View ISPAD Guidelines\n\n\n",
            attributes: [
                .font: UIFont.systemFont(ofSize: 15),
                .link: URL(string: "https://www.ispad.org/resource/chapter-13-sick-day-management.html")!,
                .paragraphStyle: paragraphStyle
            ]
        ))
        
        // ADA section
        attributedString.append(NSAttributedString(string: "General Diabetes Management\n", attributes: headerAttributes))
        attributedString.append(NSAttributedString(
            string: "American Diabetes Association (ADA) general guidelines for Diabetes management.\n\n",
            attributes: baseAttributes
        ))
        attributedString.append(NSAttributedString(
            string: "Visit American Diabetes Association",
            attributes: [
                .font: UIFont.systemFont(ofSize: 15),
                .link: URL(string: "https://diabetes.org")!,
                .paragraphStyle: paragraphStyle
            ]
        ))
        
        // Acknowledgments section
        attributedString.append(NSAttributedString(string: "\n\n\n", attributes: baseAttributes))
        attributedString.append(NSAttributedString(string: "Acknowledgments\n", attributes: headerAttributes))
        attributedString.append(NSAttributedString(
            string: "This app was designed and developed in partnership with the dedicated team of Diabetes Educators and Endocrinologists at Children's Healthcare of Atlanta. Their clinical expertise and commitment to patient care are at the heart of every recommendation within this app.\n\nWe would like to give a special mention to the following individuals for contributing their time and expertise:\n\n\u{2022} Dina Alsalih, Medical Education Specialist\n\u{2022} The Diabetes Education Team at Children's Healthcare of Atlanta, led by Anna Albritton and Alison Higgins\n\nThis work was made possible through the generous financial support of our donors and the 1998 Society.",
            attributes: baseAttributes
        ))
        
        // Built by section
        attributedString.append(NSAttributedString(string: "\n\n\n", attributes: baseAttributes))
        attributedString.append(NSAttributedString(string: "Built by the AppHatchery\n", attributes: headerAttributes))
        attributedString.append(NSAttributedString(
            string: "The AppHatchery is an interdisciplinary team of researchers, designers, and software developers from Emory University, Georgia Tech, and the Global Health Informatics Institute (in Malawi), funded by the Georgia Clinical and Translational Science Alliance (Georgia CTSA). They work on bringing research ideas to the general public via mobile and web apps.\n\nThe team that built this app includes: Aby Joe Kottoor, Maxwell Kapezi, Naomi Nyama,Upasana Bhattacharjee, Freja Zhang, Innocent Kumwenda, Wiza Munthali, Kennedy Linzie, Comfort Mwalija, Tanishk Deo, Rasika Punde, Morgan Greenleaf, Maren Parsell, and Santiago Arconada Alvarez.",
            attributes: baseAttributes
        ))
        
        textView.attributedText = attributedString
        textView.linkTextAttributes = [
            .foregroundColor: UIColor.systemBlue,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        
        contentStack.addArrangedSubview(textView)
        textView.widthAnchor.constraint(equalTo: contentStack.widthAnchor).isActive = true
        
        contentStack.setCustomSpacing(32, after: textView)
        
        // --- AppHatchery Logo ---
        let hatcheryImageView = UIImageView(image: UIImage(named: "hatchery"))
        hatcheryImageView.translatesAutoresizingMaskIntoConstraints = false
        hatcheryImageView.contentMode = .scaleAspectFit
        contentStack.addArrangedSubview(hatcheryImageView)
        NSLayoutConstraint.activate([
            hatcheryImageView.widthAnchor.constraint(equalToConstant: 140),
            hatcheryImageView.heightAnchor.constraint(equalToConstant: 65)
        ])
        
        contentStack.setCustomSpacing(12, after: hatcheryImageView)
        
        // --- Powered by footer ---
        let centeredStyle = NSMutableParagraphStyle()
        centeredStyle.alignment = .center
        
        let footerLabel = UILabel()
        footerLabel.translatesAutoresizingMaskIntoConstraints = false
        footerLabel.attributedText = NSAttributedString(
            string: "Powered by AppHatchery 2026",
            attributes: [
                .font: UIFont.systemFont(ofSize: 13),
                .foregroundColor: UIColor.secondaryLabel,
                .paragraphStyle: centeredStyle
            ]
        )
        footerLabel.textAlignment = .center
        contentStack.addArrangedSubview(footerLabel)
    }
}
