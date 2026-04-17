//
//  NetworkManager.swift
//  ArticlesNYT
//
//  Created by Rafael Aviles Puebla on 13/04/26.
//
import Foundation

final class NetworkManager: NetworkManagerProtocols {
    func getArticles(in day: String) async throws -> [ArticlesModel.Article] {
        guard day.isValidDay else {
            throw NetworkError.invalidDay
        }

        guard let url = URL(string: "https://api.nytimes.com/svc/mostpopular/v2/emailed/\(day).json?api-key=qTl6HA9lEk9bHwEMNSrdjRAceMnSqQEZ") else {
            throw NetworkError.invalidResponse
        }
        var request = URLRequest(url: url)
        request.timeoutInterval = 10

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }

            guard 200...299 ~= httpResponse.statusCode else {
                throw NetworkError.serverUnavailable
            }

            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase

            let articles: [ArticlesModel.Article]

            do {
                articles = try decoder.decode(ArticlesModel.self, from: data).results
            } catch {
                throw NetworkError.decodingFailed
            }

            return articles
        } catch let error as NetworkError {
            throw error
        } catch let error as URLError {
            switch error.code {
            case .notConnectedToInternet, .networkConnectionLost:
                throw NetworkError.noInternetConnection
            case .timedOut:
                throw NetworkError.requestTimedOut
            case .badServerResponse, .cannotFindHost, .cannotConnectToHost:
                throw NetworkError.serverUnavailable
            default:
                throw NetworkError.unexpected
            }
        } catch {
            throw NetworkError.unexpected
        }
    }
}
