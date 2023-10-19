//
//  URLImageView.swift
//  PulsePod
//
//  Created by Matthew Maloof on 10/11/23.
//

import SwiftUI

struct URLImageView: View {
    @State private var imageData: Data?
    @State private var isLoading: Bool = true
    let url: URL
    
    init(url: URL) {
        self.url = url
    }
    
    var body: some View {
        Group {
            if let data = imageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable() // Make the image resizable
            } else if isLoading {
                ProgressView() // Shows a loading indicator
            } else {
                Image(systemName: "photo") // Placeholder if the image fails to load
            }
        }
        .onAppear(perform: fetchImage)
    }
    
    func fetchImage() {
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data {
                DispatchQueue.main.async {
                    self.imageData = data
                    self.isLoading = false
                }
            }
        }
        .resume()
    }
}
