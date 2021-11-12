//
//  HomeView.swift
//  MealJournal
//
//  Created by Joe Essex on 10/2/21.
//

import SwiftUI

struct HomeView: View {

    let storageProvider: StorageProvider
    let networkingService: NetworkingService
    
    var body: some View {
        TabView {
            MealsView(storageProvider: storageProvider, networkService: networkingService, mealDataHandler: MealDataService(networkService: networkingService, storageProvider: storageProvider))
                .tabItem { Label("Meals", systemImage: "list.bullet") }
            KitchenView(dataImporter: DataImporter(context: storageProvider.persistentContainer.viewContext))
                .tabItem { Label("Kitchen", systemImage: "k.circle")}
            CaloriesView(storageProvider: storageProvider, networkService: networkingService, calorieDataHandler: CalorieDataService(networkService: networkingService, storageProvider: storageProvider))
                .tabItem { Label("Caloric Intake", systemImage: "list.bullet") }
            Text("Other Features")
                .tabItem { Label("Other", systemImage: "atom") }
        }
    }

}
