//
//  NewsDetailViewModel.swift
//  PulsePod
//
//  Created by Matthew Maloof on 10/13/23.
//

import Foundation

class NewsDetailViewModel: ObservableObject {
    var news: NewsArticle
    @Published var articleContent: DiffbotArticle?
    var urlSession: URLSession

    
    init(news: NewsArticle, urlSession: URLSession = URLSession.shared) {
        self.news = news
        self.urlSession = urlSession

    }
    
    func fetchFullContent(for url: String, completion: @escaping () -> Void) {
        let diffbotApiKey = "ccc0d136d538513c8cc95c8d7621cf1e"
        
        guard let encodedURL = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let diffbotURL = URL(string: "https://api.diffbot.com/v3/article?token=\(diffbotApiKey)&url=\(encodedURL)") else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: diffbotURL) { (data, response, error) in
            guard let data = data, error == nil,
                  let diffbotResponse = try? JSONDecoder().decode(DiffbotArticle.self, from: data) else {
                print("Failed to decode or received error")

                return
            }
            DispatchQueue.main.async {
                self.articleContent = diffbotResponse
                completion() // Call the completion handler when content is fetched
            }
        }
        
        task.resume()
    }
}
