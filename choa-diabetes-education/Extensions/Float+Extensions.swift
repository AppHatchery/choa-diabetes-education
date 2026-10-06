//
//  Float+Extensions.swift
//  choa-diabetes-education
//
//  Created by Maxwell Kapezi Jr on 14/10/2025.
//

extension Float {
    var cleanString: String {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(format: "%.1f", self)
    }

    /// Up to two decimal places with trailing zeros removed (2.50 → "2.5", 3.00 → "3"),
    /// for unrounded doses that are only rounded once at the end of a calculation.
    var preciseString: String {
        var text = String(format: "%.2f", self)
        while text.hasSuffix("0") { text.removeLast() }
        if text.hasSuffix(".") { text.removeLast() }
        return text
    }
}
