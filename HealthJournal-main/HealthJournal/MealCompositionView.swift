//
//  MealCompositionView.swift
//  HealthJournal
//
//  Created by Joe Essex on 10/2/21.
//

import SwiftUI

struct MealCompositionView: View {
    @State private var filterConfig = FilterConfig()
    let storageProvider: StorageProvider
    @Binding var constituentProducts: [Product]
    
    var body: some View {
        VStack {
            HStack {
                SearchBarView(filterConfig: $filterConfig)
                Button("Sort") {
                    
                }
            }.padding(.horizontal)
            Divider()
            SelectableProductList(filterConfig: filterConfig, selectedProducts: $constituentProducts)
                .navigationTitle("The Pantry")
        }
    }
}
