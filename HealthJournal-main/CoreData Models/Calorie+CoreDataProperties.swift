//
//  Calorie+CoreDataProperties.swift
//  HealthJournal
//
//  Created by Donald Schaefer on 10/28/21.
//
//
import Foundation
import CoreData

extension Calorie {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Calorie> {
        return NSFetchRequest<Calorie>(entityName: "Calorie")
    }

    @NSManaged public var datetime: Date?
    @NSManaged public var height: Double
    @NSManaged public var weight: Double
    @NSManaged public var age: Double
    @NSManaged public var distanceTraveled: Double
    @NSManaged public var timestamp: Date?
    @NSManaged public var caloriesBurned: Double
    @NSManaged public var id: UUID?
    @NSManaged public var timeSpent: Double
    @NSManaged public var bmr: Double
    @NSManaged public var type: String?
    @NSManaged public var name: String?
    @NSManaged public var sex: String?
    @NSManaged public var averageSpeed: String?
    //public var calories: NSSet?
    
    public var calorieArray: [Calorie] {
        print("000")
        var calories: NSSet?
        let set = calories as? Set<Calorie> ?? []
        return set.sorted {
           $0.name! < $1.name!
        }
    }
    
    public var calorieIds: [String] {
        print("001")
        print(calorieArray.count)
        var newArray = [String]()
        for calorie in calorieArray {
            if let calorieId = calorie.name {
                newArray.append(calorieId)
            } else {
                print("All products should have IDs.")
            }
        }
        return newArray
    }
    
    
    
    
}

extension Calorie : Identifiable {

}

