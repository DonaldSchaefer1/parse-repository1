//
//  RegisterTests.swift
//  HealthJournalTests
//
//  Created by Joe Essex on 10/2/21.
//

import Foundation

import XCTest
@testable import HealthJournal
class RegisterTests: XCTestCase {
    var viewModel: RegisterViewModel!
    var dataService: MockUserAccountInfoDataService!

    override func setUp() {
        dataService = MockUserAccountInfoDataService(networkService: BasicNetworkService())
        viewModel = RegisterViewModel(dataService: dataService)
    }
    
    override func tearDown() {
        viewModel.userAccount.username = "TestUsername1"
        
        do {
            try KeychainWrapper().deleteInternetPassword(server: "127.0.0.1", username: viewModel.userAccount.username)
        } catch {
            XCTFail("Test tearDown function failed")
        }
    }
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testConfirmAllFieldsAreFilledInReturnsFalseIfFieldsAreMissing() {
        XCTAssertTrue(viewModel.userAccount.username == "")
        XCTAssertTrue(viewModel.userAccount.pw == "")
        XCTAssertTrue(viewModel.userAccount.firstName == "")
        XCTAssertTrue(viewModel.userAccount.sex == "")
        XCTAssertTrue(viewModel.userAccount.lastName == "")
        XCTAssertTrue(viewModel.userAccount.email == "")
        
        XCTAssertFalse(viewModel.confirmAllFieldsAreFilledIn())
    }
    
    func testValidRegistrationRequestResultsInUpdateToUserDefaults() {
        viewModel.userAccount.username = "TestUsername1"
        viewModel.userAccount.pw = "TestPW1"
        viewModel.userAccount.firstName = "TestFirstName1"
        viewModel.userAccount.lastName = "TestLastName1"
        viewModel.userAccount.email = "TestEmail1"
        viewModel.userAccount.sex = "M"
        
        dataService.sendResult = .success(true)
        viewModel.register()
        let defaults = UserDefaults.standard
        let value = defaults.value(forKey: "REGISTRATION_STATUS") as! String
        XCTAssertEqual(value, "REGISTERED")
    }
    
    func testNetworkingIssueResultsInAlert() {
        viewModel.userAccount.username = "TestUsername1"
        viewModel.userAccount.pw = "TestPW1"
        viewModel.userAccount.firstName = "TestFirstName1"
        viewModel.userAccount.lastName = "TestLastName1"
        viewModel.userAccount.email = "TestEmail1"
        viewModel.userAccount.sex = "M"
        
        dataService.sendResult = .failure(DataServiceError.networkingError)
        viewModel.register()
        XCTAssertEqual(viewModel.alertModel.alertText, "Unexpected networking issue. Please try again.")
        XCTAssertTrue(viewModel.alertModel.alertIsPresented)
    }
    
    func testEntryOfExistingUsernameResultsInAlert() {
        viewModel.userAccount.username = "TestUsername1"
        viewModel.userAccount.pw = "TestPW1"
        viewModel.userAccount.firstName = "TestFirstName1"
        viewModel.userAccount.lastName = "TestLastName1"
        viewModel.userAccount.email = "TestEmail1"
        viewModel.userAccount.sex = "M"
        
        dataService.sendResult = .failure(DataServiceError.entityAlreadyExistsInDataStore)
        viewModel.register()
        XCTAssertEqual(viewModel.alertModel.alertText, "That username is already in-use. Please try a different one.")
        XCTAssertTrue(viewModel.alertModel.alertIsPresented)
    }
}

class RegisterDataServiceTests: XCTestCase {
    var dataService: UserAccountInfoDataService!

    override func tearDown() {
        let username = "TestUsername1"
        let server = "127.0.0.1"
        do {
            try KeychainWrapper().deleteInternetPassword(server: server, username: username)
        } catch {
            XCTFail("Test tearDown function failed")
        }
    }
    
