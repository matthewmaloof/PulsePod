//
//  NewsViewModelTests.swift
//  PulsePodTests
//
//  Created by Matthew Maloof on 10/19/23.
//

import XCTest
import Combine
@testable import PulsePod

class MockNewsService: NewsFetching {
    var fetchLatestNewsCalled = false
    var result: Result<[NewsArticle], Error> = .success([])

    func fetchLatestNews(page: Int, completion: @escaping (Result<[NewsArticle], Error>) -> Void) {
        fetchLatestNewsCalled = true
        completion(result)
    }
}

class NewsViewModelTests: XCTestCase {
    var viewModel: NewsViewModel!
    var mockNewsService: MockNewsService!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockNewsService = MockNewsService()
        viewModel = NewsViewModel(newsService: mockNewsService)
        cancellables = Set<AnyCancellable>()
    }

    override func tearDown() {
        viewModel = nil
        mockNewsService = nil
        cancellables = nil
        super.tearDown()
    }

    func testFetchNewsSuccess() {
        let expectation = XCTestExpectation(description: "Fetch News Success")

        viewModel.fetchNews()

        XCTAssertTrue(viewModel.isLoading)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            XCTAssertTrue(self.mockNewsService.fetchLatestNewsCalled)
            XCTAssertFalse(self.viewModel.isLoading)
            XCTAssertNil(self.viewModel.error)
            XCTAssertTrue(self.viewModel.hasMoreData)
            XCTAssertEqual(self.viewModel.currentPage, 2)
            XCTAssertEqual(self.viewModel.articles.count, 0) // Should be empty as we're using a mock service with an empty result
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testFetchNewsFailure() {
        let expectation = XCTestExpectation(description: "Fetch News Failure")
        let errorMessage = "An error occurred."

        mockNewsService.result = .failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: errorMessage]))

        viewModel.fetchNews()

        XCTAssertTrue(viewModel.isLoading)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            XCTAssertTrue(self.mockNewsService.fetchLatestNewsCalled)
            XCTAssertFalse(self.viewModel.isLoading)
            XCTAssertEqual(self.viewModel.error, errorMessage)
            XCTAssertTrue(self.viewModel.hasMoreData)
            XCTAssertEqual(self.viewModel.currentPage, 1) // Should not increment on failure
            XCTAssertEqual(self.viewModel.articles.count, 0) // Should be empty as we're using a mock service with a failure result
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }
}
