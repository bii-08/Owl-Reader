//
//  DefinitionView.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/04/23.
//

import SwiftUI
import AVFoundation
import SwiftData

struct DefinitionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var rewardManager = RewardAdsManager()
    @StateObject var vm: DefinitionVM
    @EnvironmentObject var wordBookVM: WordBookVM
    @State var title = ""
    @State private var thisWordIsEmpty = false
    var initialWordBook: String
    
    let synthesizer = AVSpeechSynthesizer()
    
    init(vm: DefinitionVM, initialWordBook: String = "Default") {
        _vm = StateObject(wrappedValue: vm)
        self.initialWordBook = initialWordBook
    }
    var body: some View {
        
        ZStack {
            Color(.cyan.opacity(0.2)).ignoresSafeArea()
            
            switch vm.loadingState {
            case .loading:
                ProgressView("Loading...")
            case .success:
                VStack(alignment: .leading) {
                    
                    // MARK: Selected Word and Button
                    HStack {
                        // MARK: Selected word
                        Text(vm.selectedWord.lemmatize())
                            .font(.custom("Helvetica", size: 25))
                            .textCase(.lowercase)
                            .bold()
                            .padding(.vertical, 15)
                        
                        Spacer()
                        
                        // MARK: Star button
                        Button {
                            if let word = vm.word {
                                wordBookVM.didTapOnStar(word: word, wordBookName: wordBookVM.selectedWordbook, modelContext: modelContext)
                            }
                        } label: {
                            if let word = vm.word {
                                Image(systemName: "star.fill")
                                    .scaleEffect(1.25)
                                    .foregroundColor(wordBookVM.isThisWordAlreadySaved(selectedWord: word, wordBookName: wordBookVM.selectedWordbook) ? .orange : .gray)
                            }
                        }
                        .disabled(wordBookVM.noMoreReference || thisWordIsEmpty)
                    }
                    .padding(.horizontal)
                    
                    // MARK: Pronunciation
                    VStack(alignment: .leading) {
                        // Phonetic
                        HStack {
                            if let word = vm.word {
                                if let pronunciation = word.pronunciation {
                                    Text("[\(pronunciation.all)]")
                                        .font(.custom("Helvetica", size: 19))
                                        .foregroundColor(.secondary)
                                }
                            }
                            Spacer()
                            
                            // British accent
                            HStack(spacing: 2) {
                                Text("UK")
                                    .font(.custom("Helvetica", size: 15))
                                    .foregroundColor(.secondary)
                                Button {
                                    if let word = vm.word {
                                        let utterance = AVSpeechUtterance(string: word.word)
                                        utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
                                        utterance.rate = 0.3
                                        synthesizer.speak(utterance)
                                    }
                                } label: {
                                    Image(systemName: "speaker.wave.3")
                                        .foregroundColor(.cyan)
                                }
                            }
                            
                            // American accent
                            HStack(spacing: 2) {
                                Text("US")
                                    .font(.custom("Helvetica", size: 15))
                                    .foregroundColor(.secondary)
                                Button {
                                    if let word = vm.word {
                                        let utterance = AVSpeechUtterance(string: word.word)
                                        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                                        utterance.rate = 0.3
                                        synthesizer.speak(utterance)
                                    }
                                } label: {
                                    Image(systemName: "speaker.wave.3")
                                        .foregroundColor(.cyan)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // MARK: All Definitions
                    ScrollView {
                        if let word = vm.word {
                            if let results = word.results, !results.isEmpty {
                                ForEach(results, id: \.self) { result in
                                    //                                    HStack {
                                    VStack {
                                        // Word function
                                        HStack {
                                            if let partOfSpeech = result.partOfSpeech {
                                                Text("\(vm.capitalizeFirstLetter(of: partOfSpeech))")
                                                    .font(.custom("Helvetica", size: 19))
                                                    .foregroundColor(.orange)
                                            }
                                            
                                            Spacer()
                                        }
                                        .padding(.vertical, 5)
                                        
                                        // Definitions
                                        HStack {
                                            if let definition = result.definition {
                                                Text("\(vm.capitalizeFirstLetter(of: definition))")
                                                    .font(.custom("Helvetica", size: 19))
                                                    .bold()
                                            }
                                            
                                            Spacer()
                                        }
                                        .padding(.vertical, 5)
                                        
                                        // Examples
                                        if let examples = result.examples {
                                            ForEach(examples, id: \.self) { example in
                                                HStack {
                                                    Text("\(vm.capitalizeFirstLetter(of: example)).")
                                                        .font(.custom("Helvetica", size: 19))
                                                        .foregroundColor(.primary)
                                                        .italic()
                                                        .padding()
                                                    Spacer()
                                                }
                                            }
                                        }
                                        
                                        // Synonyms
                                        if result.synonyms != nil {
                                            HStack {
                                                Text("Synonyms:")
                                                    .font(.custom("Helvetica", size: 19))
                                                    .underline()
                                                Spacer()
                                            }
                                        }
                                        
                                        if let synonyms = result.synonyms {
                                            ForEach(synonyms, id: \.self) { syn in
                                                HStack {
                                                    Text(syn)
                                                        .font(.custom("Helvetica", size: 18))
                                                        .foregroundColor(.secondary)
                                                    Spacer()
                                                }
                                            }
                                        }
                                        
                                        Spacer()
                                    }
                                    .padding(.horizontal, 15)
                                    .background(.regularMaterial)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .padding(.horizontal)
                                    .padding(.vertical, 5)
                                }
                            } else {
                               
                                HStack {
                                    Spacer()
                                    Text("Sorry. Could not find this word.😔")
                                        .font(Font.custom("DIN Condensed", size: 20))
                                        .foregroundColor(.red)
                                        .padding()
                                    Spacer()
                                }
                                .onAppear {
                                    thisWordIsEmpty = true
                                }
                                
                            }
                            
                        }
                    }
                    
                    // MARK: Picker
                    HStack {
                        Text("Choose your wordbook:")
                            .font(.custom("Helvetica", size: 19))
                            .frame(width: 220)
                            .bold()
                        Menu {
                            Picker("", selection: $wordBookVM.selectedWordbook) {
                                ForEach(wordBookVM.wordBookTitle, id: \.self) { title in
                                    Text(title)
                                        .lineLimit(1)
                                        .tag(title)
                                }
                            }
                        } label: {
                            Text(wordBookVM.truncatedText)
                                .accentColor(.picker)
                                .frame(width: 120, height: 30)
                                .background(.white.opacity(0.4))
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                }
                
            case .failed:
                ContentUnavailableView {
                    VStack {
                        Image("error")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                        Text("Error loading word")
                            .bold()
                    }
                } description: {
                    Text("An error occurred while loading your word.")
                } actions: {
                    Button("Retry") {
                        wordBookVM.fetchWordBookList(modelContext: modelContext)
                        wordBookVM.selectedWordbook = initialWordBook
                        Task {
                            await vm.fetchWordFromAPI(modelContext: modelContext)
                        }
                    }
                    .buttonStyle(BorderedButtonStyle())
                }
            case .restricted:
                VStack(spacing: 20) {
                    Text("Sorry. You have reached the request limit.😰")
                        .font(Font.custom("DIN Condensed", size: 20))
                    Button {
                        rewardManager.showAd()
                        
                    } label: {
                        Text("Watch AD for 10 free requests 💓")
                            .font(Font.custom("DIN Condensed", size: 20))
                            .foregroundColor(.yellow)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 5).fill(Color.secondary.opacity(0.5)))
                        
                    }
                }
                .onAppear {
                    
                    print("Restricted view appeared")
                    if !rewardManager.rewardLoaded {
                        rewardManager.loadAd()
                    } else {
                        let requestLimit = UserDefaults.standard.integer(forKey: "requestLimit")
                        let newLimit = requestLimit + 1
                        UserDefaults.standard.set(newLimit, forKey: "requestLimit")
                        vm.requestLimit += 1
                        
                        Task {
                            await vm.fetchWordFromAPI(modelContext: modelContext)
                        }
                    }
                }
            }
        }
        .onLoad {
            wordBookVM.fetchWordBookList(modelContext: modelContext)
            wordBookVM.selectedWordbook = initialWordBook
            Task {
                await vm.fetchWordFromAPI(modelContext: modelContext)
            }
        }
    }
}

#Preview {
    DefinitionView(vm: DefinitionVM(selectedWord: "pathetic", dictionaryService: MockdataForWord()))
        .environmentObject(WordBookVM())
        .modelContainer(for: [Word.self, WordBook.self])
}
