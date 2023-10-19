//
//  NewsDataFetcher.swift
//  PulsePod
//
//  Created by Matthew Maloof on 10/19/23.
//

import Foundation
import Alamofire

class NewsDataFetcher: NewsbotAPI {
    
    func fetchLatestNews(page: Int, completion: @escaping (Result<[NewsArticle], Error>) -> Void) {
        let parameters: Parameters = [
            "apiKey": APIConfiguration.newsAPIKey,
            "country": "us",
            "page": page
        ]
        
        AF.request(APIConfiguration.newsBaseURL, parameters: parameters).responseJSON { response in
            switch response.result {
            case .success(let data):
                guard let json = data as? [String: Any],
                      let articlesJSON = json["articles"] as? [[String: Any]] else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: nil)))
                    return
                }
                print("API Response: \(data)")
                
                if articlesJSON.isEmpty {
                    completion(.success([]))
                    return
                }
                
                let news = articlesJSON.compactMap { articleJSON -> NewsArticle? in
                    guard let title = articleJSON["title"] as? String,
                          let description = articleJSON["description"] as? String,
                          let content = articleJSON["content"] as? String,
                          let author = articleJSON["author"] as? String,
                          let url = articleJSON["url"] as? String,
                          let urlToImage = articleJSON["urlToImage"] as? String,
                          let sourceJSON = articleJSON["source"] as? [String: Any],
                          let sourceName = sourceJSON["name"] as? String else {
                        return nil
                    }
                    
                    let sourceId = sourceJSON["id"] as? String
                    
                    return NewsArticle(id: UUID().uuidString, title: title, description: description, content: content, author: author, url: url, urlToImage: urlToImage, source: NewsArticle.Source(id: sourceId, name: sourceName))
                }
                
                completion(.success(news))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        
        struct NewsAPIResponse: Decodable {
            let articles: [NewsArticle]
        }
    }
}
