//
//  Mets+CoreDataProperties.swift
//  HealthJournal
//
//  Created by Donald Schaefer on 11/2/21.
//
//

import Foundation
import CoreData


extension Mets {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Mets> {
        return NSFetchRequest<Mets>(entityName: "Mets")
    }

    @NSManaged public var averagespeed: String?
    @NSManaged public var exercisetype: String?
    @NSManaged public var mets: String?
    @NSManaged public var metsid: Int16

}

extension Mets : Identifiable {

}
