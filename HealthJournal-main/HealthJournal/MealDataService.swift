//
//  MealDataService.swift
//  HealthJournal
//
//  Created by Joe Essex on 10/2/21.
//

import Foundation


protocol MealDataHandler {
    var networkService: NetworkingService { get }
    var storageProvider: StorageProvider { get }
    func saveNewMeal(mealDetails: BuildMealConfig, dataServiceCompletion: @escaping (Result<Bool, DataServiceError>) -> Void)
    func deleteMeal(meal: Meal, dataServiceCompletion: @escaping (Result<Bool, DataServiceError>) -> Void)
}

class MealDataService: MealDataHandler {
    var networkService: NetworkingService
    var storageProvider: StorageProvider
    
    init(networkService: NetworkingService, storageProvider: StorageProvider) {
        self.networkService = networkService
        self.storageProvider = storageProvider
    }
    
    func saveNewMeal(mealDetails: BuildMealConfig, dataServiceCompletion: @escaping (Result<Bool, DataServiceError>) -> Void)  {
        // create an NS managed object
        let meal = Meal(context: storageProvider.persistentContainer.viewContext)
        meal.name = mealDetails.mealName
        meal.datetime = mealDetails.selectedDate
        meal.products = NSSet(array: mealDetails.selectedProducts)
       
        // submit meal
        networkService.send(requestProvider: Endpoint.newMeal, dataset: meal) { [weak self] (result: Result<EntityGenerationResponse, NetworkingServiceError>) in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                // add server generated identifier to meal
                meal.id = String(response.id)
                do {
                    // save object
                    try self.storageProvider.persistentContainer.viewContext.save()
                    dataServiceCompletion(.success(true))
                } catch {
                    dataServiceCompletion(.failure(.localDataStoreError(error.localizedDescription)))
                }
            case .failure(let error):
                // throw appropriate errors
                switch error {
                case .ApplicationError:
                    dataServiceCompletion(.failure(.entityAlreadyExistsInDataStore))
                case .GenericNetworkServiceError:
                    dataServiceCompletion(.failure(.networkingError))
                }
            }
        }
    }
    
    func deleteMeal(meal: Meal, dataServiceCompletion: @escaping (Result<Bool, DataServiceError>) -> Void) {
        guard let id = meal.id else {
            fatalError("This meal does not have a unique id. It should be impossible for a meal to not have an id.")
        }
        do {
            // delete object
            self.storageProvider.persistentContainer.viewContext.delete(meal)
            try self.storageProvider.persistentContainer.viewContext.save()
            dataServiceCompletion(.success(true))
        } catch {
            dataServiceCompletion(.failure(.localDataStoreError(error.localizedDescription)))
        }
        
        networkService.execute(requestProvider: Endpoint.deleteMeal(mealId: id)) { [weak self] (result: Result<EntityDeleteResponse, NetworkingServiceError>) in
            guard let self = self else { return }
            switch result {
            case .success:
                dataServiceCompletion(.success(true))
            case .failure(let error):
                // throw appropriate errors
                switch error {
                case .ApplicationError(let error):
                    print(error)
                    dataServiceCompletion(.failure(.remoteDataStoreError(error)))
                case .GenericNetworkServiceError:
                    dataServiceCompletion(.failure(.networkingError))
                }
            }
        }
    }
    

}

struct EntityDeleteResponse: Codable {
    let status: String
}
