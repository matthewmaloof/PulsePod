//
//  CoreDataService.swift
//  PulsePod
//
//  Created by Matthew Maloof on 10/11/23.
//

import Foundation
import CoreData

class CoreDataService {
    static let shared = CoreDataService()

    private init() {}

    func saveArticles(_ articles: [NewsArticle], in context: NSManagedObjectContext) {
        articles.forEach { article in
            let entity = NSEntityDescription.insertNewObject(forEntityName: "NewsArticleEntity", into: context) as! NewsArticleEntity
            entity.id = article.id
            entity.title = article.title
            entity.articleDescription = article.description
        
            entity.content = article.content
            entity.author = article.author
            entity.url = article.url
            entity.urlToImage = article.urlToImage
            entity.sourceName = article.source.name
            if let sourceId = article.source.id {
                entity.sourceId = sourceId
            }
            do {
                try context.save()
            } catch {
                print("Failed to save article to CoreData:", error)
            }
        }
    }

    func fetchArticles(in context: NSManagedObjectContext) -> [NewsArticle] {
        let fetchRequest = NSFetchRequest<NewsArticleEntity>(entityName: "NewsArticleEntity")
        
        do {
            let entities = try context.fetch(fetchRequest)
            return entities.map {
                NewsArticle(
                    id: $0.id!,
                    title: $0.title!,
                    description: $0.articleDescription!,
                    content: $0.content,
                    author: $0.author,
                    url: $0.url!,
                    urlToImage: $0.urlToImage,
                    source: NewsArticle.Source(id: $0.sourceId, name: $0.sourceName!)
                )
            }
        } catch {
            print("Failed to fetch articles from CoreData: \(error)")
            return []
        }
    }
}
