//
//  ProfileView.swift
//  PulsePod
//
//  Created by Matthew Maloof on 10/11/23.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var listeningHours = 10.0
    @State private var favoriteCategoryWeight = 0.5

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Listening Stats")
                    .font(.custom("YourCustomFontName", size: 20))
                    .bold()
                Spacer()
            }

            Text("\(Int(listeningHours)) hours")
                .font(.custom("YourCustomFontName", size: 16))

            HStack {
                Text("Favorite Category Weight")
                    .font(.custom("YourCustomFontName", size: 20))
                    .bold()
                Spacer()
            }

            Slider(value: $favoriteCategoryWeight, in: 0...1)

            Spacer()

            // Sign Out Button
            Button(action: {
                authManager.logOut() // Calls the logOut function
            }) {
                Text("Sign Out")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .cornerRadius(8)
            }
            .padding([.leading, .trailing], 20)  // Paddings to ensure it doesn't touch the screen edges
        }
        .padding(16)
    }
}