    func testValidRequestReturnsTrue() {
        var userAccount = UserAccount()
        userAccount.username = "TestUsername1"
        userAccount.pw = "TestPW1"
        userAccount.firstName = "TestFirstName1"
        userAccount.lastName = "TestLastName1"
        userAccount.email = "TestEmail1"
        userAccount.sex = "M"
        
        let networkService = MockNetworkService<EntityGenerationResponse>()
        let dataService = UserAccountInfoDataHandler(networkService: networkService)
        networkService.expectedResult = .success(EntityGenerationResponse(id: 1))
        dataService.sendUserAccountInfo(userAccount: userAccount) { result in
            switch result {
            case .success(let value):
                XCTAssertTrue(value)
            case .failure:
                XCTFail("This should not fail")
            }
        }
    }
    
    func testReturnsErrorBecauseOfNetworkIssue() {
        var userAccount = UserAccount()
        userAccount.username = "TestUsername1"
        userAccount.pw = "TestPW1"
        userAccount.firstName = "TestFirstName1"
        userAccount.lastName = "TestLastName1"
        userAccount.email = "TestEmail1"
        userAccount.sex = "M"
        
        let networkService = MockNetworkService<EntityGenerationResponse>()
        let dataService = UserAccountInfoDataHandler(networkService: networkService)
        networkService.expectedResult = .failure(NetworkingServiceError.GenericNetworkServiceError)
        dataService.sendUserAccountInfo(userAccount: userAccount) { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, DataServiceError.networkingError)
            }
        }
    }
    func testReturnsErrorBecauseEntityAlreadyExists() {
        var userAccount = UserAccount()
        userAccount.username = "TestUsername1"
        userAccount.pw = "TestPW1"
        userAccount.firstName = "TestFirstName1"
        userAccount.lastName = "TestLastName1"
        userAccount.email = "TestEmail1"
        userAccount.sex = "M"
        
        let networkService = MockNetworkService<EntityGenerationResponse>()
        let dataService = UserAccountInfoDataHandler(networkService: networkService)
        networkService.expectedResult = .failure(NetworkingServiceError.ApplicationError("USERNAME_NOT_UNIQUE"))
        dataService.sendUserAccountInfo(userAccount: userAccount) { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, DataServiceError.entityAlreadyExistsInDataStore)
            }
        }
    }
    
    func testSensitiveUserDataIsStoredInSecureLocalStore() {
        var userAccountModel = UserAccountModel()
        let networkService = MockNetworkService<EntityGenerationResponse>()
        let dataService = UserAccountInfoDataHandler(networkService: networkService)
        
        userAccountModel.username = "TestUsername1"
        userAccountModel.pw = "TestPW1"
        dataService.storeSensitiveDataInSecureLocalStore(username: userAccountModel.username, password: userAccountModel.pw)
        
        let credentials = try! KeychainWrapper().retrieveInternetPassword(server: "127.0.0.1", username: userAccountModel.username)
        XCTAssertEqual(userAccountModel.username, credentials.username)
        XCTAssertEqual(userAccountModel.pw, credentials.pw)
    }
    
    func testStoreUserDataInLocalStore() {
        var userAccountModel = UserAccountModel()
        let networkService = MockNetworkService<EntityGenerationResponse>()
        let dataService = UserAccountInfoDataHandler(networkService: networkService)
        
        userAccountModel.username = "TestUsername1"
        userAccountModel.pw = "TestPW1"
        userAccountModel.firstName = "TestFirstName1"
        userAccountModel.lastName = "TestLastName1"
        userAccountModel.email = "TestEmail1"
        userAccountModel.userId = 1

        dataService.storeUserAccountModelDataInLocalStore(userAccountModel: userAccountModel)
        
        let defaults = UserDefaults.standard
        let registrationStatus = defaults.value(forKey: "REGISTRATION_STATUS") as! String
        XCTAssertEqual(registrationStatus, "REGISTERED")
        
        let datastoreHandler = DataStoreHandler()
        let retrievedUserAccount: UserAccountModel = datastoreHandler.fetchDataset(datasetEndpoint: "UserAccount.json", needsDecryption: false)
        XCTAssertEqual(userAccountModel.username, retrievedUserAccount.username)
        XCTAssertEqual(userAccountModel.firstName, retrievedUserAccount.firstName)
        XCTAssertEqual(userAccountModel.lastName, retrievedUserAccount.lastName)
        XCTAssertEqual(userAccountModel.email, retrievedUserAccount.email)
        XCTAssertEqual(userAccountModel.userId, retrievedUserAccount.userId)
        XCTAssertEqual(retrievedUserAccount.pw, "")
    }
}
