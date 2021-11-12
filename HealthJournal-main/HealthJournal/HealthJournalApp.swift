//
//  HealthJournalApp.swift
//  HealthJournal
//
//  Created by Joe Essex on 10/2/21.
//

import SwiftUI
import CoreData

@main
struct HealthJournalApp: App {
    let storageProvider: StorageProvider
    let networkingService: NetworkingService
    
    init() {
        let provider = StorageProvider()
        self.storageProvider = provider
        let networking = BasicNetworkService()
        self.networkingService = networking
    
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(storageProvider: storageProvider, networkingService: networkingService)
                .environment(\.managedObjectContext, storageProvider.persistentContainer.viewContext)
        }
    }
}

 var persistentContainer: NSPersistentContainer = {
  let container = NSPersistentContainer(name: "HealthJournal")
  container.loadPersistentStores { _, error in
    if let error = error as NSError? {
      // You should add your own error handling code here.
      fatalError("Unresolved error \(error), \(error.userInfo)")
    }
  }
  return container
}()



  
