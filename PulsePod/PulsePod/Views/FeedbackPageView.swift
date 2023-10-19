//
//  FeedbackPageView.swift
//  PulsePod
//
//  Created by Matthew Maloof on 10/11/23.
//

import SwiftUI

struct FeedbackPageView: View {
    @State private var feedbackText: String = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Provide Your Feedback")
                .font(.custom("YourCustomFontName", size: 24))
                .padding(.top, 20)
            
            TextEditor(text: $feedbackText)
                .padding(10)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            
            Button(action: submitFeedback) {
                Text("Submit")
                    .font(.custom("YourCustomFontName", size: 18))
                    .padding(.horizontal, 40)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }

    func submitFeedback() {
        print("Feedback submitted:", feedbackText)
    }
}
