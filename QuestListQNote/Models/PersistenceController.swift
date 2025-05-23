//
//  PersistenceController.swift
//  QuestListQNote
//
//  Created by Роман Главацкий on 23.05.2025.
//
import Foundation
import CoreData
import UIKit

final class PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init() {
        // Create the container
        container = NSPersistentContainer(name: "QuestList")
        
        // Configure the persistent store
        let description = NSPersistentStoreDescription()
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = true
        
        // Set up SQLite store
        let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent("QuestList.sqlite")
        description.url = storeURL
        
        container.persistentStoreDescriptions = [description]
        
        // Load the persistent store
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        }
        
        // Configure the view context
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        // Enable automatic saving
        NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: .main) { [weak self] _ in
            self?.save()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // Helper function to save the context
    func save() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
    
    // Helper function to create a new background context
    func newBackgroundContext() -> NSManagedObjectContext {
        return container.newBackgroundContext()
    }
}
