//
//  Mocks.swift
//  HealthJournalTests
//
//  Created by Joe Essex on 10/2/21.
//

import Foundation
@testable import HealthJournal

class MockUserAccountInfoDataService: UserAccountInfoDataService {
    var networkService: NetworkingService
    var sendResult: Result<Bool, DataServiceError>?
    var retrieveResult: Result<UserAccount, DataServiceError>?

    init(networkService: NetworkingService) {
        self.networkService = networkService
    }
    
   func sendUserAccountInfo(userAccount: UserAccount, dataServiceCompletion: @escaping (Result<Bool, DataServiceError>) -> Void) {
        
        if let result = sendResult {
            dataServiceCompletion(result)
        }
    }
    
    func retrieveUserAccountInfo(userId: Int, dataServiceCompletion: @escaping (Result<UserAccount, DataServiceError>) -> Void) {
        if let result = retrieveResult {
            dataServiceCompletion(result)
        }
    }
}

class MockNetworkService<A: Decodable>: NetworkingService {
    var expectedResult: Result<A,NetworkingServiceError>?

    func send<H:Encodable, T: Decodable>(requestProvider: URLRequestProviding, dataset: H, completion: @escaping (Result<T, NetworkingServiceError>) -> Void) {
        
        let result = expectedResult as! Result<T, NetworkingServiceError>
        completion(result)
        
    }
    func retrieve<T: Decodable>(requestProvider: URLRequestProviding, completion: @escaping (Result<T, NetworkingServiceError>) -> Void) {
        let result = expectedResult as! Result<T, NetworkingServiceError>
        completion(result)
        
    }
}

class MockLoginDataService: LoginDataService {
    var networkService: NetworkingService
    var errorResult:LoginDataServiceError?
    
    init(networkService: NetworkingService) {
        self.networkService = networkService
    }
    
    func logUserIn(userLogin: UserLogin) throws {
        if let error = errorResult {
            throw error.self
        } else {
            return
        }
    }
}
