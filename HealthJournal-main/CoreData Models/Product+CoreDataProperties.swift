//
//  Product+CoreDataProperties.swift
//  HealthJournal
//
//  Created by Joe Essex on 10/2/21.
//
//

import Foundation
import CoreData

extension Product {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Product> {
        return NSFetchRequest<Product>(entityName: "Product")
    }

    @NSManaged public var brand: String
    @NSManaged public var fdcId: String?
    @NSManaged public var id: String?
    @NSManaged public var ingredients: String
    @NSManaged public var name: String
    @NSManaged public var upcCode: String?
    @NSManaged public var meals: NSSet?
    @NSManaged public var imageLocation: String?
    @NSManaged public var imagename: Data?

}

// MARK: Generated accessors for meals
extension Product {

    @objc(addMealsObject:)
    @NSManaged public func addToMeals(_ value: Meal)

    @objc(removeMealsObject:)
    @NSManaged public func removeFromMeals(_ value: Meal)

    @objc(addMeals:)
    @NSManaged public func addToMeals(_ values: NSSet)

    @objc(removeMeals:)
    @NSManaged public func removeFromMeals(_ values: NSSet)

}

extension Product : Identifiable {

}

public extension Product {
    static var sortedFetchRequest: NSFetchRequest<Product> {
      let sortDescriptors = [NSSortDescriptor(keyPath: \Product.ingredients, ascending: true)]
      let request = NSFetchRequest<Product>(entityName: "Product")
      request.sortDescriptors = sortDescriptors
      return request
    }
}
