//
//  Meal+CoreDataClass.swift
//  HealthJournal
//
//  Created by Joe Essex on 10/2/21.
//
//

import Foundation
import CoreData

@objc(Meal)
public class Meal: NSManagedObject, Codable {
    
    enum CodingKeys: CodingKey {
        case meal_description, meal_id, meal_datetime, prod_ids, user_id // remove user in production
    }
    
    
    public required convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[.managedObjectContext] as? NSManagedObjectContext else {
            fatalError("object context error with the decoder")
        }
        self.init(context: context)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .meal_description)
        //self.products = try container.decode(Set<Product>.self, forKey: .products) as NSSet
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .meal_id)
        try container.encode(self.name, forKey: .meal_description)
        try container.encode(self.datetime, forKey: .meal_datetime)
        try container.encode(self.productIds, forKey: .prod_ids)
        try container.encode(1, forKey: .user_id) // remove this stub value once authorization/authentication design is complete
    }
}
