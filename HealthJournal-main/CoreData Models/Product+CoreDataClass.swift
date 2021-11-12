//
//  Product+CoreDataClass.swift
//  HealthJournal
//
//  Created by Joe Essex on 10/2/21.
//
//

import Foundation
import CoreData


@objc(Product)
public class Product: NSManagedObject, Codable {

    enum CodingKeys: CodingKey {
        case prod_name, prod_brand, upc_code, fdc_id, ingredients, prod_id, image, meals
    }
    
    
    public required convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[.managedObjectContext] as? NSManagedObjectContext else {
            fatalError("object context error with the decoder")
        }
        self.init(context: context)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .prod_name)
        self.brand = try container.decode(String.self, forKey: .prod_brand)
        self.upcCode = try container.decode(String.self, forKey: .upc_code)
        self.fdcId = try container.decode(String.self, forKey: .fdc_id)
        self.ingredients = try container.decode(String.self, forKey: .ingredients)
        self.id = try container.decode(String.self, forKey: .prod_id)
        //self.meals = try container.decode(Set<Meal>.self, forKey: .meals) as NSSet
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .prod_id)
        try container.encode(self.name, forKey: .prod_name)
        try container.encode(self.brand, forKey: .prod_brand)
        try container.encode(self.upcCode, forKey: .upc_code)
        try container.encode(self.fdcId, forKey: .fdc_id)
        try container.encode(self.ingredients, forKey: .ingredients)
        try container.encode(self.meals as! Set<Meal>, forKey: .meals)
       
    }
}
