//
//  ArticlesNYTTests.swift
//  ArticlesNYTTests
//
//  Created by Rafael Aviles Puebla on 13/04/26.
//

import Foundation
import Testing
import SwiftData
@testable import ArticlesNYT

struct ArticlesNYTTests {
    @MainActor
    @Test func getArticlesUsesCachedArticlesWithoutCallingNetwork() async throws {
        let modelContext = try makeInMemoryModelContext()
        let cachedArticle = ArticleItem(
            day: "1",
            title: "Cached title",
            abstract: "Cached abstract",
            publishedDate: "2026-04-13",
            byline: "Cached byline"
        )
        modelContext.insert(cachedArticle)
        try modelContext.save()
        
        let networkManager = MockNetworkManager(result: .success([
            .fixture(title: "Remote title")
        ]))
        let viewModel = ArticlesViewModel(networkManager: networkManager)
        
        await viewModel.getArticles(in: "1", modelContext: modelContext)
        
        let savedArticles = try fetchArticles(in: "1", modelContext: modelContext)
        
        #expect(networkManager.callCount == 0)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.showErrorMessage == nil)
        #expect(savedArticles.count == 1)
        #expect(savedArticles.first?.title == "Cached title")
    }

    @MainActor
    @Test func getArticlesSavesFetchedArticlesWhenCacheIsEmpty() async throws {
        let modelContext = try makeInMemoryModelContext()
        let networkManager = MockNetworkManager(result: .success([
            .fixture(title: "Article 1"),
            .fixture(title: "Article 2")
        ]))
        let viewModel = ArticlesViewModel(networkManager: networkManager)
        
        await viewModel.getArticles(in: "7", modelContext: modelContext)
        
        let savedArticles = try fetchArticles(in: "7", modelContext: modelContext)
        
        #expect(networkManager.callCount == 1)
        #expect(networkManager.receivedDays == ["7"])
        #expect(viewModel.isLoading == false)
        #expect(viewModel.showErrorMessage == nil)
        #expect(savedArticles.count == 2)
        #expect(savedArticles.map(\.title) == ["Article 1", "Article 2"])
        #expect(savedArticles.allSatisfy { $0.day == "7" })
    }

    @MainActor
    @Test func getArticlesShowsErrorWhenNetworkFails() async throws {
        let modelContext = try makeInMemoryModelContext()
        let networkManager = MockNetworkManager(result: .failure(URLError(.notConnectedToInternet)))
        let viewModel = ArticlesViewModel(networkManager: networkManager)
        
        await viewModel.getArticles(in: "30", modelContext: modelContext)
        
        let savedArticles = try fetchArticles(in: "30", modelContext: modelContext)
        
        #expect(networkManager.callCount == 1)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.showErrorMessage == "No fue posible obtener los articulos.")
        #expect(savedArticles.isEmpty)
    }
}

private extension ArticlesNYTTests {
    @MainActor
    func makeInMemoryModelContext() throws -> ModelContext {
        let schema = Schema([ArticleItem.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        return ModelContext(container)
    }
    
    @MainActor
    func fetchArticles(in day: String, modelContext: ModelContext) throws -> [ArticleItem] {
        let descriptor = FetchDescriptor<ArticleItem>(
            predicate: #Predicate<ArticleItem> { item in
                item.day == day
            },
            sortBy: [SortDescriptor(\.title)]
        )
        return try modelContext.fetch(descriptor)
    }
}

private final class MockNetworkManager: NetworkManagerProtocols {
    private let result: Result<[ArticlesModel.Article], Error>
    private(set) var callCount = 0
    private(set) var receivedDays: [String] = []
    
    init(result: Result<[ArticlesModel.Article], Error>) {
        self.result = result
    }
    
    func getArticles(in day: String) async throws -> [ArticlesModel.Article] {
        callCount += 1
        receivedDays.append(day)
        return try result.get()
    }
}

private extension ArticlesModel.Article {
    static func fixture(
        title: String,
        abstract: String = "Abstract",
        publishedDate: String = "2026-04-13",
        byline: String = "Byline"
    ) -> Self {
        .init(
            title: title,
            abstract: abstract,
            publishedDate: publishedDate,
            byline: byline
        )
    }
}
