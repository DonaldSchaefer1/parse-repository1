//
//  RegisterView.swift
//  HealthJournal
//
//  Created by Joe Essex on 10/2/21.
//

import SwiftUI

struct RegisterView: View {
    @StateObject var viewModel = RegisterViewModel(dataService: UserAccountInfoDataHandler(networkService: BasicNetworkService()))
    
    var body: some View {
        Form {
            VStack {
                Text("Register")
                    .font(.title)
                    .padding()
                TextField("First Name", text: $viewModel.userAccount.firstName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Last Name", text: $viewModel.userAccount.lastName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Email", text: $viewModel.userAccount.email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Sex", text: $viewModel.userAccount.sex)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                DatePicker("Date of birth", selection: $viewModel.userAccount.dateOfBirth, displayedComponents: .date)
                TextField("Username", text: $viewModel.userAccount.username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                SecureField("Password", text: $viewModel.userAccount.pw)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            HStack {
                Button("Register") {
                    viewModel.register()
                }.buttonStyle(BorderlessButtonStyle())
                Spacer()
                Button("Login") {
                    viewModel.markUserAsAlreadyRegistered()
                }.buttonStyle(BorderlessButtonStyle())
                .foregroundColor(.gray)
            }
        }.alert(isPresented: $viewModel.alertModel.alertIsPresented, content: {
            Alert(title: Text(viewModel.alertModel.alertType), message: Text(viewModel.alertModel.alertText))
        })
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}

class RegisterViewModel: ObservableObject {
    @Published var userAccount = UserAccount()
    @Published var alertModel = AlertModel()
    var dataService:  UserAccountInfoDataService
 
    init(dataService: UserAccountInfoDataService) {
        self.dataService = dataService
    }
    
    func register() {
        guard confirmAllFieldsAreFilledIn() else {
            self.alertModel.alertText = "All fields must be filled in."
            self.alertModel.alertIsPresented.toggle()
            return
        }
        dataService.sendUserAccountInfo(userAccount: userAccount) { result in
            switch result {
            case .success:
                self.markUserAsAlreadyRegistered()
            case .failure(let error):
                switch error {
                case .entityAlreadyExistsInDataStore:
                    self.alertModel.alertText = "That username is already in-use. Please try a different one."
                    self.alertModel.alertIsPresented.toggle()
                    return
                case .networkingError:
                    self.alertModel.alertText = "Unexpected networking issue. Please try again."
                    self.alertModel.alertIsPresented.toggle()
                    return
                case .remoteDataStoreError, .localDataStoreError:
                    fatalError("This error should never happen.")
                }
            }
        }
    }
    
    func markUserAsAlreadyRegistered() {
        let defaults = UserDefaults.standard
        defaults.setValue("REGISTERED", forKey: "REGISTRATION_STATUS")
    }
    
    func confirmAllFieldsAreFilledIn() -> Bool {
        if userAccount.firstName == "" || userAccount.lastName == "" ||  userAccount.email == "" || userAccount.username == "" || userAccount.pw == "" {
            return false
        } else {
            return true
        }
    }
}

struct UserAccount {
    var firstName = ""
    var lastName = ""
    var email = ""
    var sex = ""
    var dateOfBirth = Date()
    var username = ""
    var pw = ""
    
    var dobText : String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        let dateString = dateFormatter.string(from: dateOfBirth)
        return dateString
    }
}
