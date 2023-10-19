//
//  CategoryTabView.swift
//  PulsePod
//
//  Created by Matthew Maloof on 10/11/23.
//

import SwiftUI

struct CategoryTabView: View {
    @Binding var selectedCategory: String

    var categories = ["General", "Tech", "Politics", "Entertainment"]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(categories, id: \.self) { category in
                    Text(category)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        .background(self.selectedCategory == category ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(20)
                        .onTapGesture {
                            self.selectedCategory = category
                        }
                }
            }
            .padding(16)
        }
    }
}
