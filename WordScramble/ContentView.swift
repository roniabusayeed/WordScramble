//
//  ContentView.swift
//  WordScramble
//
//  Created by Abu Sayeed Roni on 2023-08-08.
//

import SwiftUI

struct ContentView: View {
    
    @State private var rootWord: String = ""
    @State private var newWord: String = ""
    @State private var usedWords: [String] = []
    
    @State private var showingError = false
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    
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
            .onAppear(perform: loadWords)
            
            .alert(errorTitle, isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    func addNewWord() {
        
        // Get a normalized copy of input word.
        let word = newWord.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        // Clear new word text field for the next word entry.
        newWord.removeAll()
        
        // Input validation.
        let isNotAnEmptyWord = word.count > 0
        let isOneWord = word.components(separatedBy: .whitespacesAndNewlines).count == 1
        guard isNotAnEmptyWord && isOneWord else {
            wordError("Invalid input", "Your word must contain at least one non-whitespace character and it shouldn't contain any whitespaces in the middle.")
            return
        }
        
        // Word validation.
        // Is the word original? I.e. hasn't been used already by the user.
        // Is the word possible? I.e. can be constructed using the characters from the root word.
        // Is the word real? I.e. included in the dictionary.
        guard isOriginal(word) else {
            wordError("Word is used already", "Try to be original!")
            return
        }
        guard isPossible(word) else {
            wordError("Word not possible", "You cannot spell that word from '\(rootWord)'!")
            return
        }
        guard isReal(word) else {
            wordError("Word not recognized", "Stop making up words!")
            return
        }
        
        // Add the word to the used word list.
        withAnimation {
            usedWords.insert(word, at: 0)
        }
    }
    
    func wordError(_ title: String, _ message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
    func isOriginal(_ word: String) -> Bool {
        
        // The word is original if it hasn't already beed used by the user.
        return !usedWords.contains(word)
    }
    
    func isPossible(_ word: String) -> Bool {
        
        // The word is possible if it can be constructed using the characters from the root word.
        var rootWordCopy = rootWord
        for character in word {
            guard let index = rootWordCopy.firstIndex(of: character) else {
                return false
            }
            rootWordCopy.remove(at: index)
        }
        return true
    }
    
    func isReal(_ word: String) -> Bool {
        
        // Do spell checking using UIKit's api.
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledWordRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledWordRange.location == NSNotFound
    }
    
    func loadWords() {
        if let wordsFileUrl = Bundle.main.url(forResource: "words", withExtension: "txt") {
            if let wordsFileContent = try? String(contentsOf: wordsFileUrl) {
                let words = wordsFileContent.components(separatedBy: .newlines)
                rootWord = words.randomElement() ?? "haunting"
                return
            }
        }
        
        // Error occurred while loading.
        fatalError("Could not load words.txt from bundle.")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
