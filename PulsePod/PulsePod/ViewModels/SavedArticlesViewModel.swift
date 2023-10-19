//
//  SavedArticlesViewModel.swift
//  PulsePod
//
//  Created by Matthew Maloof on 10/17/23.
//

import SwiftUI
import CoreData

class SavedArticlesViewModel: ObservableObject {
    @Published var savedArticles: [SavedArticleEntity] = []
    
    var viewContext: NSManagedObjectContext = PersistenceController.shared.container.viewContext
    
    init() {
        fetchSavedArticles()
    }
    
    func fetchSavedArticles() {
        let fetchRequest: NSFetchRequest<SavedArticleEntity> = SavedArticleEntity.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \SavedArticleEntity.pinned, ascending: false),
            NSSortDescriptor(keyPath: \SavedArticleEntity.publishedAt, ascending: false)
        ]
        
        do {
            self.savedArticles = try viewContext.fetch(fetchRequest)
        } catch {
            print("Failed to fetch saved articles: \(error)")
        }
    }
    
    func togglePinStatus(for article: SavedArticleEntity) {
        article.pinned.toggle()
        saveContext()
    }
    
    func deleteSavedArticle(_ article: SavedArticleEntity) {
        viewContext.delete(article)
        saveContext()
    }
    
    func unsaveAllArticles() {
        for article in savedArticles {
            if !article.pinned {
                viewContext.delete(article)
            }
        }
        saveContext()
    }
    
    func saveContext() {
        do {
            try viewContext.save()
            fetchSavedArticles()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
}
