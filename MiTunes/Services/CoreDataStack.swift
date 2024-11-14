//
//  CoreDataStack.swift
//  MiTunes
//
//  Created by Neil Francis Ramirez Hipona on 11/14/24.
//

import Foundation
import CoreData

final class CoreDataStack: ObservableObject {
    static let shared = CoreDataStack()

    // Create a persistent container as a lazy variable to defer instantiation until its first use.
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "MiTunes")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    var managedObjectModel: NSManagedObjectModel { 
        persistentContainer.managedObjectModel
    }

    private init() { }
}

// MARK: - Helpers

extension CoreDataStack {
    typealias CallbackHandler = ((Error?) -> Void)

    // Add a convenience method to commit changes to the store.
    func saveContext(callback: CallbackHandler? = nil) {
        // Verify that the context has uncommitted changes.
        guard viewContext.hasChanges else { return }

        do {
            // Attempt to save changes.
            try viewContext.save()
        } catch {
            print("Failed to save the context:", error.localizedDescription)
            callback?(error)
        }
    }

    func delete(
        item: Media,
        callback: CallbackHandler? = nil
    ) {
        viewContext.delete(item)
        saveContext(callback: callback)
    }

    func insert(
        model: NSManagedObject
    ) {
        viewContext.insert(model)
    }
}
