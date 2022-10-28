//
//  ContentView.swift
//  PhotoTransfert
//
//  Created by Luigi Aiello on 28/10/22.
//

import SwiftUI
import GoogleSignIn

struct ContentView: View {
    
    // MARK: - Wrapped Properties
    
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    // MARK: - Body
    
    var body: some View {
        return Group {
          NavigationView {
            switch authViewModel.state {
            case .signedIn:
                PhotoListView()
                    .navigationTitle("Photo Transfert")
            case .signedOut:
              SignInView()
                .navigationTitle(
                  NSLocalizedString(
                    "Sign-in with Google",
                    comment: "Sign-in navigation title"
                  ))
            }
          }
          #if os(iOS)
          .navigationViewStyle(StackNavigationViewStyle())
          #endif
        }
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AuthenticationViewModel())
    }
}
