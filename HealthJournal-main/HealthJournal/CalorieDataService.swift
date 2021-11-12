//
//  CalorieDataService.swift
//  HealthJournal
//
//  Created by Donald Schaefer on 10/28/21.
//

import Foundation


protocol CalorieDataHandler {
    var networkService: NetworkingService { get }
    var storageProvider: StorageProvider { get }
    func saveNewCalorie(calorieDetails: BuildCalorieConfig, dataServiceCompletion: @escaping (Result<Bool, DataServiceError>) -> Void)
    func deleteCalorie(calorie: Calorie, dataServiceCompletion: @escaping (Result<Bool, DataServiceError>) -> Void)
}

class CalorieDataService: CalorieDataHandler {
    var networkService: NetworkingService
    var storageProvider: StorageProvider
    
    init(networkService: NetworkingService, storageProvider: StorageProvider) {
        self.networkService = networkService
        self.storageProvider = storageProvider
    }
    
    func saveNewCalorie(calorieDetails: BuildCalorieConfig, dataServiceCompletion: @escaping (Result<Bool, DataServiceError>) -> Void)  {
        // create an NS managed object
        let calorie = Calorie(context: storageProvider.persistentContainer.viewContext)
        calorie.name = calorieDetails.calorieName
        calorie.datetime = calorieDetails.selectedDate
       /*
        networkService.send(requestProvider: Endpoint.newCalorie, dataset: calorie) { [weak self] (result: Result<EntityGenerationResponse, NetworkingServiceError>) in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                calorie.id = String(response.id)
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
        */
    }
    
    func deleteCalorie(calorie: Calorie, dataServiceCompletion: @escaping (Result<Bool, DataServiceError>) -> Void) {
        guard let id = calorie.id else {
            fatalError("This does not have a unique id. It should be impossible for a to not have an id.")
        }
        do {
            // delete object
            self.storageProvider.persistentContainer.viewContext.delete(calorie)
            try self.storageProvider.persistentContainer.viewContext.save()
            dataServiceCompletion(.success(true))
        } catch {
            dataServiceCompletion(.failure(.localDataStoreError(error.localizedDescription)))
        }
        
    }
    

}

struct CalorieEntityDeleteResponse: Codable {
    let status: String
}












