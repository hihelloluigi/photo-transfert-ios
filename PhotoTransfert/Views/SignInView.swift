//
//  SignInView.swift
//  PhotoTransfert
//
//  Created by Luigi Aiello on 28/10/22.
//

import SwiftUI
import GoogleSignInSwift

struct SignInView: View {
    
    // MARK: - Wrapped Properties
    
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @ObservedObject var viewModel = GoogleSignInButtonViewModel()
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    GoogleSignInButton(viewModel: viewModel, action: authViewModel.signIn)
                        .accessibilityIdentifier("GoogleSignInButton")
                        .accessibility(hint: Text("Sign in with Google button."))
                        .padding()
                    VStack {
                        HStack {
                            Text("Button style:")
                                .padding(.leading)
                            Picker("", selection: $viewModel.style) {
                                ForEach(GoogleSignInButtonStyle.allCases) { style in
                                    Text(style.rawValue.capitalized)
                                        .tag(GoogleSignInButtonStyle(rawValue: style.rawValue)!)
                                }
                            }
                            Spacer()
                        }
                        HStack {
                            Text("Button color:")
                                .padding(.leading)
                            Picker("", selection: $viewModel.scheme) {
                                ForEach(GoogleSignInButtonColorScheme.allCases) { scheme in
                                    Text(scheme.rawValue.capitalized)
                                        .tag(GoogleSignInButtonColorScheme(rawValue: scheme.rawValue)!)
                                }
                            }
                            Spacer()
                        }
                        HStack {
                            Text("Button state:")
                                .padding(.leading)
                            Picker("", selection: $viewModel.state) {
                                ForEach(GoogleSignInButtonState.allCases) { state in
                                    Text(state.rawValue.capitalized)
                                        .tag(GoogleSignInButtonState(rawValue: state.rawValue)!)
                                }
                            }
                            Spacer()
                        }
                    }
                    .pickerStyle(.segmented)
                }
            } //: HSTACK
            Spacer()
        } //: VSTACK
    }
}

// MARK: - Preview

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
            .environmentObject(AuthenticationViewModel())
    }
}
