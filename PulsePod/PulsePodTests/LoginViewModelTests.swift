//
//  LoginViewModelTests.swift
//  PulsePodTests
//
//  Created by Matthew Maloof on 10/19/23.
//

import XCTest
import Combine
@testable import PulsePod

class MockAuthenticationManager: AuthenticationManager {
    var signInCalled = false

    func signIn(email: String, password: String) -> AnyPublisher<Void, Error> {
        signInCalled = true
        if email == "test@example.com" && password == "password" {
            return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
        } else {
            let error = NSError(domain: "", code: 1, userInfo: nil)
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
}

class LoginViewModelTests: XCTestCase {
    var viewModel: LoginViewModel!
    var mockAuthManager: MockAuthenticationManager!

    override func setUp() {
        super.setUp()
        mockAuthManager = MockAuthenticationManager()
        viewModel = LoginViewModel(authManager: mockAuthManager)
    }

    override func tearDown() {
        viewModel = nil
        mockAuthManager = nil
        super.tearDown()
    }

    func testLoginUserSuccess() {
        let expectation = XCTestExpectation(description: "Login User Success")

        viewModel.email = "test@example.com"
        viewModel.password = "password"

        viewModel.loginUser(email: viewModel.email, password: viewModel.password)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    XCTAssertTrue(self.mockAuthManager.signInCalled)
                    XCTAssertNil(self.viewModel.errorMessage)
                    expectation.fulfill()
                case .failure:
                    XCTFail("Login should succeed")
                }
            }, receiveValue: { _ in })
            .store(in: &viewModel.disposables)

        wait(for: [expectation], timeout: 2.0)
    }

    func testLoginUserFailure() {
        let expectation = XCTestExpectation(description: "Login User Failure")

        viewModel.email = "wrong@example.com"
        viewModel.password = "wrongpassword"

        viewModel.loginUser(email: viewModel.email, password: viewModel.password)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    XCTFail("Login should fail")
                case .failure(let error):
                    XCTAssertTrue(self.mockAuthManager.signInCalled)
                    XCTAssertEqual(self.viewModel.errorMessage, error.localizedDescription)
                    expectation.fulfill()
                }
            }, receiveValue: { _ in })
            .store(in: &viewModel.disposables)

        wait(for: [expectation], timeout: 2.0)
    }

    func testToggleSignUpView() {
        viewModel.toggleSignUpView()
        XCTAssertTrue(viewModel.isShowingSignUp)
        viewModel.toggleSignUpView()
        XCTAssertFalse(viewModel.isShowingSignUp)
    }
}

