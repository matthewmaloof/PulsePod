//
//  NewsView.swift
//  PulsePod
//
//  Created by Matthew Maloof on 10/11/23.
//

import SwiftUI

struct NewsView: View {
    @ObservedObject var viewModel: NewsViewModel

    var body: some View {
        NavigationView {
            if viewModel.articles.isEmpty {
                Text("No articles available.")
            } else {
                List(viewModel.articles) { article in
                    VStack(alignment: .leading) {
                        Text(article.title)
                            .font(.custom("YourCustomFontName", size: 20))
                            .foregroundColor(.blue)
                            .padding(.bottom, 5)
                        Text(article.content ?? "")
                            .font(.custom("YourCustomFontName", size: 16))
                            .foregroundColor(.black)
                            .lineLimit(2)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .shadow(radius: 2)
                }
                .onAppear(perform: viewModel.fetchNews)
                .navigationTitle("PulsePod")
                .navigationBarItems(trailing: Image(systemName: "gear"))
            }
        }.navigationBarHidden(true) // Hide the navigation bar
    }
}
