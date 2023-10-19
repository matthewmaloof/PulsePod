//
//  NewsListViewModelTests.swift
//  PulsePodTests
//
//  Created by Matthew Maloof on 10/19/23.
//

import XCTest
import Combine
@testable import PulsePod


class NewsListViewModelTests: XCTestCase {
    var viewModel: NewsListViewModel!
    var mockNewsService: MockNewsService!

    override func setUp() {
        super.setUp()
        mockNewsService = MockNewsService()
        viewModel = NewsListViewModel(newsService: mockNewsService)
    }

    override func tearDown() {
        viewModel = nil
        mockNewsService = nil
        super.tearDown()
    }

    func testShouldLoadMoreData() {
        let article1 = NewsArticle(id: "1", title: "Title 1", description: "Description 1", content: "Content 1", url: "https://example1.com", source: NewsArticle.Source(name: "Source 1"))
        let article2 = NewsArticle(id: "2", title: "Title 2", description: "Description 2", content: "Content 2", url: "https://example2.com", source: NewsArticle.Source(name: "Source 2"))
        let article3 = NewsArticle(id: "3", title: "Title 3", description: "Description 3", content: "Content 3", url: "https://example3.com", source: NewsArticle.Source(name: "Source 3"))

        viewModel.newsArticles = [article1, article2, article3]

        // Test when currentItem is nil
        XCTAssertFalse(viewModel.shouldLoadMoreData(currentItem: nil))

        // Test when currentItem is not found in the list
        let article4 = NewsArticle(id: "4", title: "Title 4", description: "Description 4", content: "Content 4", url: "https://example4.com", source: NewsArticle.Source(name: "Source 4"))
        XCTAssertFalse(viewModel.shouldLoadMoreData(currentItem: article4))

        // Test when currentItem is found at threshold index
        XCTAssertTrue(viewModel.shouldLoadMoreData(currentItem: article1))
    }

    func testFetchMoreData() {
        let expectation = XCTestExpectation(description: "Fetch More Data")

        viewModel.fetchMoreData()

        XCTAssertTrue(mockNewsService.fetchLatestNewsCalled)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            XCTAssertEqual(self.viewModel.newsArticles.count, 0) // Should be empty as we're using a mock service with an empty result
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testRefreshData() {
        let article1 = NewsArticle(id: "1", title: "Title 1", description: "Description 1", content: "Content 1", url: "https://example.com", source: NewsArticle.Source(name: "Source 1"))
        let article2 = NewsArticle(id: "2", title: "Title 2", description: "Description 2", content: "Content 2", url: "https://example2.com", source: NewsArticle.Source(name: "Source 2"))

        viewModel.newsArticles = [article1, article2]

        viewModel.refreshData()

        XCTAssertEqual(viewModel.currentPage, 1)
        XCTAssertEqual(viewModel.newsArticles.count, 0) // Should be cleared after refresh
    }
}

