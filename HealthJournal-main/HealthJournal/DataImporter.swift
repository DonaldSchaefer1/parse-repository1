//
//  DataImporter.swift
//  MealJournal
//
//  Created by Joe Essex on 10/2/21.
//

import Foundation
import CoreData

extension CodingUserInfoKey {
    static let managedObjectContext = CodingUserInfoKey(rawValue: "managedObjectContext")!
}

public class DataImporter {
    private let context: NSManagedObjectContext
    public static var sampleData: Data {
      let url = Bundle(for: Self.self).url(forResource: "InitialProductData", withExtension: "json")

      return try! Data(contentsOf: url!)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    private func _importData<T: Decodable>(_ data: Data, as model: T.Type) {
        context.perform { [unowned self] in
            let decoder = JSONDecoder()
            decoder.userInfo[.managedObjectContext] = self.context
            //decoder.userInfo[.managedObjectContext!] = self.context
            //decoder.userInfo[CodingUserInfoKey.managedObjectContext] = self.context
            
            do {
                let objects = try decoder.decode(model, from: data)
                    //print(objects)
                //_ = try decoder.decode(model, from: data)
                try self.context.save()
            } catch {
                if self.context.hasChanges {
                    self.context.rollback()
                }
                print(error)
                print("Importing failed.")
            }
        }
    }
    
    public func importData<T: Collection & Decodable>(_ data: Data, as model: T.Type) where T.Element: NSManagedObject {
        self._importData(data, as: model)
    }
    
    public func importData<T: NSManagedObject & Decodable>(_ data: Data, as model: T.Type) {
      self._importData(data, as: model)
    }
}
