//
//  ContentView.swift
//  WordScramble
//
//  Created by Abu Sayeed Roni on 2023-08-08.
//

import SwiftUI

struct ContentView: View {
    
    @State private var rootWord: String = "Rootword"
    @State private var newWord: String = ""
    @State private var usedWords: [String] = []
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("Enter your word", text: $newWord)
                        .textInputAutocapitalization(.never)
                }
                
                Section {
                    ForEach(usedWords, id: \.self) {word in
                        HStack {
                            Image(systemName: "\(word.count).circle.fill")
                            Text(word)
                        }
                    }
                }
            }
            .navigationTitle(rootWord)
            .navigationBarTitleDisplayMode(.inline)
            .onSubmit(addNewWord)
        }
    }
    
    func addNewWord() {
        
        // Get a normalized copy of input word.
        let word = newWord.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        // Clear new word text field for the next word entry.
        newWord.removeAll()
        
        // Validation.
        let isNotAnEmptyWord = word.count > 0
        let isOneWord = word.components(separatedBy: .whitespacesAndNewlines).count == 1
        guard isNotAnEmptyWord && isOneWord else { return }
        
        // Add the word to the used word list.
        withAnimation {
            usedWords.insert(word, at: 0)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
