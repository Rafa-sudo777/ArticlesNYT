//
//  DetailView.swift
//  ArticlesNYT
//
//  Created by Rafael Aviles Puebla on 14/04/26.
//

import SwiftUI

struct DetailView: View {
    let article: ArticleItem

    var body: some View {
        VStack {
            Text(article.title)
                .font(Font.largeTitle.bold())
                .padding(.bottom, 1)
                .padding(.top, 20)
            HStack {
                Image(systemName: "person.crop.circle")
                Text(article.byline)
                Spacer()
                Image(systemName: "calendar")
                Text(article.publishedDate)
            }
            .font(Font.subheadline)
            .padding(.top, 5)
            .padding(.bottom, 20)
            .foregroundColor(Color(.secondaryLabel))
            Text(article.abstract)
                .font(Font.body)
            Spacer()
        }
        .padding(.horizontal, 25)
    }
}

#Preview {
    let article = ArticleItem(day:"1",
                              title: "Michael Movie",
                              abstract: "The best movie ever made. A true classic of the genre portrait of a man who is a hero in his own story. distributed by 20th Century Fox.",
                              publishedDate: "20/04/26",
                              byline: "Rafael Aviles Puebla")
    DetailView(article: article)
}
