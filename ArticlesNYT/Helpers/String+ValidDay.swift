//
//  String+ValidDay.swift
//  ArticlesNYT
//
//  Created by Rafael Aviles Puebla on 13/04/26.
//

import Foundation

extension String {
    var isValidDay: Bool {
        ["1", "7", "30"].contains(
            trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }
}
