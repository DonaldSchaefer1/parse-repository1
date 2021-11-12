//
//  UserAccountInfoDataService.swift
//  HealthJournal
//
//  Created by Joe Essex on 10/2/21.
//

import Foundation


protocol UserAccountInfoDataService {
    var networkService: NetworkingService { get }
    func sendUserAccountInfo(userAccount: UserAccount, dataServiceCompletion: @escaping (Result<Bool, DataServiceError>) -> Void)
    func retrieveUserAccountInfo(userId: Int, dataServiceCompletion: @escaping (Result<UserAccount, DataServiceError>) -> Void)
}

extension UserAccountInfoDataService {
    func sendUserAccountInfo(userAccount: UserAccount, dataServiceCompletion: @escaping (Result<Bool, DataServiceError>) -> Void) {
        var userAccountModel = convertToModelType(userAccount)
        networkService.send(requestProvider: Endpoint.register, dataset: userAccountModel) { (result: Result<EntityGenerationResponse, NetworkingServiceError>) in
            switch result {
            case .success(let serviceResponse):
                userAccountModel.userId = serviceResponse.id
                self.storeSensitiveDataInSecureLocalStore(username: userAccountModel.username, password: userAccountModel.pw)
                self.storeUserAccountModelDataInLocalStore(userAccountModel: userAccountModel)
                dataServiceCompletion(.success(true))
            case .failure(let error):
                switch error {
                case .ApplicationError:
                    dataServiceCompletion(.failure(.entityAlreadyExistsInDataStore))
                case .GenericNetworkServiceError:
                    dataServiceCompletion(.failure(.networkingError))
                }
            }
        }
        
    }
    func retrieveUserAccountInfo(userId: Int, dataServiceCompletion: @escaping (Result<UserAccount, DataServiceError>) -> Void) {
        networkService.execute(requestProvider: Endpoint.registration(userId: userId)) { (result: Result<UserAccountModel, NetworkingServiceError>) in
            switch result {
            case .success(let returnedModel):
                let userAccount = convertToUIType(returnedModel)
                dataServiceCompletion(.success(userAccount))
            case .failure(let error):
                switch error {
                case .ApplicationError:
                    dataServiceCompletion(.failure(.remoteDataStoreError(error.localizedDescription)))
                case .GenericNetworkServiceError:
                    dataServiceCompletion(.failure(.networkingError))
                }
            }
            
        }
    }
    
    func convertToModelType(_ userAccount: UserAccount) -> UserAccountModel {
        var model = UserAccountModel()
        model.firstName = userAccount.firstName
        model.lastName = userAccount.lastName
        model.username = userAccount.username
        model.email = userAccount.email
        model.pw = userAccount.pw
        model.sex = userAccount.sex
        model.dateOfBirth = userAccount.dateOfBirth
        return model
    }
    
    func convertToUIType(_ userAccountModel: UserAccountModel) -> UserAccount {
        var model = UserAccount()
        model.firstName = userAccountModel.firstName
        model.lastName = userAccountModel.lastName
        model.username = userAccountModel.username
        model.email = userAccountModel.email
        model.pw = userAccountModel.pw
        model.sex = userAccountModel.sex
        model.dateOfBirth = userAccountModel.dateOfBirth
        return model
    }
    
    func storeSensitiveDataInSecureLocalStore(username: String, password: String) {
        let configHandler = ConfigHandler()
        let configObject = configHandler.pullConfigObject()
        let proposedServer = configHandler.pullConfigValue(key: "PHS_HOST_ADDRESS", configObject: configObject) as! String
        
        do {
            try KeychainWrapper().addInternetPassword(server: proposedServer, username: username, password: password)
        } catch {
            // need to fail more gracefully
            print(error)
        }
    }
    
    func storeUserAccountModelDataInLocalStore(userAccountModel: UserAccountModel) {
        let defaults = UserDefaults.standard
        defaults.setValue("REGISTERED", forKey: "REGISTRATION_STATUS")
        
        var userAccountModel = userAccountModel
        userAccountModel.pw = ""
        DataStoreHandler().storeDataset(dataset: userAccountModel, endpoint: "UserAccount.json", needsEncryption: false)
    }
}


struct UserAccountInfoDataHandler: UserAccountInfoDataService {
    var networkService: NetworkingService
    
    init(networkService: NetworkingService) {
        self.networkService = networkService
    }
}
