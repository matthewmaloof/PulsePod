//
//  NewsListViewModel.swift
//  PulsePod
//
//  Created by Matthew Maloof on 10/11/23.
//

import Combine
import Foundation

final class NewsListViewModel: ObservableObject {
    @Published var newsArticles: [NewsArticle] = []
    
    var currentPage = 1
    private let newsService: NewsFetching
    
    // Dependency Injection
    init(newsService: NewsFetching = NewsService()) {
        self.newsService = newsService
        fetchMoreData()
    }
    
    func shouldLoadMoreData(currentItem: NewsArticle?) -> Bool {
        guard let currentItem = currentItem else { return false }
        let thresholdIndex = newsArticles.index(newsArticles.endIndex, offsetBy: -5)
        return newsArticles.firstIndex(where: { $0.id == currentItem.id }) == thresholdIndex
    }
    
    func fetchMoreData() {
        newsService.fetchLatestNews(page: currentPage) { [weak self] result in
            DispatchQueue.main.async {
                self?.handleFetchResult(result)
            }
        }
    }
    
    private func handleFetchResult(_ result: Result<[NewsArticle], Error>) {
        switch result {
        case .success(let articles):
            newsArticles += articles
            print("Current Page before API call: \(currentPage)")
            currentPage += 1
        case .failure(let error):
            print("Error fetching more news: \(error)") // This could be enhanced to surface errors to the UI
        }
    }
    
    func refreshData() {
        currentPage = 1
        newsArticles = []
        fetchMoreData()
    }
}
