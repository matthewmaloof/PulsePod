//
//  SavedArticleViewModel.swift
//  PulsePod
//
//  Created by Matthew Maloof on 10/18/23.
//

import Combine
import CoreData

final class SavedArticleViewModel: ObservableObject {
    
    @Published var savedArticles: [SavedArticleEntity] = []
    @Published var inEditMode: Bool = false
    private var cancellables = Set<AnyCancellable>()
    var fetchedResultsController: NSFetchedResultsController<SavedArticleEntity>?
    
    init() {
        setupFetchedResultsController()
    }
    
    func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<SavedArticleEntity> = SavedArticleEntity.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \SavedArticleEntity.pinned, ascending: false),
            NSSortDescriptor(keyPath: \SavedArticleEntity.publishedAt, ascending: false)
        ]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: PersistenceController.shared.container.viewContext,
            sectionNameKeyPath: nil, cacheName: nil
        )
        
        do {
            try fetchedResultsController?.performFetch()
            self.savedArticles = fetchedResultsController?.fetchedObjects ?? []
        } catch {
            print("Failed to fetch items!")
        }
        
        NotificationCenter.default.publisher(for: .NSManagedObjectContextObjectsDidChange)
            .sink { [weak self] _ in
                self?.savedArticles = self?.fetchedResultsController?.fetchedObjects ?? []
            }
            .store(in: &cancellables)
    }
    
    func toggleEditMode() {
        inEditMode.toggle()
    }
    
    func togglePinStatus(for article: SavedArticleEntity) {
        article.pinned.toggle()
        saveContext()
    }
    
    func deleteArticle(_ article: SavedArticleEntity) {
        PersistenceController.shared.container.viewContext.delete(article)
        saveContext()
    }
    
    func unsaveAllArticles() {
        for article in savedArticles where !article.pinned {
            PersistenceController.shared.container.viewContext.delete(article)
        }
        saveContext()
    }
    
    func saveContext() {
        do {
            try PersistenceController.shared.container.viewContext.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
}
