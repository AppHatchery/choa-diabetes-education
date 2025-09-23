//
//  UIString+Extensions.swift
//  choa-diabetes-education
//

import Foundation

/// Extension for localizable methods
extension String {

    // MARK: - Localization related string extensions

    /// Swift friendly localization syntax, replaces NSLocalizedString
    ///
    /// - Returns: The localized string.
    public func localized() -> String {
        return localized(tableName: nil, bundle: Bundle.main)
    }

    /**
        Swift friendly localization syntax, replaces NSLocalizedString.
        - parameter tableName: The receiver’s string table to search. If tableName is `nil`
        or is an empty string, the method attempts to use `Localizable.strings`.
        - parameter bundle: The receiver’s bundle to search. If bundle is `nil`,
        the method attempts to use main bundle.
        - returns: The localized string.
     */
    func localized(tableName: String?, bundle: Bundle?) -> String {
        let bundle: Bundle = bundle ?? Bundle.main
        return bundle.localizedString(forKey: self, value: nil, table: tableName)
    }

	var capitalizedFirstLetter: String {
		guard !isEmpty else { return self }
		return prefix(1).uppercased() + dropFirst()
	}
}

