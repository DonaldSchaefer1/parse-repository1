//
//  LoginDataService.swift
//  HealthJournal
//
//  Created by Joe Essex on 10/2/21.
//

import Foundation

enum LoginDataServiceError: Error {
    case invalidCredentials
    case credentialStoreIssue(description: String)
    case noCredentialsFound
}

protocol LoginDataService {
    var networkService: NetworkingService { get }
    func logUserIn(userLogin: UserLogin) throws
    
}

extension LoginDataService {
    func logUserIn(userLogin: UserLogin) throws {
        do {
            let storedCredentials = try retrieveCredentials(username: userLogin.username)
            let inputCredentials = UserLoginModel(username: userLogin.username, pw: userLogin.pw)
            guard confirmCredentialsMatch(firstCredentialSet: inputCredentials, secondCredentialSet: storedCredentials) == true else {
                throw LoginDataServiceError.invalidCredentials
            }
        } catch LoginDataServiceError.noCredentialsFound {
            /// need to build in ability to fetch credentials from server
            throw LoginDataServiceError.noCredentialsFound
        }
    }
    
    func retrieveUserLoginModelFromRemoteCredentialStore(userLogin: UserLogin, dataServiceCompletion: @escaping (Result<UserLoginModel, DataServiceError>) -> Void) {
        /// stub for later development
    }
    
    func retrieveCredentials(username: String) throws -> UserLoginModel {
        let configHandler = ConfigHandler()
        let configObject = configHandler.pullConfigObject()
        let server = configHandler.pullConfigValue(key: "PHS_HOST_ADDRESS", configObject: configObject) as! String
        do {
            let credentials = try KeychainWrapper().retrieveInternetPassword(server: server, username: username)
            return credentials
        } catch KeychainWrapperError.noItemFound {
            //PHLogger().log(errorString: "KeychainWrapperError.noItemFound")
            throw LoginDataServiceError.noCredentialsFound
        } catch KeychainWrapperError.keychainIssue {
            //PHLogger().log(errorString: "KeychainWrapperError.keychainIssue")
            throw LoginDataServiceError.credentialStoreIssue(description: "KEYCHAIN_ISSUE")
        }
    }


    func confirmCredentialsMatch(firstCredentialSet: UserLoginModel, secondCredentialSet: UserLoginModel) -> Bool {
        if firstCredentialSet.username == secondCredentialSet.username && firstCredentialSet.pw == secondCredentialSet.pw {
            return true
        } else {
            return false
        }
    }
}

struct LoginDataHandler: LoginDataService {
    var networkService: NetworkingService
    
    init(networkService: NetworkingService) {
        self.networkService = networkService
    }
}
