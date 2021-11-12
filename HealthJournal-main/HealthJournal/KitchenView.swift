//
//  KitchenView.swift
//  MealJournal
//
//  Created by Joe Essex on 10/2/21.
//

import SwiftUI
import CoreData

struct KitchenView: View {
    @Environment(\.managedObjectContext) var context: NSManagedObjectContext
    let dataImporter: DataImporter
    @FetchRequest(fetchRequest: Product.sortedFetchRequest)
    var products: FetchedResults<Product>
    @State private var filterConfig = FilterConfig()
    
    var body: some View {
        VStack {
            Text("Hello, this is the kitchen!")
            Button("Populate the pantry") {
                let data = DataImporter.sampleData
                dataImporter.importData(data, as: [Product].self)
            }
            SearchBarView(filterConfig: $filterConfig)
            FilteredList(filterConfig: filterConfig)
        }
    }
}

struct FilteredList: View {
    var fetchRequest: FetchRequest<Product>
    let filterConfig: FilterConfig
    
    init(filterConfig: FilterConfig) {
        self.filterConfig = filterConfig
        if filterConfig.searchText != "" {
            let predicate = NSPredicate(format: "name BEGINSWITH %@", filterConfig.searchText)
            fetchRequest = FetchRequest<Product>(entity: Product.entity(), sortDescriptors: [], predicate: predicate)
        } else {
            fetchRequest = FetchRequest<Product>(entity: Product.entity(), sortDescriptors: [])
        }
    }
    
    var body: some View {
        List(fetchRequest.wrappedValue, id: \.self) { product in
            Text("\(product.ingredients)")
        }
    }
}
