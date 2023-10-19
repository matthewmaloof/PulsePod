import SwiftUI
import CoreData

struct DownloadedEpisodeView: View {
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \SavedArticleEntity.pinned, ascending: false),
            NSSortDescriptor(keyPath: \SavedArticleEntity.publishedAt, ascending: false)
        ],
        animation: .default
    )
    private var savedArticles: FetchedResults<SavedArticleEntity>
    @ObservedObject var viewModel = SavedArticleViewModel()

    
    @State private var inEditMode: Bool = false
    @State private var selectedArticleForNotes: SavedArticleEntity?
    @State private var selectedArticleForViewing: SavedArticleEntity?
    @State private var isPresentingEditNotesSheet = false
    @State private var isPresentingViewNotesSheet = false
    @State private var isEditingNotes = false

    var body: some View {
            NavigationView {
                VStack {
                    contentBody
                }
                .navigationBarTitle("Saved Articles", displayMode: .large)
                .navigationBarItems(leading: viewModel.inEditMode ? unsaveAllButton : nil, trailing: editToggleButton)
                .sheet(isPresented: $isPresentingEditNotesSheet) {
                    EditNotesView(
                        article: selectedArticleForNotes ?? SavedArticleEntity(context: PersistenceController.shared.container.viewContext),
                        isEditingNotes: $isEditingNotes,
                        isPresentingSheet: $isPresentingEditNotesSheet
                    )
                }
                .sheet(isPresented: $isPresentingViewNotesSheet) {
                    ViewNotesView(notes: selectedArticleForViewing?.notes ?? "", onCloseTapped: {
                        isPresentingViewNotesSheet = false
                    })
                }
            }
        }
        
    private var contentBody: some View {
            Group {
                if viewModel.savedArticles.isEmpty {
                    emptyStateView
                } else {
                    ScrollView {
                        ForEach(viewModel.savedArticles, id: \.id) { savedArticle in
                            ZStack {
                                NavigationLink(destination: NewsDetailView(article: convertToNewsArticle(savedArticle))) {
                                    articleCell(for: savedArticle)
                                }
                                
                                if viewModel.inEditMode {
                                    editModeButtons(for: savedArticle)
                                }
                            }
                        }
                    }
                }
            }
        }
        
        private var emptyStateView: some View {
            Text("There are no current saved articles.")
                .font(.headline)
                .padding()
                .multilineTextAlignment(.center)
        }
    
    private func articleCell(for savedArticle: SavedArticleEntity) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            if let urlString = savedArticle.urlToImage, let url = URL(string: urlString) {
                RemoteImage(url: url)
                    .scaledToFit()
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
            
            Text(savedArticle.title ?? "")
                .font(.headline)
            
            Text(savedArticle.desc ?? "")
                .font(.body)
                .foregroundColor(.gray)
            
            HStack {
                Button(action: { viewNotes(for: savedArticle) }) {
                    noteActionButton(imageName: "note.text", text: "View Notes", color: .blue)
                }
                Spacer()
                Button(action: { editOrCreateNote(for: savedArticle) }) {
                    noteActionButton(imageName: "pencil.circle", text: "Edit Note", color: .green)
                }
            }
        }
    }
    
    private func noteActionButton(imageName: String, text: String, color: Color) -> some View {
        HStack {
            Image(systemName: imageName)
                .font(.headline)
            Text(text)
                .font(.subheadline)
        }
        .foregroundColor(color)
    }
    
    private func editModeButtons(for savedArticle: SavedArticleEntity) -> some View {
            HStack {
                Button(action: { viewModel.togglePinStatus(for: savedArticle) }) {
                    editModeButton(imageName: savedArticle.pinned ? "pin.fill" : "pin", color: .blue)
                }
                
                Spacer()
                
                if !savedArticle.pinned {
                    Button(action: { viewModel.deleteArticle(savedArticle) }) {
                        editModeButton(imageName: "trash", color: .red)
                    }
                }
            }
            .offset(y: -80)
        }
    
    private func editModeButton(imageName: String, color: Color) -> some View {
        Image(systemName: imageName)
            .padding()
            .background(color.opacity(0.7))
            .clipShape(Circle())
            .foregroundColor(.white)
    }
    
    private var unsaveAllButton: some View {
        Button(action: unsaveAllArticles) {
            Text("Unsave All")
                .font(.caption)
                .padding(8)
                .background(Color.red)
                .cornerRadius(8)
                .foregroundColor(.white)
        }
    }
    
    private var editToggleButton: some View {
        Button(action: { inEditMode.toggle() }) {
            Text(inEditMode ? "Done" : "Edit")
                .font(.headline)
                .padding(8)
                .background(Color.blue)
                .cornerRadius(8)
                .foregroundColor(.white)
        }
    }
    
    // Core Data operations offloaded to a background queue
    private func togglePinStatus(for article: SavedArticleEntity) {
        DispatchQueue.global(qos: .userInitiated).async {
            let context = PersistenceController.shared.container.newBackgroundContext()
            context.performAndWait {
                let articleID = article.objectID
                if let fetchedArticle = try? context.existingObject(with: articleID) as? SavedArticleEntity {
                    fetchedArticle.pinned.toggle()
                    try? context.save()
                }
            }
            DispatchQueue.main.async {
                withAnimation {
                    try? PersistenceController.shared.container.viewContext.save()
                }
            }
        }
    }
    
    private func unsaveAllArticles() {
        for article in savedArticles {
            if !article.pinned {
                PersistenceController.shared.container.viewContext.delete(article)
            }
        }
        try? PersistenceController.shared.container.viewContext.save()
    }

    
    private func convertToNewsArticle(_ savedArticle: SavedArticleEntity) -> NewsArticle {
        return NewsArticle(id: savedArticle.id ?? "",
                           title: savedArticle.title ?? "",
                           description: savedArticle.desc ?? "",
                           content: savedArticle.content,
                           author: savedArticle.author,
                           url: savedArticle.url ?? "",
                           urlToImage: savedArticle.urlToImage,
                           source: NewsArticle.Source(id: nil, name: savedArticle.sourceName ?? ""))
    }
    
    private func deleteSavedArticle(_ article: SavedArticleEntity) {
        PersistenceController.shared.container.viewContext.delete(article)
        try? PersistenceController.shared.container.viewContext.save()
    }
    
    private func editOrCreateNote(for article: SavedArticleEntity) {
        // Set the article for which notes will be edited
        selectedArticleForNotes = article
        
        // Present the edit notes sheet
        isPresentingEditNotesSheet = true
    }
    
    private func viewNotes(for article: SavedArticleEntity) {
        // Set the article for which notes will be viewed
        selectedArticleForViewing = article
        
        // Present the view notes sheet
        isPresentingViewNotesSheet = true
    }
}
