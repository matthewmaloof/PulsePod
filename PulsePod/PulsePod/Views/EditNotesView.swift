//
//  EditNotesView.swift
//  PulsePod
//
//  Created by Matthew Maloof on 10/14/23.
//

import SwiftUI
import CoreData

struct EditNotesView: View {
    var article: SavedArticleEntity
    @Binding var isEditingNotes: Bool
    @Binding var isPresentingSheet: Bool
    @State private var notesText: String
    
    init(article: SavedArticleEntity, isEditingNotes: Binding<Bool>, isPresentingSheet: Binding<Bool>) {
        self.article = article
        self._isEditingNotes = isEditingNotes
        self._isPresentingSheet = isPresentingSheet
        self._notesText = State(initialValue: article.notes ?? "")
    }
    
    var body: some View {
        VStack {
            notesEditor
            saveButton
            cancelButton
        }
        .padding()
        .navigationBarTitle("Edit Notes", displayMode: .inline)
    }
    
    private var notesEditor: some View {
        TextEditor(text: $notesText)
            .frame(minHeight: 200)
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
    }
    
    private var saveButton: some View {
        button(for: "Save Notes", action: saveNotes, color: Color.blue)
    }
    
    private var cancelButton: some View {
        button(for: "Cancel", action: cancelEditingNotes, color: Color.red)
    }
    
    private func button(for text: String, action: @escaping () -> Void, color: Color) -> some View {
        Button(action: action) {
            Text(text)
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(color)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .padding(.top, 10)
    }
    
    private func saveNotes() {
        article.notes = notesText
        
        do {
            try article.managedObjectContext?.save()
        } catch {
            print("Error saving notes: \(error)")
        }
        
        isEditingNotes = false
        isPresentingSheet = false
    }
    
    private func cancelEditingNotes() {
        isEditingNotes = false
        isPresentingSheet = false
    }
}

