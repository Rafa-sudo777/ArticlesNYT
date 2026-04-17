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
    @Test func isValidDayAcceptsSupportedValues() {
        #expect("1".isValidDay)
        #expect("7".isValidDay)
        #expect("30".isValidDay)
        #expect(" 30 ".isValidDay)
    }

    @Test func isValidDayRejectsUnsupportedValues() {
        #expect("".isValidDay == false)
        #expect("0".isValidDay == false)
        #expect("15".isValidDay == false)
        #expect("31".isValidDay == false)
        #expect("one".isValidDay == false)
    }

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
    @Test func getArticlesShowsInternetErrorWhenNetworkFails() async throws {
        let modelContext = try makeInMemoryModelContext()
        let networkManager = MockNetworkManager(result: .failure(URLError(.notConnectedToInternet)))
        let viewModel = ArticlesViewModel(networkManager: networkManager)
        
        await viewModel.getArticles(in: "30", modelContext: modelContext)
        
        let savedArticles = try fetchArticles(in: "30", modelContext: modelContext)
        
        #expect(networkManager.callCount == 1)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.showErrorMessage == NetworkError.noInternetConnection.errorDescription)
        #expect(savedArticles.isEmpty)
    }

    @MainActor
    @Test func getArticlesShowsTimeoutErrorWhenServerDoesNotRespond() async throws {
        let modelContext = try makeInMemoryModelContext()
        let networkManager = MockNetworkManager(result: .failure(URLError(.timedOut)))
        let viewModel = ArticlesViewModel(networkManager: networkManager)

        await viewModel.getArticles(in: "30", modelContext: modelContext)

        let savedArticles = try fetchArticles(in: "30", modelContext: modelContext)

        #expect(networkManager.callCount == 1)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.showErrorMessage == NetworkError.requestTimedOut.errorDescription)
        #expect(savedArticles.isEmpty)
    }

    @MainActor
    @Test func getArticlesRejectsInvalidDayBeforeCallingNetwork() async throws {
        let modelContext = try makeInMemoryModelContext()
        let networkManager = MockNetworkManager(result: .success([.fixture(title: "Unused")]))
        let viewModel = ArticlesViewModel(networkManager: networkManager)

        await viewModel.getArticles(in: "5", modelContext: modelContext)

        let savedArticles = try fetchArticles(in: "5", modelContext: modelContext)

        #expect(networkManager.callCount == 0)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.showErrorMessage == NetworkError.invalidDay.errorDescription)
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
