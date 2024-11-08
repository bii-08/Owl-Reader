//
//  DefinitionView.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/04/23.
//

import SwiftUI
import AVFoundation
import SwiftData
import GoogleMobileAds

struct DefinitionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) var presentationMode
    
    @EnvironmentObject private var reviewsManager: ReviewRequestManager
    @Environment(\.requestReview) var requestReview
    @Query var allWords: [Word]
    
    @Environment(\.dismiss) var dismiss
    @StateObject private var rewardManager = RewardAdsManager()
    @ObservedObject private var requestManager = RequestManager.shared
    @StateObject var vm: DefinitionVM
    @EnvironmentObject var wordBookVM: WordBookVM
    @State var title = ""
    @State private var thisWordIsEmpty = false
    var initialWordBook: String
    var width: CGFloat?
    var height: CGFloat?
    let synthesizer = AVSpeechSynthesizer()
    var deviceType: DeviceType
    var isPopover = false
    init(vm: DefinitionVM, initialWordBook: String = "Default", width: CGFloat? = nil, height: CGFloat? = nil, isPopover: Bool = false) {
        _vm = StateObject(wrappedValue: vm)
        self.initialWordBook = initialWordBook
        self.width = width
        self.height = height
        self.deviceType = DeviceInfo.shared.getDeviceType()
        self.isPopover = isPopover
    }
    var body: some View {
        
        ZStack {
            Color(.cyan.opacity(0.2)).ignoresSafeArea()
            
            switch vm.loadingState {
            case .loading:
                ProgressView(Localized.Loading)
                    .frame(width: deviceType == .pad ? width : nil, height: deviceType == .pad ? height : nil)
                    .onAppear {
                        AnalyticsManager.shared.logEvent(name: "DifinitionView_LoadingView Appear")
                    }
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
                                AnalyticsManager.shared.logEvent(name: "DifinitionView_StarButtonClick")
                                if reviewsManager.canAskForReview(numberOfWords: allWords.count) {
                                    requestReview()
                                }
                            }
                            HapticManager.shared.notification(type: .success)
                            
                        } label: {
                            if let word = vm.word {
                                Image(systemName: "star.fill")
                                    .scaleEffect(1.25)
                                    .foregroundColor(wordBookVM.isThisWordAlreadySaved(selectedWord: word, wordBookName: wordBookVM.selectedWordbook) ? .orange : .gray)
                            }
                        }
                        .disabled(thisWordIsEmpty)
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
                                                Text(Localized.Synonyms)
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
                                    Text(Localized.Sorry_Could_not_find_this_word)
                                        .font(Font.custom("DIN Condensed", size: 20))
                                        .foregroundColor(.red)
                                        .padding()
                                    Spacer()
                                }
                                .onAppear {
                                    thisWordIsEmpty = true
                                    let remainingAdjust = requestManager.requestRemaning + 1
                                    UserDefaults.standard.set(remainingAdjust, forKey: "requestRemaining")
                                    requestManager.requestRemaning += 1
                                }
                                
                            }
                            
                        }
                    }
                    
                    // MARK: Picker
                    HStack {
                        Text(Localized.Choose_your_wordbook)
                            .font(.custom("Helvetica", size: 19))
                            .bold()
                            .frame(minWidth: 220)
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
                        Spacer()
                    }
                    .frame(minWidth: deviceType == .pad ? 420 : nil)
                    .padding()
                }
                .frame(maxWidth: deviceType == .pad ? width : nil, maxHeight: deviceType == .pad ? height : nil)
                .onAppear {
                    AnalyticsManager.shared.logEvent(name: "DifinitionView_SuccessView Appear")
                }
                .onDisappear {
                    if let word = vm.word {
                        if wordBookVM.needToDelete {
                            modelContext.delete(word)
                        }
                    }
                }
                
            case .failed:
                VStack {
                    ContentUnavailableView {
                        VStack {
                            Image("error")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                            Text(Localized.Error_loading_word)
                                .bold()
                        }
                        .onAppear {
                            AnalyticsManager.shared.logEvent(name: "DifinitionView_ErrorView Appear")
                        }
                    } description: {
                        Text(Localized.An_error_occurred_while_loading_your_word)
                    } actions: {
                        Button(Localized.Retry) {
                            wordBookVM.fetchWordBookList(modelContext: modelContext)
                            wordBookVM.selectedWordbook = initialWordBook
                            Task {
                                await vm.fetchWordFromAPI(modelContext: modelContext)
                            }
                        }
                        .buttonStyle(BorderedButtonStyle())
                }
                }
                .frame(minWidth: 400, minHeight: 420)
                
            case .restricted:
                VStack(spacing: 20) {
                    Image("lock")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 90, height: 90)
                    Text(Localized.Sorry_You_have_reached_the_request_limit)
                        .font(Font.custom("DIN Condensed", size: 20))
                    ///
//                    Text(Localized.Please_try_again_tomorrow)
//                        .font(Font.custom("DIN Condensed", size: 20))
//                    
//                    Button {
//                        dismiss()
//                    } label: {
//                        Text(Localized.Got_it)
//                            .font(Font.custom("DIN Condensed", size: 20))
//                    }
//                    .buttonStyle(.borderedProminent)
                    ///
                    Button {
                        rewardManager.showAd()
                        
                    } label: {
                        Text(Localized.Watch_AD_for_10_free_requests)
                            .font(Font.custom("DIN Condensed", size: 20))
                            .foregroundColor(rewardManager.rewardAd == nil ? .gray.opacity(0.5) : .yellow)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 5).fill(rewardManager.rewardAd == nil ? .gray.opacity(0.5) : Color.teal.opacity(0.8)))
                        
                    }
                    .disabled(rewardManager.rewardAd == nil)
                }
                .frame(minWidth: 400, minHeight: 420)
                
                .onAppear {
                    
                    print("Restricted view appeared")
                    if !rewardManager.rewardLoaded {
                        rewardManager.loadAd()
                    } else {
                        vm.loadingState = .rewarded
                    }
                    AnalyticsManager.shared.logEvent(name: "DifinitionView_RestrictedView Appear")
                }
                
            case .rewarded:
                RewardedView {
                    Task {
                        await vm.fetchWordFromAPI(modelContext: modelContext)
                    }
                }
                .frame(maxWidth: deviceType == .pad ? width : nil, maxHeight: deviceType == .pad ? height : nil)
                .onAppear {
                    requestManager.adsWatchCount += 1
                    UserDefaults.standard.set(requestManager.adsWatchCount, forKey: "adsWatchCount")
                    AnalyticsManager.shared.logEvent(name: "DifinitionView_RewardedView Appear")
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
        .overlay(alignment: .bottomTrailing) {
            if deviceType == .pad && isPopover {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                        .padding()
                }
            }
        }
    }
}

#Preview {
    DefinitionView(vm: DefinitionVM(selectedWord: "pathetic", webService: MockdataWebService()))
        .environmentObject(WordBookVM())
        .modelContainer(for: [Word.self, WordBook.self])
}
