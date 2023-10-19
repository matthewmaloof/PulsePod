//
//  ViewNotesView.swift
//  PulsePod
//
//  Created by Matthew Maloof on 10/14/23.
import SwiftUI

struct ViewNotesView: View {
    var notes: String
    var onCloseTapped: () -> Void
    
    var body: some View {
        NavigationView {
            ScrollView {
                Text(notes)
                    .font(.body)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .lineLimit(nil)
                    .foregroundColor(.black)
            }
            .navigationBarTitle("Notes", displayMode: .inline)
            .navigationBarItems(trailing: Button(action: onCloseTapped) {
                Text("Done")
            })
        }
    }
}
