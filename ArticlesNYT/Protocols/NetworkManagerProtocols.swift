//
//  NetworkManagerProtocols.swift
//  ArticlesNYT
//
//  Created by Rafael Aviles Puebla on 13/04/26.
//

protocol NetworkManagerProtocols {
    func getArticles(in day: String) async throws -> [ArticlesModel.Article]
}
