//
//  SavedArticleViewModelTests.swift
//  PulsePodTests
//
//  Created by Matthew Maloof on 10/19/23.
//

import XCTest
import CoreData
@testable import PulsePod

struct MockPersistenceController {
    var container: NSPersistentContainer

    init(inMemory: Bool = true) {
        self.container = NSPersistentContainer(name: "PulsePod")
        if inMemory {
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            self.container.persistentStoreDescriptions = [description]
        }

        self.container.loadPersistentStores { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
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

    func saveArticle(_ article: NewsArticle) {
        let savedArticle = SavedArticleEntity(context: container.viewContext)
        savedArticle.id = article.id
        savedArticle.title = article.title
        savedArticle.desc = article.description
        savedArticle.content = article.content
        savedArticle.author = article.author
        savedArticle.url = article.url
        savedArticle.urlToImage = article.urlToImage
        savedArticle.sourceName = article.source.name

        do {
            try container.viewContext.save()
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



class SavedArticleViewModelTests: XCTestCase {
    var viewModel: SavedArticleViewModel!
    var mockPersistenceController: MockPersistenceController!

    override func setUp() {
        super.setUp()
        mockPersistenceController = MockPersistenceController()
        viewModel = SavedArticleViewModel()
        viewModel.savedArticles = [SavedArticleEntity(), SavedArticleEntity()]
    }

    override func tearDown() {
        viewModel = nil
        mockPersistenceController = nil
        super.tearDown()
    }

    func testTogglePinStatus() {
        let article = SavedArticleEntity(context: mockPersistenceController.container.viewContext)
        article.pinned = false

        viewModel.togglePinStatus(for: article)

        XCTAssertTrue(article.pinned)
        XCTAssertNoThrow(try mockPersistenceController.container.viewContext.save())
    }

    func testDeleteArticle() {
        let article = SavedArticleEntity(context: mockPersistenceController.container.viewContext)
        article.pinned = false

        viewModel.deleteArticle(article)

        XCTAssertTrue(article.isDeleted)
        XCTAssertNoThrow(try mockPersistenceController.container.viewContext.save())
    }

    func testUnsaveAllArticles() {
        let article1 = SavedArticleEntity(context: mockPersistenceController.container.viewContext)
        article1.pinned = false
        let article2 = SavedArticleEntity(context: mockPersistenceController.container.viewContext)
        article2.pinned = true
        viewModel.savedArticles = [article1, article2]

        viewModel.unsaveAllArticles()

        XCTAssertTrue(article1.isDeleted)
        XCTAssertFalse(article2.isDeleted)
        XCTAssertNoThrow(try mockPersistenceController.container.viewContext.save())
    }

    // Additional tests for CoreData fetch request setup, notifications, and inEditMode
    func testSetupFetchedResultsController() {
        viewModel.setupFetchedResultsController()
        XCTAssertNotNil(viewModel.fetchedResultsController)
        XCTAssertNoThrow(try viewModel.fetchedResultsController?.performFetch())
        XCTAssertEqual(viewModel.savedArticles.count, 0)
    }

    func testInEditModeToggle() {
        XCTAssertFalse(viewModel.inEditMode)
        viewModel.toggleEditMode()
        XCTAssertTrue(viewModel.inEditMode)
        viewModel.toggleEditMode()
        XCTAssertFalse(viewModel.inEditMode)
    }

    // Test saveContext by adding a new article
    func testSaveContext() {
        let article = SavedArticleEntity(context: mockPersistenceController.container.viewContext)
        article.pinned = false
        viewModel.savedArticles.append(article)

        viewModel.saveContext()

        XCTAssertNoThrow(try mockPersistenceController.container.viewContext.save())
        XCTAssertEqual(viewModel.savedArticles.count, 3)
    }
}

