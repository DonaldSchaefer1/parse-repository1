//
//  CoreDataManager.swift
//

import CoreData

final class CoreDataManager {

    private let modelName: String
    init(modelName: String) {
        self.modelName = modelName
    }

    private(set) lazy var managedObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)

        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator

        return managedObjectContext
    }()


        private lazy var managedObjectModel: NSManagedObjectModel =
        {
        guard let modelURL = Bundle.main.url(forResource: "HealthJournal", withExtension: "momd") else {
            fatalError("Unable to Find Data Model")
        }
            
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Unable to Load Data Model")
        }
        
        return managedObjectModel
    }()
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.cocoacasts.PersistentStores" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .applicationDirectory, in: .userDomainMask)
        return urls[urls.count-1] as NSURL
    }()
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        var path1: String
        
        let fileManager = FileManager.default
        let storeName = "HealthJournal.sqlite"
        let documentsDirectoryURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        
        let persistentStoreURL = documentsDirectoryURL.appendingPathComponent(storeName)

        do {
            try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                                              configurationName: nil,
                                                              at: persistentStoreURL,
                                                              options: nil)
        } catch {
            fatalError("Unable to Load Persistent Store")
        }
        
        return persistentStoreCoordinator
    }()

}
