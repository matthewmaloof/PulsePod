//
//  AuthenticationManager.swift
//  PulsePod
//
//  Created by Matthew Maloof on 10/11/23.
//

import Foundation
import Firebase


class AuthenticationManager: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var currentUser: User?
    
    private var authListener: AuthStateDidChangeListenerHandle?

    init() {
        authListener = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                self.isLoggedIn = true
                self.currentUser = user
            } else {
                self.isLoggedIn = false
                self.currentUser = nil
            }
        }
    }
    
    func logIn(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (result, error) in
            if let error = error {
                print("Error logging in: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            self?.isLoggedIn = true
            self?.currentUser = result?.user
            completion(.success(()))
        }
    }

    func signUp(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] (result, error) in
            if let error = error {
                completion(.failure(error))
                return
            }

            self?.isLoggedIn = true
            self?.currentUser = result?.user
            completion(.success(()))
        }
    }

    
    // Log Out User
    func logOut() {
        do {
            try Auth.auth().signOut()
            self.isLoggedIn = false
            self.currentUser = nil
        } catch {
            print("Error logging out: \(error.localizedDescription)")
        }
    }
    
    deinit {
        if let listener = authListener {
            Auth.auth().removeStateDidChangeListener(listener)
        }
    }
    
    
}
