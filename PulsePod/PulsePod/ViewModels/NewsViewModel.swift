//
//  NewsViewModel.swift
//  PulsePod
//
//  Created by Matthew Maloof on 10/11/23.
//

import Combine
import Foundation

protocol NewsFetching {
    func fetchLatestNews(page: Int, completion: @escaping (Result<[NewsArticle], Error>) -> Void)
}

final class NewsViewModel: ObservableObject {
    @Published private(set) var currentPage: Int = 1
    @Published private(set) var articles: [NewsArticle] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var error: String?
    @Published private(set) var hasMoreData: Bool = true

    private let newsService: NewsFetching

    init(newsService: NewsFetching = NewsService()) {
            self.newsService = newsService
            fetchNews()
        }

    func fetchNews() {
        guard hasMoreData else { return }
        isLoading = true
        newsService.fetchLatestNews(page: currentPage) { [weak self] result in
            print("Fetch result: \(result)")
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.handleFetchResult(result)
            }
        }
    }

    private func handleFetchResult(_ result: Result<[NewsArticle], Error>) {
        switch result {
        case .success(let fetchedArticles):
            updateArticles(fetchedArticles)
        case .failure(let transformError):
            self.error = transformError.localizedDescription
        }
    }

    private func updateArticles(_ newArticles: [NewsArticle]) {
        if newArticles.isEmpty {
            hasMoreData = false
        } else {
            articles.append(contentsOf: newArticles)
            currentPage += 1
        }
    }
}
