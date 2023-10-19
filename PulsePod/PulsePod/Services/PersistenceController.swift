//
//  Persistence.swift
//  PulsePod
//
//  Created by Matthew Maloof on 10/10/23.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext

        do {
            try viewContext.save()
        } catch {

            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "PulsePod")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {

                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    

    func isArticleSaved(id: String) -> Bool {
        let fetchRequest: NSFetchRequest<SavedArticleEntity> = SavedArticleEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        do {
            let matchingArticles = try container.viewContext.fetch(fetchRequest)
            return !matchingArticles.isEmpty
        } catch {
            print("Error checking saved article: \(error)")
            return false
        }
    }

}

extension PersistenceController {
    func saveArticle(_ article: NewsArticle, context: NSManagedObjectContext? = nil) {
        let actualContext = context ?? container.viewContext
        let savedArticle = SavedArticleEntity(context: actualContext)
        savedArticle.id = article.id
        savedArticle.title = article.title
        savedArticle.desc = article.description
        savedArticle.content = article.content
        savedArticle.author = article.author
        savedArticle.url = article.url
        savedArticle.urlToImage = article.urlToImage
        savedArticle.sourceName = article.source.name
    

        do {
            try actualContext.save()
            print("Article saved!")
        } catch {
            print("Error saving article: \(error)")
        }
    }
    
    func unsaveArticle(id: String) {
        let fetchRequest: NSFetchRequest<SavedArticleEntity> = SavedArticleEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)

        do {
            let savedArticles = try container.viewContext.fetch(fetchRequest)
            if let savedArticle = savedArticles.first {
                container.viewContext.delete(savedArticle)
                try container.viewContext.save()
            }
        } catch {
            print("Failed to unsave article: \(error)")
        }
    }
    
    // Fetch the SavedArticleEntity for a given NewsArticle. If none exists, return nil.
    func getSavedArticleEntity(for article: NewsArticle) -> SavedArticleEntity? {
        let fetchRequest: NSFetchRequest<SavedArticleEntity> = SavedArticleEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", article.id ?? "")

        do {
            let matchingArticles = try container.viewContext.fetch(fetchRequest)
            return matchingArticles.first
        } catch {
            print("Error fetching saved article entity: \(error)")
            return nil
        }
    }



}
