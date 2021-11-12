//
//  MealsView.swift
//  HealthJournal
//
//  Created by Joe Essex on 10/2/21.
//

import SwiftUI
import CoreData

struct MealsView: View {
    let storageProvider: StorageProvider
    let networkService: NetworkingService
    let mealDataHandler: MealDataHandler
    @State private var filterConfig = FilterConfig()
    @State private var isShowingNewMealView = false
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
                FilterableMealsList(filterConfig: filterConfig, mealDataHandler: mealDataHandler)
                    .navigationTitle("Meals")
                    .toolbar(content: {
                        ToolbarItem(placement: .primaryAction) {
                            Button("New Meal") {
                                self.isShowingNewMealView = true
                            }
                        }
                    })
                Spacer()
                

                NavigationLink(
                    destination: BuildMealView(storageProvider: storageProvider, mealDataHandler: mealDataHandler),
                    isActive: $isShowingNewMealView) { EmptyView() }
            }
        }
    }
}

struct FilterableMealsList: View {
    
    let mealDataHandler: MealDataHandler
    var fetchRequest: FetchRequest<Meal>
    var filterConfig: FilterConfig
    
    
    // Because filterConfig is a value type, any change to it results in
    // an update to all effected views. This forces a regen of the
    // fetch request every time
    init(filterConfig: FilterConfig, mealDataHandler: MealDataHandler) {
        self.filterConfig = filterConfig
        if filterConfig.searchText != "" {
            let predicate = NSPredicate(format: "name BEGINSWITH %@", filterConfig.searchText)
            fetchRequest = FetchRequest<Meal>(entity: Meal.entity(), sortDescriptors: [], predicate: predicate)
        } else {

            fetchRequest = FetchRequest<Meal>(entity: Meal.entity(), sortDescriptors: [])
        }
        self.mealDataHandler = mealDataHandler
    }
    var body: some View {
        if fetchRequest.wrappedValue.isEmpty {
            Text("Psst, you gotta eat something.")
  
        } else {
            List {
                ForEach(fetchRequest.wrappedValue, id: \.self) { meal in
                    NavigationLink(destination: MealDetailView(meal: meal)) {
                        MealRow(meal: meal)
                        
                    }
                }.onDelete(perform: removeMeal)
                   
            }.listStyle(PlainListStyle())
            
        }
    }
    
    func removeMeal(at offsets: IndexSet) {
        for index in offsets {
            let meal = fetchRequest.wrappedValue[index]
            mealDataHandler.deleteMeal(meal: meal) { result in
                switch result {
                case .success:
                    print("Success!")
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    
}

struct MealRow: View {
    let meal: Meal
    var mealname: String  = ""
    //@ObservedObject var mealname: Namevar
    
    var body: some View
    {
        HStack {
            VStack (alignment: .leading) {
                Text("\(meal.name)")
                    .font(.title2)
            }
            Spacer()
            Text("\(meal.contextualMealTime)")
        }
    }
}

struct MealDetailView: View {
    let meal: Meal
    var _product: [AnyObject] = []
    @State private var selection: String?
    //let mealname = meal.name
  
    @FetchRequest(
            entity: Product.entity(),
            sortDescriptors: [],
            predicate: NSPredicate(format: "name == %@", GlobalVariables.namevarglobal)
        )  public var mealData: FetchedResults<Product>


    var body: some View {
        VStack (alignment: .leading) {
            
            Text("Eaten at: \(meal.contextualMealTime)")
            Text(meal.name)
            Section(header: Text("Ingredients").bold()) {
            //List(meal.productsArray, id: \.self) { product in
            //        ProductRow(product: product)
                List(mealData, id: \.self, selection: $selection ) { product in
                ProductRow1(product: product)
                }
                .onTapGesture {
                    GlobalVariables.namevarglobal = meal.name
                }
                .simultaneousGesture(TapGesture().onEnded {
                    GlobalVariables.namevarglobal = meal.name
                               
                })
            }
            .navigationTitle(meal.name)
            .navigationBarTitleDisplayMode(.inline)
            .onTapGesture {
                GlobalVariables.namevarglobal = meal.name
                print("tap")
            }
            
        }.padding()
    }
    
  
    
   
}




