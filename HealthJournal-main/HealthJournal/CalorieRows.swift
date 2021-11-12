//
//  CalorieRows.swift
//  HealthJournal
//
//  Created by Donald Schaefer on 10/30/21.
//

import Foundation
import SwiftUI

struct CalorieRows: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest
    public var calories: FetchedResults<Calorie>
    public var namevar: String = "Ccc"

    init(boolCalorie: Bool) {
        var predicate: NSPredicate? = nil
            predicate = NSPredicate(format: "name == %@", namevar)
        _calories = FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Calorie.name, ascending: true)], predicate: predicate, animation: .default)
    }
    
    var body: some View {
        ForEach(calories) { calorie in
            NavigationLink(destination: DetailView(calorie: calorie)) {
                Label(
                    title: { CalorieCard(calorie:calorie) },
                    icon: { RoundedRectangle(cornerRadius: 10)
                            .fill(.blue)
                            .frame(width: 64, height: 64) }
                )
            }
        }
        .onDelete(perform: deleteItems)
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { calories[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

}
