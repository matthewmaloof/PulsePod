//
//  NewsArticleCell.swift
//  PulsePod
//
//  Created by Matthew Maloof on 10/11/23.
//

import SwiftUI

struct RemoteImage: View {
    let url: URL?
    
    init(url: URL?) {
        self.url = url
    }
    
    @State private var image: Image? = nil
    
    var body: some View {
        Group {
            if let image = image {
                image
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
                    .background(Color.black) // Add a black background
            } else {
                Color.gray
            }
        }
        .onAppear(perform: loadImage)
    }
    
    private func loadImage() {
        guard let url = url else { return }
        
        DispatchQueue.global(qos: .userInitiated).async {  // Moved to background thread
            URLSession.shared.dataTask(with: url) { data, _, error in
                if let data = data, let uiImage = UIImage(data: data) {
                    let image = Image(uiImage: uiImage)
                    DispatchQueue.main.async {  // Switch back to main thread for UI update
                        self.image = image
                    }
                }
            }.resume()
        }
    }
}

struct NewsArticleCell: View {
    @State private var isNewsViewPresented = false
    @State private var isArticleSaved: Bool = false
    @State private var isEditingNotes = false
    @State private var currentNotes: String = "" // Add @State for notes
    
    let article: NewsArticle
    
    var body: some View {
        Button(action: {
            isNewsViewPresented = true
        }) {
            ZStack {
                VStack(alignment: .leading, spacing: 8) {
                    // Load the image from URL using RemoteImage
                    RemoteImage(url: URL(string: article.urlToImage ?? ""))
                        .frame(maxWidth: .infinity, maxHeight: 200)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.clear, lineWidth: 2)
                        )
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(article.title)
                            .font(.headline)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                            .lineLimit(3)
                        
                        Text(article.description ?? "No description loaded.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                            .lineLimit(4)
                    }
                    .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
                }
                
                // Save icon
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            if isArticleSaved {
                                PersistenceController.shared.unsaveArticle(id: article.id ?? "")
                            } else {
                                PersistenceController.shared.saveArticle(article)
                            }
                            isArticleSaved.toggle()
                        }) {
                            Image(systemName: isArticleSaved ? "bookmark.fill" : "bookmark")
                                .padding()
                                .background(Color.white.opacity(0.7))
                                .clipShape(Circle())
                        }
                    }
                    Spacer()
                }
            }
        }
        .buttonStyle(PlainButtonStyle()) // Remove button styling
        .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
        .frame(maxWidth: .infinity)
        .onAppear {
            isArticleSaved = PersistenceController.shared.isArticleSaved(id: article.id ?? "")
        }
        .sheet(isPresented: $isNewsViewPresented) {
            NewsDetailView(article: article)
        }
    }
}
