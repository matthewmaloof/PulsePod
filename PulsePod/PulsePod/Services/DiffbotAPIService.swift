//
//  DiffbotAPIService.swift
//  PulsePod
//
//  Created by Matthew Maloof on 10/19/23.
//

import Foundation
import Alamofire

class DiffbotAPIService: DiffbotAPI {
    
    // Fetch full article content from Diffbot API
    func fetchFullArticleContent(from url: String, completion: @escaping (Result<DiffbotArticle, Error>) -> Void) {
        
        // Build the URL with query parameters
        var urlComponents = URLComponents(string: APIConfiguration.diffbotAPIEndpoint)
        urlComponents?.queryItems = [
            URLQueryItem(name: "token", value: APIConfiguration.diffbotToken),
            URLQueryItem(name: "url", value: url)
        ]
        
        // Check if the URL is valid
        guard let finalURL = urlComponents?.url else {
            completion(.failure(NSError(domain: "DiffbotAPIService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to prepare URL"])))
            return
        }
        
        // Make the API request
        AF.request(finalURL).responseJSON { response in
            switch response.result {
            case .success(let data):
                // Assume you have a DiffbotDataTransformer class that handles JSON decoding
                // Let's use a function transformJSONToDiffbotArticle() for now
                let transformResult = DiffbotDataTransformer.transformJSONToDiffbotArticle(data)
                
                switch transformResult {
                case .success(let article):
                    completion(.success(article))
                case .failure(let error):
                    completion(.failure(error))
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
