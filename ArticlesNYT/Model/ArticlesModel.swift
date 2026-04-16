//
//  ArticlesModel.swift
//  ArticlesNYT
//
//  Created by Rafael Aviles Puebla on 13/04/26.
//

struct ArticlesModel: Decodable {
    let results: [Article]
    
    struct Article: Decodable {
        let title, abstract, publishedDate, byline: String
    }
}
