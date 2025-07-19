//
//  CoreDataStack.swift
//  AroundEgypt
//
//  Created by Mohamed Shendy on 18/07/2025.
//

import CoreData

class CoreDataStack {
    static let shared = CoreDataStack()

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ExperienceModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data stack init failed: \(error)")
            }
        }
        return container
    }()

    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            try? context.save()
        }
    }
}
