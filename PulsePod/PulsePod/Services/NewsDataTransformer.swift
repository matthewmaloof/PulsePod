//
//  NewsDataTransformer.swift
//  PulsePod
//
//  Created by Matthew Maloof on 10/19/23.
//

import Foundation

class NewsDataTransformer {
    static func transformJSONToArticles(_ jsonData: Any) -> Result<[NewsArticle], Error> {
        do {
            let data = try JSONSerialization.data(withJSONObject: jsonData, options: [])
            let decodedResponse = try JSONDecoder().decode(NewsResponse.self, from: data)
            return .success(decodedResponse.articles)
        } catch let error {
            return .failure(error)
        }
    }
}

