//
//  AuthenticationViewModel.swift
//  PhotoTransfert
//
//  Created by Luigi Aiello on 28/10/22.
//


import SwiftUI
import GoogleSignIn

/// A class conforming to `ObservableObject` used to represent a user's authentication status.
final class AuthenticationViewModel: ObservableObject {
    
    // MARK: - Wrapped Properties
    
    /// The user's log in status.
    /// - note: This will publish updates when its value changes.
    @Published var state: State
    
    // MARK: - Computed Properties
    
    private var authenticator: GoogleSignInAuthenticator {
        return GoogleSignInAuthenticator(authViewModel: self)
    }
    /// The user-authorized scopes.
    /// - note: If the user is logged out, then this will default to empty.
    var authorizedScopes: [String] {
        switch state {
        case .signedIn(let user):
            return user.grantedScopes ?? []
        case .signedOut:
            return []
        }
    }
    
    // MARK: - Init
    
    /// Creates an instance of this view model.
    init() {
        if let user = GIDSignIn.sharedInstance.currentUser {
            self.state = .signedIn(user)
        } else {
            self.state = .signedOut
        }
    }
    
    // MARK: - Methods
    
    /// Signs the user in.
    func signIn() {
        authenticator.signIn()
    }
    
    /// Signs the user out.
    func signOut() {
        authenticator.signOut()
    }
    
    /// Disconnects the previously granted scope and logs the user out.
    func disconnect() {
        authenticator.disconnect()
    }
    
    var hasPhotoReadScope: Bool {
        let listSet = Set(authorizedScopes)
        let findListSet = Set(PhotoLoader.photoReadScopes)
        
        return findListSet.isSubset(of: listSet)
    }
    
    /// Adds the requested birthday read scope.
    /// - parameter completion: An escaping closure that is called upon successful completion.
    func addPhotoReadScope(completion: @escaping () -> Void) {
        authenticator.addPhotoReadScope(completion: completion)
    }
}

extension AuthenticationViewModel {
    /// An enumeration representing logged in status.
    enum State {
        /// The user is logged in and is the associated value of this case.
        case signedIn(GIDGoogleUser)
        /// The user is logged out.
        case signedOut
    }
}
