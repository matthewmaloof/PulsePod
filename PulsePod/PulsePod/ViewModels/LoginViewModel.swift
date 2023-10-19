//
//  LoginViewModel.swift
//  PulsePod
//
//  Created by Matthew Maloof on 10/18/23.
//

import Combine
import Foundation
import FirebaseAuth

class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var errorMessage: String?
    @Published var isShowingSignUp: Bool = false
    
    var disposables = Set<AnyCancellable>()
    private let authManager: AuthenticationManager
    
    init(authManager: AuthenticationManager) {
        self.authManager = authManager
    }
    
    func loginUser(email: String, password: String) -> AnyPublisher<Void, Error> {
            return Future<Void, Error> { promise in
                Auth.auth().signIn(withEmail: email, password: password) { result, error in
                    if let error = error {
                        promise(.failure(error))
                    } else {
                        promise(.success(()))
                    }
                }
            }.eraseToAnyPublisher()
        }
    
    func toggleSignUpView() {
        isShowingSignUp.toggle()
    }
}


