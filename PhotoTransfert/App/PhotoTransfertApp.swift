//
//  PhotoTransfertApp.swift
//  PhotoTransfert
//
//  Created by Luigi Aiello on 28/10/22.
//

import SwiftUI
import GoogleSignIn

@main
struct PhotoTransfertApp: App {
    
    // MARK: - Wrapped Properties
    
    @StateObject var authViewModel = AuthenticationViewModel()
    
    // MARK: - Body
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .onAppear {
                    GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                        if let user = user {
                            self.authViewModel.state = .signedIn(user)
                        } else if let error = error {
                            self.authViewModel.state = .signedOut
                            print("There was an error restoring the previous sign-in: \(error)")
                        } else {
                            self.authViewModel.state = .signedOut
                        }
                    }
                }
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}
