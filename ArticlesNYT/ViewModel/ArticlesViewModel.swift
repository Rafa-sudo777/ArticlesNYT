import Foundation
import Combine
import SwiftData

final class ArticlesViewModel: ObservableObject {
    @Published var showErrorMessage: String?
    @Published var isLoading = true
    
    let networkManager: NetworkManagerProtocols
    
    init(networkManager: NetworkManagerProtocols = NetworkManager()) {
        self.networkManager = networkManager
    }
    
    @MainActor
    func getArticles(in day: String, modelContext: ModelContext) async {
            guard day.isValidDay else {
                showErrorMessage = NetworkError.invalidDay.errorDescription
                isLoading = false
                return
            }

            let normalizedDay = day.trimmingCharacters(in: .whitespacesAndNewlines)
            let cachedArticles = fetchArticles(in: normalizedDay, modelContext: modelContext)
            guard cachedArticles.isEmpty else {
                isLoading = false
                return
            }

            do {
                let articles = try await networkManager.getArticles(in: normalizedDay)
                let articleItems = articlesAdapter(articles: articles, day: normalizedDay)
                saveArticles(articleItems, modelContext: modelContext)
            } catch {
                showErrorMessage = resolveErrorMessage(from: error)
            }

            isLoading = false
    }
    
    private func articlesAdapter(articles: [ArticlesModel.Article], day: String) -> [ArticleItem] {
        articles.map { article in
            ArticleItem(
                day: day,
                title: article.title,
                abstract: article.abstract,
                publishedDate: article.publishedDate,
                byline: article.byline
            )
        }
    }

    @MainActor
    private func fetchArticles(in day: String, modelContext: ModelContext) -> [ArticleItem] {
        let descriptor = FetchDescriptor<ArticleItem>(
            predicate: #Predicate<ArticleItem> { item in
                item.day == day
            }
        )

        do {
            return try modelContext.fetch(descriptor)
        } catch {
            showErrorMessage = "No fue posible leer los articulos guardados."
            return []
        }
    }

    @MainActor
    private func saveArticles(_ articles: [ArticleItem], modelContext: ModelContext) {
        guard articles.isEmpty == false else { return }

        articles.forEach { article in
            modelContext.insert(article)
        }

        do {
            try modelContext.save()
        } catch {
            showErrorMessage = "No fue posible guardar los articulos para uso offline."
        }
    }

    private func resolveErrorMessage(from error: Error) -> String {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost:
                return NetworkError.noInternetConnection.errorDescription ?? NetworkError.unexpected.errorDescription ?? ""
            case .timedOut:
                return NetworkError.requestTimedOut.errorDescription ?? NetworkError.unexpected.errorDescription ?? ""
            case .badServerResponse, .cannotFindHost, .cannotConnectToHost:
                return NetworkError.serverUnavailable.errorDescription ?? NetworkError.unexpected.errorDescription ?? ""
            default:
                return NetworkError.unexpected.errorDescription ?? ""
            }
        }

        if let localizedError = error as? LocalizedError,
           let description = localizedError.errorDescription {
            return description
        }

        return "Ocurrio un error inesperado al obtener los articulos."
    }
}
