//
//  NewsAPI.swift
//  PulsePod
//
//  Created by Matthew Maloof on 10/11/23.
//

import Foundation
struct NewsAPI {
    static let shared = NewsAPI()
    private init() {}
    
    private let apiKey = "YOUR_API_KEY_HERE"
    private let baseURL = "https://newsapi.org/v2/top-headlines?country=us&apiKey="

    func fetchTopHeadlines(completion: @escaping ([NewsArticle]?) -> Void) {
        let urlString = baseURL + apiKey
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil,
                  let newsResponse = try? JSONDecoder().decode(NewsResponse.self, from: data) else {
                completion(nil)
                return
            }
            
            completion(newsResponse.articles)
        }
        
        task.resume()
    }
}

struct NewsResponse: Decodable {
    let status: String
    let totalResults: Int
    let articles: [NewsArticle]
}
