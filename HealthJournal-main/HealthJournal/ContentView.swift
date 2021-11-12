//
//  ContentView.swift
//  MealJournal
//
//  Created by Joe Essex on 10/2/21.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("REGISTRATION_STATUS") var registrationStatus = "UNREGISTERED"
    @AppStorage("USER_LOGIN_STATUS") var userLoginStatus = "NOT_LOGGED_IN"
    @AppStorage("LAST_LOGIN") var lastLogin = ""
    @StateObject var contentViewModel = ContentViewModel()
    
    let storageProvider: StorageProvider
    let networkingService: NetworkingService
    
    
    var body: some View {
        if registrationStatus == "REGISTERED" && userLoginStatus == "LOGGED_IN" {
            if contentViewModel.ensureLoginIsStillValid(lastLoginString: lastLogin) {
                HomeView(storageProvider: storageProvider, networkingService: networkingService)
            } else {
                LoginView()
            }
        } else if registrationStatus == "REGISTERED" && userLoginStatus == "NOT_LOGGED_IN" {
            LoginView()
        } else {
            //RegisterView()
            /// removed registerView to avoid the need for an active backend connection to access the app.
            HomeView(storageProvider: storageProvider, networkingService: networkingService)
        }
    }
}

class ContentViewModel: ObservableObject {
    func ensureLoginIsStillValid(lastLoginString: String) -> Bool {
        let lastLoginDatetime = Date.getISO8601DatetimeFromString(datetimeString: lastLoginString)
        let dateInterval = DateInterval(start: lastLoginDatetime, end: Date())
        print("Time since last login: \(dateInterval.duration)")
        let acceptableNumberOfSecs = Double(60*60)
        print("Acceptable # of seconds since last login: \(acceptableNumberOfSecs)")
        if dateInterval.duration > acceptableNumberOfSecs {
            print("Your login has timed out.")
            return false
        } else {
            let timedelta = acceptableNumberOfSecs - dateInterval.duration
            print("You will need to login again in \(timedelta) seconds")
            return true
        }
    }
}
