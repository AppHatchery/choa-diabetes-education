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
}
