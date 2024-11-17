//
//  CoreDataStack.swift
//  MiTunes
//
//  Created by Neil Francis Ramirez Hipona on 11/14/24.
//

import Foundation
import CoreData

final class CoreDataStack: ObservableObject {
    static let shared = CoreDataStack(
        persistentContainer: CoreDataStack.stubMiTunes
    )

    private let persistentContainer: NSPersistentContainer

    init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
    }

    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    var managedObjectModel: NSManagedObjectModel { 
        persistentContainer.managedObjectModel
    }
}

extension CoreDataStack {
    static let persistentContainerName = "MiTunes"
    static let stubMiTunes: NSPersistentContainer = {
        let container = NSPersistentContainer(name: persistentContainerName)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                debugLog("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
}

// MARK: - Helpers

extension CoreDataStack {
    typealias CallbackHandler = ((Error?) -> Void)

    // Add a convenience method to commit changes to the store.
    func saveContext(callback: CallbackHandler? = nil) {
        // Verify that the context has uncommitted changes.
        guard viewContext.hasChanges 
        else {
            callback?(nil)
            return
        }

        do {
            // Attempt to save changes.
            try viewContext.save()
            callback?(nil)
        } catch {
            debugLog("Failed to save the context:", error.localizedDescription)
            callback?(error)
        }
    }

    /// Utilize shouldSave if only one item to save
    func insert(
        model: NSManagedObject,
        shouldSave: Bool = false,
        callback: CallbackHandler? = nil
    ) {
        viewContext.insert(model)
        if shouldSave {
            saveContext(callback: callback)
        }
    }

    func delete(
        item: NSManagedObject,
        shouldSave: Bool = false,
        callback: CallbackHandler? = nil
    ) {
        viewContext.delete(item)
        if shouldSave {
            saveContext(callback: callback)
        }
    }
}
