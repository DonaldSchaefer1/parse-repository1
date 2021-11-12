//
//  LoginView.swift
//  HealthJournal
//
//  Created by Joe Essex on 10/2/21.
//

import SwiftUI


struct LoginView: View {
    @StateObject var viewModel = LoginViewModel(loginDataService: LoginDataHandler(networkService: BasicNetworkService()))
    
    var body: some View {
        Form {
            VStack {
                TextField("Username", text: $viewModel.userLogin.username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                SecureField("Password", text: $viewModel.userLogin.pw)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            HStack {
                Button("Log in") {
                    viewModel.login()
                }.buttonStyle(BorderlessButtonStyle())
                Spacer()
                Button("Forgot Password") {
                    /// future work
                }.buttonStyle(BorderlessButtonStyle())
            }
            HStack {
                Spacer()
                Button("Create an account") {
                    viewModel.markUserAsNotRegistered()
                }.foregroundColor(.gray)
            }
            //Spacer()
        }.alert(isPresented: $viewModel.alertModel.alertIsPresented, content: {
            Alert(title: Text(viewModel.alertModel.alertType), message: Text(viewModel.alertModel.alertText))
        })
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

class LoginViewModel: ObservableObject {
    @Published var userLogin = UserLogin()
    @Published var alertModel = AlertModel()
    var loginDataService: LoginDataService
    @Published var existingUserFirstUseOnNewPhone = false
    
    init(loginDataService: LoginDataService) {
        self.loginDataService = loginDataService
    }
    
    func login() {
        guard ensureFormIsFilledOut() else { alertModel.alertIsPresented.toggle(); return }
        do {
            try loginDataService.logUserIn(userLogin: userLogin)
            let defaults = UserDefaults.standard
            defaults.setValue("LOGGED_IN", forKey: "USER_LOGIN_STATUS")
            defaults.setValue(Date.getDatetimeStringInISO8601(datetime: Date()), forKey: "LAST_LOGIN")
            
        } catch LoginDataServiceError.invalidCredentials {
            alertModel.alertText = "Your username and/or password are incorrect."
            alertModel.alertIsPresented.toggle()
        } catch LoginDataServiceError.noCredentialsFound {
            alertModel.alertText = "You don't appear to have an account. Please register before attempting to log in."
            alertModel.alertIsPresented.toggle()
        } catch LoginDataServiceError.credentialStoreIssue(let issue) {
            alertModel.alertType = "Error"
            alertModel.alertText = "Unexpected credential store error: \(issue)."
            alertModel.alertIsPresented.toggle()
        } catch {
            alertModel.alertType = "Error"
            alertModel.alertText = "Unexpected error. If it persists, please reach out to the app support team."
            alertModel.alertIsPresented.toggle()
        }
    }
    
    func ensureFormIsFilledOut() -> Bool {
        if userLogin.username == "" && userLogin.pw == "" {
            alertModel.alertText = "You need to provide a username & password."
            return false
        } else if userLogin.username != "" && userLogin.pw == "" {
            alertModel.alertText = "You need to provide a username & password."
            return false
        } else if userLogin.username == "" && userLogin.pw != "" {
            alertModel.alertText = "You need to provide a username & password."
            return false
        } else {
            return true
        }
    }
    
    func markUserAsNotRegistered() {
        let defaults = UserDefaults.standard
        defaults.setValue("UNREGISTERED", forKey: "REGISTRATION_STATUS")
    }
}

struct UserLogin {
    var username = ""
    var pw = ""
}
