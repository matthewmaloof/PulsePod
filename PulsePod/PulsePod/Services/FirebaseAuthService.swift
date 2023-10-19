//
//  FirebaseAuthService.swift
//  PulsePod
//
//  Created by Matthew Maloof on 10/11/23.
//

import Foundation
import Firebase

class FirebaseAuthService {
    static let shared = FirebaseAuthService()

    private init() {}

    var isUserAuthenticated: Bool {
        return Auth.auth().currentUser != nil
    }

    func signIn(email: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let error = error {
                completion(false, error)
            } else {
                completion(true, nil)
            }
        }
    }

    func signOut() -> Bool {
        do {
            try Auth.auth().signOut()
            return true
        } catch {
            return false
        }
    }
}
