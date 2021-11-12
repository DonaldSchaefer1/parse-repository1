//
//  Meal+CoreDataProperties.swift
//  HealthJournal
//
//  Created by Joe Essex on 10/2/21.
//
//

import Foundation
import CoreData


extension Meal {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Meal> {
        return NSFetchRequest<Meal>(entityName: "Meal")
    }

    @NSManaged public var name: String
    @NSManaged public var datetime: Date
    @NSManaged public var id: String?
    @NSManaged public var products: NSSet?
    
   // public var _product: [Product] {
    //}
    
    public var productsArray: [Product] {
        let set = products as? Set<Product> ?? []
        return set.sorted {
            $0.name < $1.name
        }
    }
    
    public var productIds: [String] {
        var newArray = [String]()
        for product in productsArray {
            if let productId = product.id {
                newArray.append(productId)
            } else {
                print("All products should have IDs.")
            }
        }
        return newArray
    }

    public var contextualMealTime: String {
        let dateFormatter = DateFormatter()
        if self.datetime.isWithin24Hours {
            dateFormatter.dateStyle = .none
            dateFormatter.timeStyle = .short
            return dateFormatter.string(from: self.datetime)
        } else {
            dateFormatter.timeStyle = .none
            dateFormatter.dateStyle = .medium
            return dateFormatter.string(from: self.datetime)
        }
    }
}

// MARK: Generated accessors for products
extension Meal {

    @objc(addProductsObject:)
    @NSManaged public func addToProducts(_ value: Product)

    @objc(removeProductsObject:)
    @NSManaged public func removeFromProducts(_ value: Product)

    @objc(addProducts:)
    @NSManaged public func addToProducts(_ values: NSSet)

    @objc(removeProducts:)
    @NSManaged public func removeFromProducts(_ values: NSSet)

}

extension Meal : Identifiable {

}
