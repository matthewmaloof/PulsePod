//
//  NewsArticle.swift
//  PulsePod
//
//  Created by Matthew Maloof on 10/11/23.
//

import Foundation

struct NewsArticle: Identifiable, Decodable, Equatable {
    // Identifying properties
    var id: String
    var title: String
    var description: String
    var content: String?
    var author: String?
    var url: String
    var urlToImage: String?
    var source: Source
    
    // Nested structure to represent the source of the news article
    struct Source: Decodable, Equatable {
        var id: String?
        var name: String
    }
}

