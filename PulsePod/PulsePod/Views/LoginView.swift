import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: LoginViewModel

    var body: some View {
        VStack(spacing: 20) {
            header
            emailField
            passwordField
            errorText
            loginButton
            forgotPasswordButton
            signUpButton
            Spacer()
        }
        .padding()
        .background(backgroundGradient.edgesIgnoringSafeArea(.all))
        .sheet(isPresented: $viewModel.isShowingSignUp) {
            SignUpView() // Assuming you have a SignUpView
        }
    }
    
    // MARK: - Subviews
    private var header: some View {
        Text("PulsePod")
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundColor(Color.blue)
    }
    
    private var emailField: some View {
        TextField("Email", text: $viewModel.email)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .autocapitalization(.none)
            .keyboardType(.emailAddress)
    }
    
    private var passwordField: some View {
        SecureField("Password", text: $viewModel.password)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
    }
    
    private var errorText: some View {
        Group {
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.callout)
            } else {
                Text("").hidden()
            }
        }
    }
    
    private var loginButton: some View {
        Button(action: {
            //_ = to suppress warning.
            _ = viewModel.loginUser(email: viewModel.email, password: viewModel.password)
        }) {
            Text("Login")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
    }

    
    private var forgotPasswordButton: some View {
        Button(action: {}) { // Placeholder action for forgot password
            Text("Forgot Password?")
                .font(.callout)
                .foregroundColor(.blue)
        }
    }
    
    private var signUpButton: some View {
        HStack {
            Text("Don't have an account?")
            Button(action: viewModel.toggleSignUpView) {
                Text("Sign Up")
                    .font(.callout)
                    .foregroundColor(.blue)
            }
        }
    }
    
    private var backgroundGradient: LinearGradient {
        LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.blue.opacity(0.6)]), startPoint: .top, endPoint: .bottom)
    }
}
