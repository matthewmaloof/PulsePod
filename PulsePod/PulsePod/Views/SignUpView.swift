//
//  SignUpView.swift
//  PulsePod
//
//  Created by Matthew Maloof on 10/11/23.
//

import SwiftUI
import FirebaseAuth

struct SignUpView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var errorMessage: String?
    @State private var isSignUpSuccessful = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Sign Up to PulsePod")
                .font(.largeTitle)
                .bold()
                .padding(.top, 40)
            
            TextField("Email", text: $email)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .padding(.horizontal)
            
            //TODO: CHANGE FROM UNSECURE ONETIMECODE IN FUTURE
            SecureField("Password", text: $password)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .padding(.horizontal)
                .textContentType(.oneTimeCode)

            //TODO: CHANGE FROM UNSECURE ONETIMECODE IN FUTURE
            SecureField("Confirm Password", text: $confirmPassword)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .padding(.horizontal)
                .textContentType(.oneTimeCode)

            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
            
            Button(action: signUpUser) {
                Text("Sign Up")
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
        }
        .padding(.bottom, 50)
        .fullScreenCover(isPresented: $isSignUpSuccessful) {
            MainTabView()
        }
    }

    func signUpUser() {
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            return
        }

        authManager.signUp(email: email, password: password) { result in
            switch result {
            case .success:
                isSignUpSuccessful = true
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }
}

