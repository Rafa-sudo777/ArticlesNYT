//
//  ArticleItem.swift
//  ArticlesNYT
//
//  Created by Rafael Aviles Puebla on 13/04/26.
//

import SwiftData

@Model
final class ArticleItem {
    var day: String
    var title: String
    var abstract: String
    var publishedDate: String
    var byline: String
    
    init(day: String, title: String, abstract: String, publishedDate: String, byline: String) {
        self.day = day
        self.title = title
        self.abstract = abstract
        self.publishedDate = publishedDate
        self.byline = byline
    }
}
