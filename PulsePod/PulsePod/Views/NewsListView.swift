//
//  NewsListView.swift
//  PulsePod
//
//  Created by Matthew Maloof on 10/11/23.
//

import SwiftUI
import AVFoundation
import CoreData

struct NewsListView: View {
    @ObservedObject var viewModel: NewsViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                // Adding the header view at the top
                NewsHeaderView()
                
                ScrollView {
                    ForEach(viewModel.articles, id: \.id) { article in
                        NavigationLink(destination: NewsDetailView(article: article)) {
                            NewsArticleCell(article: article)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal) // Add some horizontal padding
                    }
                }
                .background(Color.clear) // Remove the background color of ScrollView
            }
            .navigationBarHidden(true)  //Hides the default navigation bar
        }
    }
}

struct NewsDetailView: View {
    var article: NewsArticle
    @State private var fullArticleContent: String = ""
    @State private var isFullArticleVisible = false
    @State private var isLoading = false // Add loading state
    @State private var isSpeaking = false // Add speaking state
    @State private var isArticleSaved: Bool = false
    @State private var isEditingNotes = false
    @State private var currentNotes = ""
    var newsService = NewsService()
    let synthesizer = AVSpeechSynthesizer() // Text-to-speech synthesizer
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ZStack(alignment: .topTrailing) {
                    // Article Image
                    if let urlString = article.urlToImage, let url = URL(string: urlString) {
                        RemoteImage(url: url)
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                    
                    Button(action: {
                        if isArticleSaved {
                            PersistenceController.shared.unsaveArticle(id: article.id ?? "")
                            isArticleSaved = false
                        } else {
                            PersistenceController.shared.saveArticle(article)
                            isArticleSaved = true
                        }
                    }) {
                        Image(systemName: isArticleSaved ? "bookmark.fill" : "bookmark")
                            .padding(10)
                            .background(Color.white.opacity(0.7))
                            .clipShape(Circle())
                    }
                    .foregroundColor(.blue)
                    .padding()
                }
                
                // Article Title
                Text(article.title)
                    .font(.system(size: 24, weight: .bold))
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal)
                
                // Article Snippet/Description
                Text(article.description ?? "No description loaded.")
                    .font(.body)
                    .lineSpacing(5)
                    .padding(.horizontal)
                
                if !isFullArticleVisible {
                    Button(action: {
                        fetchFullArticleContent()
                        self.isFullArticleVisible.toggle()
                    }) {
                        HStack {
                            Image(systemName: "doc.text.magnifyingglass")
                            Text("Load Full Article")
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .padding(.top, 10)
                }
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                }
                
                if isFullArticleVisible && !isLoading {
                    // Text-to-speech button
                    Button(action: {
                        toggleSpeaking()
                    }) {
                        Image(systemName: isSpeaking ? "speaker.2.fill" : "speaker.2")
                            .resizable()
                            .foregroundColor(.green)
                            .frame(width: 24, height: 24)
                            .padding(8)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(8)
                    }
                    .padding(.top, 5)
                    .padding(.bottom, 5)
                    
                    // Article content
                    Text(formatArticleText(fullArticleContent))
                        .font(.body)
                        .lineSpacing(5)
                        .padding(.horizontal)
                }
                
                Button(action: {
                    if let url = URL(string: article.url) {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Text("Open Article Source")
                        .underline()
                        .foregroundColor(.blue)
                }
                .padding(.top, 10)
            }
            .onAppear {
                self.isArticleSaved = PersistenceController.shared.isArticleSaved(id: article.id)
            }
            .onDisappear {
                stopSpeaking()
            }
            .background(Color.white)
            .navigationTitle("Details")
        }
    }
    
    private func fetchFullArticleContent() {
            isLoading = true // Show loading indicator
            newsService.fetchFullArticleContent(from: article.url) { (article, error) in
                DispatchQueue.main.async {
                    isLoading = false // Hide loading indicator
                    if let error = error {
                        self.fullArticleContent = "Failed to load content: \(error.localizedDescription)"
                    } else if let article = article {
                        self.fullArticleContent = article.text
                    } else {
                        self.fullArticleContent = "Failed to load content"
                    }
                }
            }
        }

    
    private func toggleSpeaking() {
        if isSpeaking {
            stopSpeaking()
        } else {
            startSpeaking()
        }
    }
    
    private func startSpeaking() {
        let utterance = AVSpeechUtterance(string: fullArticleContent)
        utterance.rate = 0.5
        synthesizer.speak(utterance)
        isSpeaking = true
    }
    
    private func stopSpeaking() {
        synthesizer.stopSpeaking(at: .immediate)
        isSpeaking = false
    }
    
    private func formatArticleText(_ text: String) -> String {
        return text.replacingOccurrences(of: "\n", with: "\n\n")
    }
}

struct ProgressBar: View {
    var progress: CGFloat
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .opacity(0.3)
                    .foregroundColor(Color.gray)
                
                Rectangle()
                    .frame(width: geometry.size.width * progress, height: geometry.size.height)
                    .foregroundColor(Color.blue)
            }
        }
    }
}

extension DateFormatter {
    static let short: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
}

struct NewsHeaderView: View {
    var body: some View {
        ZStack {
            Color.blue.opacity(0.1)  // Light background for a subtle touch of branding
            HStack {
                Text("PulsePod News")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color.blue)
                
                Spacer()
                
                Image(systemName: "bell")  // For notifications
                    .foregroundColor(Color.blue)
                    .font(.title)
            }
            .padding([.leading, .trailing])
        }
        .frame(height: 70)
        .shadow(radius: 5)
    }
}
