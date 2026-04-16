//
//  NetworkManager.swift
//  ArticlesNYT
//
//  Created by Rafael Aviles Puebla on 13/04/26.
//
import Foundation

final class NetworkManager: NetworkManagerProtocols {
    func getArticles(in day: String) async throws -> [ArticlesModel.Article] {
        guard let url = URL(string: "https://api.nytimes.com/svc/mostpopular/v2/emailed/\(day).json?api-key=qTl6HA9lEk9bHwEMNSrdjRAceMnSqQEZ") else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.timeoutInterval = 10
        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw URLError(.badServerResponse)
            }

            guard 200...299 ~= httpResponse.statusCode else {
                throw URLError(.badServerResponse)
            }

            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase

            let articles = try decoder.decode(ArticlesModel.self, from: data).results
            return articles
        } catch {
            throw error
        }
    }
}
