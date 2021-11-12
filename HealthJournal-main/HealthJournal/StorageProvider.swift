//
//  StorageProvider.swift
//  HealthJournal
//
//  Created by Joe Essex on 10/2/21.
//

import Foundation
import CoreData

public class PersistentContainer: NSPersistentContainer {}

public class StorageProvider {
  public let persistentContainer: PersistentContainer

  public init() {
    persistentContainer = PersistentContainer(name: "HealthJournal")

    persistentContainer.loadPersistentStores(completionHandler: { description, error in

      if let error = error {
        fatalError("Core Data store failed to load with error: \(error)")
      }
    })

    persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
    persistentContainer.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
  }
}
