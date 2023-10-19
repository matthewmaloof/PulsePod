//
//  NewsService.swift
//  PulsePod
//
//  Created by Matthew Maloof on 10/11/23.
//

import Alamofire
import Foundation

typealias NewsFetchCompletion = (Result<[NewsArticle], Error>) -> Void

protocol NewsbotAPI {
    func fetchLatestNews(page: Int, completion: @escaping NewsFetchCompletion)
}

protocol DiffbotAPI {
    func fetchFullArticleContent(from url: String, completion: @escaping (Result<DiffbotArticle, Error>) -> Void)
}




// NewsService class implementing both protocols
class NewsService: NewsbotAPI, NewsFetching {
    private var newsDataFetcher = NewsDataFetcher()
    private var diffbotAPIService = DiffbotAPIService()
    var isLoading: Bool = false
    var error: String?
    
    
    // Existing Newsbot API implementation
    func fetchLatestNews(page: Int, completion: @escaping (Result<[NewsArticle], Error>) -> Void) {
        newsDataFetcher.fetchLatestNews(page: page, completion: completion)
    }
    
    private func convertDiffbotArticlesToNewsArticles(_ diffbotArticles: [DiffbotArticle]) -> [NewsArticle] {
        return diffbotArticles.map { diffbotArticle in
            return NewsArticle(
                id: diffbotArticle.id,
                title: diffbotArticle.title,
                description: diffbotArticle.text,
                content: diffbotArticle.text,
                author: diffbotArticle.author,
                url: diffbotArticle.url ?? "",
                urlToImage: diffbotArticle.images?.first?.url,
                source: NewsArticle.Source(id: nil, name: "Diffbot")
            )
        }
    }
    
    func fetchFullArticleContent(from url: String, completion: @escaping (DiffbotArticle?, Error?) -> Void) {
            // Make sure the URL is percent encoded
            guard let encodedURL = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                completion(nil, NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
                return
            }
            
            // Construct the Diffbot URL with your token and the encoded article URL
            let diffbotURL = "https://api.diffbot.com/v3/article?token=ccc0d136d538513c8cc95c8d7621cf1e&url=\(encodedURL)"
            
            guard let requestURL = URL(string: diffbotURL) else {
                completion(nil, NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid Diffbot URL"]))
                return
            }

            let request = URLRequest(url: requestURL)
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    completion(nil, error)
                    return
                }
                
                guard let data = data else {
                    completion(nil, NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "No data received from Diffbot API"]))
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let diffbotResponse = try decoder.decode(DiffbotResponse.self, from: data)
                    completion(diffbotResponse.objects?.first, nil)
                } catch let decodingError {
                    completion(nil, decodingError)
                }
            }.resume()
        }
    
    private func handleFetchResult(_ result: Result<[DiffbotArticle], Error>, completion: @escaping NewsFetchCompletion) {
        isLoading = false
        
        switch result {
        case .success(let fetchedArticles):
            let newsArticles = convertDiffbotArticlesToNewsArticles(fetchedArticles)
            
            // Call the completion block with the successfully converted NewsArticle objects
            completion(.success(newsArticles))
            
        case .failure(let fetchError):
            self.error = fetchError.localizedDescription
            
            // Call the completion block with the error
            completion(.failure(fetchError))
        }
    }
    
    
}

// API Configuration containing constants
struct APIConfiguration {
    static let newsAPIKey = "a8db9950a033403986b5b01b703fd517"
    static let newsBaseURL = "https://newsapi.org/v2/top-headlines?country=us"
    static let diffbotAPIEndpoint = "https://api.diffbot.com/v3/article"
    static let diffbotToken = "ccc0d136d538513c8cc95c8d7621cf1e"
}
