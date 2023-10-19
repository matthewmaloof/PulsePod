import XCTest
@testable import PulsePod

class MockURLSession: URLSession {
    var dataTaskCalled = false
    var mockData: Data?
    var mockError: Error?
    
    override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        print("Mock Data:", String(data: mockData ?? Data(), encoding: .utf8) ?? "None")
            print("Mock Error:", mockError?.localizedDescription ?? "None")
        dataTaskCalled = true
        completionHandler(mockData, nil, mockError)
        return URLSessionDataTask()
    }
}

class NewsDetailViewModelTests: XCTestCase {

    var mockSession: MockURLSession!
    var newsArticle: NewsArticle!

    override func setUp() {
        super.setUp()
        mockSession = MockURLSession()
        print("Mock session in setup: \(mockSession)")

        newsArticle = NewsArticle(id: "1",
                                  title: "Title",
                                  description: "Description",
                                  content: nil,
                                  author: nil,
                                  url: "https://www.example.com",
                                  urlToImage: nil,
                                  source: NewsArticle.Source(id: nil, name: "Source"))
    }

    func testSuccessfulFetch() {
        let expectation = self.expectation(description: "Fetch should succeed")
        
        let jsonData = """
            {
                "title": "Title",
                "text": "Text",
                "url": "https://www.example.com",
                "author": "Author",
                "date": "Date",
                "images": [{"url": "https://image.url"}]
            }
        """.data(using: .utf8)
        
        mockSession.mockData = jsonData
        
        let viewModel = NewsDetailViewModel(news: newsArticle, urlSession: mockSession)
        print("Session in ViewModel: \(viewModel.urlSession)")

        
        viewModel.fetchFullContent(for: newsArticle.url) {
            XCTAssertTrue(self.mockSession.dataTaskCalled)
            
            XCTAssertNotNil(viewModel.articleContent)
            XCTAssertEqual(viewModel.articleContent?.title, "Title")
            XCTAssertEqual(viewModel.articleContent?.text, "Text")
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testFetchFailure() {
        let expectation = self.expectation(description: "Fetch should fail")
        
        mockSession.mockError = NSError(domain: "TestError", code: 1, userInfo: nil)
        
        let viewModel = NewsDetailViewModel(news: newsArticle, urlSession: mockSession)
        
        viewModel.fetchFullContent(for: newsArticle.url) {
            XCTAssertTrue(self.mockSession.dataTaskCalled)
            
            XCTAssertNil(viewModel.articleContent)
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
}

