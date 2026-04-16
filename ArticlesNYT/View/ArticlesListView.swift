//
//  ArticlesListView.swift
//  ArticlesNYT
//
//  Created by Rafael Aviles Puebla on 13/04/26.
//

import SwiftUI
import SwiftData

struct ArticlesListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [ArticleItem]
    
    @StateObject private var viewModel = ArticlesViewModel()
    let days: String
    
    init(days: String) {
        self.days = days
        _items = Query(
            filter: #Predicate<ArticleItem> { item in
                item.day == days
            }
        )
    }

    var body: some View {
        Group {
            if viewModel.isLoading && items.isEmpty {
                ProgressView()
                    .progressViewStyle(.circular)
            } else if items.isEmpty {
                ContentUnavailableView(
                    "No hay artículos",
                    systemImage: "newspaper",
                    description: Text("No fue posible cargar artículos para \(days) días.")
                )
            } else {
                List(items) { item in
                    NavigationLink(destination: DetailView(article: item)) {
                        Text(item.title)
                            .font(.subheadline)
                            .lineLimit(1)
                    }
                }
            }
        }
        .navigationTitle("Articulos")
        .task(id: days) {
            await viewModel.getArticles(in: days, modelContext: modelContext)
        }
        .alert("Error", isPresented: errorBinding) {
        } message: {
            if let showErrorMessage = viewModel.showErrorMessage {
                Text(showErrorMessage)
            }
        }
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { viewModel.showErrorMessage != nil },
            set: { newValue in
                if newValue == false {
                    viewModel.showErrorMessage = nil
                }
            }
        )
    }
}

#Preview {
    NavigationStack {
        ArticlesListView(days: "1")
            .modelContainer(for: ArticleItem.self, inMemory: true)
    }
}
