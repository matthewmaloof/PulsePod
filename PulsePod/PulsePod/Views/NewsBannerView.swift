//
//  NewsBannerView.swift
//  PulsePod
//
//  Created by Matthew Maloof on 10/11/23.
//

import SwiftUI
import SwiftUIPager

struct NewsBannerView: View {
    @State var page: Page
    var newsArticles: [NewsArticle]

    var body: some View {
        let initialPage = Page.withIndex(newsArticles.indices.first ?? 0)
        Pager(page: initialPage,
              data: newsArticles,
              id: \.id,
              content: { article in
                  VStack(alignment: .leading) {
                      Text(article.title)
                          .font(.custom("YourCustomFontName", size: 24))
                          .foregroundColor(.white)
                  }
                  .frame(maxWidth: .infinity, maxHeight: .infinity)
                  .background(Color.blue)
                  .cornerRadius(10)
              })
        .frame(height: 200)
    }
}

