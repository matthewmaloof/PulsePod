//
//  DiffbotDataTransformer.swift
//  PulsePod
//
//  Created by Matthew Maloof on 10/19/23.
//

import Foundation

struct DiffbotDataTransformer {
    static func transformJSONToDiffbotArticle(_ json: Any) -> Result<DiffbotArticle, Error> {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            let decodedArticle = try JSONDecoder().decode(DiffbotArticle.self, from: jsonData)
            return .success(decodedArticle)
        } catch let error {
            return .failure(error)
        }
    }
}
