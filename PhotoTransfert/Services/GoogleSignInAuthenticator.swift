//
//  File.swift
//  PhotoTransfert
//
//  Created by Luigi Aiello on 28/10/22.
//

import Foundation
import GoogleSignIn

/// An observable class for authenticating via Google.
final class GoogleSignInAuthenticator: ObservableObject {
    
    // MARK: - Stored Properties
    
    private var authViewModel: AuthenticationViewModel
    private let signInConfig = GIDConfiguration(clientID: Environments.clientID)
    
    // MARK: - Init
    /// Creates an instance of this authenticator.
    /// - parameter authViewModel: The view model this authenticator will set logged in status on.
    init(authViewModel: AuthenticationViewModel) {
        self.authViewModel = authViewModel
    }
    
    // MARK: - Methods
    /// Signs in the user based upon the selected account.'
    /// - note: Successful calls to this will set the `authViewModel`'s `state` property.
    func signIn() {
#if os(iOS)
        guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else {
            print("There is no root view controller!")
            return
        }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { user, error in
            guard let user = user else {
                print("Error! \(String(describing: error))")
                return
            }
            
            self.authViewModel.state = .signedIn(user)
        }
        
#elseif os(macOS)
        guard let presentingWindow = NSApplication.shared.windows.first else {
            print("There is no presenting window!")
            return
        }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingWindow) { user, error in
            guard let user = user else {
                print("Error! \(String(describing: error))")
                return
            }
            
            self.authViewModel.state = .signedIn(user)
        }
#endif
    }
    
    /// Signs out the current user.
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        authViewModel.state = .signedOut
    }
    
    /// Disconnects the previously granted scope and signs the user out.
    func disconnect() {
        GIDSignIn.sharedInstance.disconnect { error in
            if let error = error {
                print("Encountered error disconnecting scope: \(error).")
            }
            self.signOut()
        }
    }
    
    // Confines birthday calucation to iOS for now.
    /// Adds the birthday read scope for the current user.
    /// - parameter completion: An escaping closure that is called upon successful completion of the
    /// `addScopes(_:presenting:)` request.
    /// - note: Successful requests will update the `authViewModel.state` with a new current user that
    /// has the granted scope.
    func addPhotoReadScope(completion: @escaping () -> Void) {
#if os(iOS)
        guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else {
            fatalError("No root view controller!")
        }
        
        GIDSignIn.sharedInstance.addScopes(PhotoLoader.photoReadScopes, presenting: rootViewController) { user, error in
            if let error = error {
                print("Found error while adding photo read scope: \(error).")
                return
            }
            
            guard let currentUser = user else { return }
            self.authViewModel.state = .signedIn(currentUser)
            completion()
        }
        
#elseif os(macOS)
        guard let presentingWindow = NSApplication.shared.windows.first else {
            fatalError("No presenting window!")
        }
        
        GIDSignIn.sharedInstance.addScopes(PhotoLoader.photoReadScopes, presenting: presentingWindow) { user, error in
            if let error = error {
                print("Found error while adding photo read scope: \(error).")
                return
            }
            
            guard let currentUser = user else { return }
            self.authViewModel.state = .signedIn(currentUser)
            completion()
        }
#endif
    }
}
