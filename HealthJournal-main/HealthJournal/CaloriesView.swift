//
//  CalorieView.swift
//  HealthJournal
//
//  Created by Donald Schaefer on 10/28/21.
//

import Foundation
import SwiftUI
import CoreData

struct CaloriesView: View {
    let storageProvider: StorageProvider
    let networkService: NetworkingService
    let calorieDataHandler: CalorieDataHandler
    @State private var filterConfig = FilterConfig()
    @State private var isShowingNewCalorieView = false
    @Environment(\.managedObjectContext) var managedObjectContext
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    SearchBarView(filterConfig: $filterConfig)
                    Button("Sort") {
                        // future work
                    }
                }.padding(.horizontal)
                Divider()
                FilterableCaloriesList(filterConfig: filterConfig, calorieDataHandler: calorieDataHandler)
                    .navigationTitle("Caloric Session")
                    .toolbar(content: {
                        ToolbarItem(placement: .primaryAction) {
                            Button("New Session") {
                                self.isShowingNewCalorieView = true
                            }
                        }
                    })
                Spacer()
                

                NavigationLink(
                    destination: BuildCalorieView(storageProvider: storageProvider, calorieDataHandler: calorieDataHandler),
                    isActive: $isShowingNewCalorieView) { EmptyView() }
            }
        }
    }
}

struct FilterableCaloriesList: View {
    let calorieDataHandler: CalorieDataHandler
    var fetchRequest: FetchRequest<Calorie>
    var filterConfig: FilterConfig
    let boolCalorie: Bool = true
    
    
    // Because filterConfig is a value type, any change to it results in
    // an update to all effected views. This forces a regen of the
    // fetch request every time
    init(filterConfig: FilterConfig, calorieDataHandler: CalorieDataHandler) {
        self.filterConfig = filterConfig
        if filterConfig.searchText != "" {
            let predicate = NSPredicate(format: "name BEGINSWITH %@", filterConfig.searchText)
            fetchRequest = FetchRequest<Calorie>(entity: Calorie.entity(), sortDescriptors: [], predicate: predicate)
        } else {
            fetchRequest = FetchRequest<Calorie>(entity: Calorie.entity(), sortDescriptors: [])
        }
        self.calorieDataHandler = calorieDataHandler
    }
    var body: some View {
        if fetchRequest.wrappedValue.isEmpty {
            Text("Start Exercising.")
  
        } else {
            List {
                ForEach(fetchRequest.wrappedValue, id: \.self) { calorie in
                    NavigationLink(destination: CalorieDetailView(calorie: calorie, boolCalorie: boolCalorie
)) {
                        CalorieRow(calorie: calorie)
                    }
                }
                   
            }.listStyle(PlainListStyle())
            
        }
    }
    
   
    
}


struct CalorieRow: View {
    let calorie: Calorie
    
    var body: some View {
        HStack {
            VStack (alignment: .leading) {
                Text("\(calorie.name!)")
                    .font(.title2)
            }
            Spacer()
            Text("\(calorie.datetime!)")

        }
    }
}


struct CalorieDetailView: View {
    let calorie: Calorie
    let boolCalorie: Bool
    
    var body: some View {
        VStack (alignment: .leading) {
            
            Text("Exercised Time: \(calorie.datetime!)")
                .font(.title3)
            Text("Exercise Session Name: \(calorie.name!)")
                    .font(.title3)
            Text("Exercise Type:  \(calorie.type!)")
                    .font(.title3)
            HStack
            {
            Text("Height:   \(calorie.height)")
                    .font(.title3)
            Text("Weight:   \(calorie.weight)")
                    .font(.title3)
            }
            HStack
            {
            Text("Age:   \(calorie.age)")
                    .font(.title3)
            Text("Sex:   \(calorie.sex!)")
                    .font(.title3)
            }
            Text("Distance Traveled:   \(calorie.distanceTraveled)")
                    .font(.title3)
            Text("Average Speed:   \(calorie.averageSpeed!)")
                .font(.title3)
            Text("BMR:   \(calorie.bmr)")
                    .font(.title3)
            Text("Time Spent:   \(calorie.timeSpent)")
                .font(.title3)
            Text("Calories Burned:   \(calorie.caloriesBurned)")
                    .font(.title3)
            
        }
           

           // .navigationTitle(calorie.name!)
            .navigationTitle("Exercise Session Name: \(calorie.name!)")
            .font(.title3)
            .navigationBarTitleDisplayMode(.inline)

        }
    }





