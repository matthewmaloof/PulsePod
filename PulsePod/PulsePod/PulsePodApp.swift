//
//  PulsePodApp.swift
//  PulsePod
//
//  Created by Matthew Maloof on 10/10/23.
//

import SwiftUI
import Firebase
import SwiftUIPager

@main
struct PulsePodApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject var authManager = AuthenticationManager()
    
    init(){
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            if authManager.isLoggedIn {
                MainTabView()
                    .environmentObject(authManager)
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            } else {
                let loginViewModel = LoginViewModel(authManager: authManager)
                LoginView(viewModel: loginViewModel)
                    .environmentObject(authManager)
            }
        }
    }
}


struct MainTabView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        TabView {
            NewsListView(viewModel: NewsViewModel())  // No missing argument error now
                .tabItem {
                    Image(systemName: "newspaper.fill")
                    Text("News")
                }
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.crop.circle.fill")
                    Text("Profile")
                }
            
            FeedbackPageView()
                .tabItem {
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                    Text("Feedback")
                }
            
            DownloadedEpisodeView()
                .tabItem {
                    Image(systemName: "arrow.down.circle.fill")
                    Text("Downloads")
                }
        }
    }
}



func fetchData() -> [NewsArticle] {
    var fetchedArticles: [NewsArticle] = []
    
    let semaphore = DispatchSemaphore(value: 0)  // This will allow synchronous behavior for our asynchronous call
    
    NewsAPI.shared.fetchTopHeadlines { articles in
        if let articles = articles {
            fetchedArticles = articles
            CoreDataService.shared.saveArticles(articles, in: PersistenceController.shared.container.viewContext)
        }
        semaphore.signal()
    }
    
    semaphore.wait()  // This will wait until the above API call and CoreData save operation are completed
    return fetchedArticles
}
