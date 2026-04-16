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
            let cachedArticles = fetchArticles(in: day, modelContext: modelContext)
            guard cachedArticles.isEmpty else {
                isLoading = false
                return
            }

            do {
                let articles = try await networkManager.getArticles(in: day)
                let articleItems = articlesAdapter(articles: articles, day: day)
                saveArticles(articleItems, modelContext: modelContext)
            } catch {
                showErrorMessage = "No fue posible obtener los articulos."
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
}
