//
//  DiffbotArticle.swift
//  PulsePod
//
//  Created by Matthew Maloof on 10/13/23.
//

struct DiffbotArticle: Identifiable, Codable, Equatable {
    var id: String { url ?? "" }
    var title: String
    var text: String
    var url: String?
    let author: String?
    let date: String?
    let images: [DiffbotImage]?
}

// Also for DiffbotImage if you intend to compare it as part of DiffbotArticle
struct DiffbotImage: Codable, Equatable {
    let url: String
}

struct DiffbotResponse: Decodable {
    let objects: [DiffbotArticle]?
}
