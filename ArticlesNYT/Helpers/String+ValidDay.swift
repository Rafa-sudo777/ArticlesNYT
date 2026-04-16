//
//  String+ValidDay.swift
//  ArticlesNYT
//
//  Created by Rafael Aviles Puebla on 13/04/26.
//

extension String {
    var isValidDay: Bool {
        ["1", "7", "30"].contains(self)
    }
}
