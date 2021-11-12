//
//  LoginTests.swift
//  HealthJournalTests
//
//  Created by Joe Essex on 10/2/21.
//

import XCTest
@testable import HealthJournal
class LoginTests: XCTestCase {
    var viewModel: LoginViewModel!
    var dataService: MockLoginDataService!
    
    override func setUp() {
        dataService = MockLoginDataService(networkService: BasicNetworkService())
        viewModel = LoginViewModel(loginDataService: dataService)
    }
    
    func testEmptyLoginFormReturnsFalse() {
        XCTAssertTrue(viewModel.userLogin.username == "")
        XCTAssertTrue(viewModel.userLogin.pw == "")
        XCTAssertFalse(viewModel.ensureFormIsFilledOut())
    }

    func testEmptyPWFieldReturnsFalse() {
        viewModel.userLogin.username = "testUser"
        XCTAssertTrue(viewModel.userLogin.username != "")
        XCTAssertTrue(viewModel.userLogin.pw == "")
        XCTAssertFalse(viewModel.ensureFormIsFilledOut())
    }

    func testEmptyUsernameFieldReturnsFalse() {
        viewModel.userLogin.pw = "testPW"
        XCTAssertTrue(viewModel.userLogin.username == "")
        XCTAssertTrue(viewModel.userLogin.pw != "")
        XCTAssertFalse(viewModel.ensureFormIsFilledOut())
    }

    func testPopulatedFormReturnsTrue() {
        viewModel.userLogin.pw = "testPW"
        viewModel.userLogin.username = "testUsername"
        XCTAssertTrue(viewModel.userLogin.username != "")
        XCTAssertTrue(viewModel.userLogin.pw != "")
        XCTAssertTrue(viewModel.ensureFormIsFilledOut())
    }
    
    func testValidLoginUpdatesUserDefaults() {
        viewModel.userLogin.pw = "testPW"
        viewModel.userLogin.username = "testUsername"
        XCTAssertTrue(viewModel.userLogin.username != "")
        XCTAssertTrue(viewModel.userLogin.pw != "")
        
        viewModel.login()
        let defaults = UserDefaults.standard
        XCTAssertEqual(defaults.value(forKey: "USER_LOGIN_STATUS") as! String, "LOGGED_IN")
    }
    
    func testInvalidLoginResultsInAlert() {
        viewModel.userLogin.pw = "testPW"
        viewModel.userLogin.username = "testUsername"
        XCTAssertTrue(viewModel.userLogin.username != "")
        XCTAssertTrue(viewModel.userLogin.pw != "")
        dataService.errorResult = LoginDataServiceError.invalidCredentials
        viewModel.login()
        XCTAssertEqual(viewModel.alertModel.alertText, "Your username and/or password are incorrect.")
        XCTAssertTrue(viewModel.alertModel.alertIsPresented)
    }
    
    func testNoAccountFoundResultsInAlert() {
        viewModel.userLogin.pw = "testPW"
        viewModel.userLogin.username = "testUsername"
        XCTAssertTrue(viewModel.userLogin.username != "")
        XCTAssertTrue(viewModel.userLogin.pw != "")
        dataService.errorResult = LoginDataServiceError.noCredentialsFound
        viewModel.login()
        XCTAssertEqual(viewModel.alertModel.alertText, "You don't appear to have an account. Please register before attempting to log in.")
        XCTAssertTrue(viewModel.alertModel.alertIsPresented)
    }
    
    func testCredentialStoreIssueResultsInAlert() {
        viewModel.userLogin.pw = "testPW"
        viewModel.userLogin.username = "testUsername"
        XCTAssertTrue(viewModel.userLogin.username != "")
        XCTAssertTrue(viewModel.userLogin.pw != "")
        dataService.errorResult = LoginDataServiceError.credentialStoreIssue(description: "Some_Unknown_Issue")
        viewModel.login()
        XCTAssertEqual(viewModel.alertModel.alertText, "Unexpected credential store error: Some_Unknown_Issue.")
        XCTAssertTrue(viewModel.alertModel.alertIsPresented)
    }
}


class LoginDataServiceTests: XCTestCase {
    var dataService: LoginDataService!
    
    override func tearDown() {
        do {
            try KeychainWrapper().deleteInternetPassword(server: "127.0.0.1", username: "testUser")
        } catch {
            XCTFail("Test tearDown function failed")
        }
    }
    
    func testValidLoginThrowsNoErrors() {
        let storedCredentials = UserLoginModel(username: "testUser", pw: "testPW")
        try! KeychainWrapper().addInternetPassword(server: "127.0.0.1", username: storedCredentials.username, password: storedCredentials.pw)
        
        self.dataService = LoginDataHandler(networkService: MockNetworkService<UserLoginModel>())
        let userLogin = UserLogin(username: "testUser", pw: "testPW")
        XCTAssertNoThrow(try dataService.logUserIn(userLogin: userLogin))
    }

    func testInvalidCredentialsThrowsError() {
        let storedCredentials = UserLoginModel(username: "testUser", pw: "testPW")
        try! KeychainWrapper().addInternetPassword(server: "127.0.0.1", username: storedCredentials.username, password: storedCredentials.pw)
        
        self.dataService = LoginDataHandler(networkService: MockNetworkService<UserLoginModel>())
        let userLogin = UserLogin(username: "testUser", pw: "testBadPW")
        XCTAssertThrowsError(try dataService.logUserIn(userLogin: userLogin)) { error in
            guard case LoginDataServiceError.invalidCredentials = error else {
                print(error)
                XCTFail("Expected error to be invalidCredentials")
                return
            }
        }
    }
    
    func testNoCredentialsFoundThrowsError() {
        self.dataService = LoginDataHandler(networkService: MockNetworkService<UserLoginModel>())
        let userLogin = UserLogin(username: "testUser", pw: "testPW")
        XCTAssertThrowsError(try dataService.logUserIn(userLogin: userLogin)) { error in
            guard case LoginDataServiceError.noCredentialsFound = error else {
                print(error)
                XCTFail("Expected error to be invalidCredentials")
                return
            }
        }
    }
    
    func testConfirmValidCredentialMatch() {
        self.dataService = LoginDataHandler(networkService: MockNetworkService<UserLoginModel>())
        let firstCredentialsSet = UserLoginModel(username: "testUser", pw: "testPW")
        let secondCredentialsSet = UserLoginModel(username: "testUser", pw: "testPW")
        XCTAssert(dataService.confirmCredentialsMatch(firstCredentialSet: firstCredentialsSet, secondCredentialSet: secondCredentialsSet))
    }

    func testConfirmInvalidCredentialsDoNotMatch() {
        self.dataService = LoginDataHandler(networkService: MockNetworkService<UserLoginModel>())
        let firstCredentialsSet = UserLoginModel(username: "testUser1", pw: "testPW1")
        let secondCredentialsSet = UserLoginModel(username: "testUser2", pw: "testPW2")
        XCTAssertFalse(dataService.confirmCredentialsMatch(firstCredentialSet: firstCredentialsSet, secondCredentialSet: secondCredentialsSet))
    }
}
