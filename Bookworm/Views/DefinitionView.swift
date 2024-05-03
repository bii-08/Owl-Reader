//
//  DefinitionView.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/04/23.
//

import SwiftUI
import AVFoundation


struct DefinitionView: View {
    @State private var starTapped = false
    @StateObject var vm: DefinitionVM
    let synthesizer = AVSpeechSynthesizer()
    
    var body: some View {
       
        ZStack {
            Color(.cyan.opacity(0.2)).ignoresSafeArea()
            VStack(alignment: .leading) {
                    // Selected word
                    HStack {
                        Text(vm.selectedWord)
                            .font(.custom("Helvetica", size: 25))
                            .textCase(.lowercase)
                            .bold()
                            .padding(.horizontal)
                            .padding(.vertical, 5)
                        
                        Spacer()
                        Button {
                            starTapped.toggle()
                        } label: {
                            Image(systemName: "star.fill")
                                .foregroundColor(starTapped ? .orange : .gray)
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Pronunciation
                        VStack(alignment: .leading) {
                            HStack {
                                if let word = vm.word {
                                    if let pronunciation = word.pronunciation {
                                        Text("[\(pronunciation.all)]")
                                            .font(.custom("Helvetica", size: 19))
                                            .foregroundColor(.secondary)
                                            .padding(.horizontal)
                                    }
                                }
                                Spacer()
                                
                                // British
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
                                .padding(.horizontal)
                                
                                // American
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
                                .padding(.horizontal)
                            }
                            
                        }
                    
                    ScrollView {
                        if let word = vm.word {
                            if let results = word.results {
                                ForEach(results, id: \.self) { result in
                                    HStack {
                                        VStack(alignment: .leading) {
                                            
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
                                                Text("Synonyms:")
                                                    .font(.custom("Helvetica", size: 19))
                                                    .underline()
                                            }
                                            
                                            if let synonyms = result.synonyms {
                                                ForEach(synonyms, id: \.self) { syn in
                                                    HStack {
                                                        Text(syn)
                                                            .font(.custom("Helvetica", size: 18))
                                                            .foregroundColor(.secondary)
                                                    }
                                                }
                                            }
                                            
                                            
                                           Spacer()
                                        }
                                        .frame(width: 350)
                                        .padding(8)
                                        .background(.ultraThickMaterial)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .padding(.vertical, 5)
                                        
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            
                        }
                    }
            }
            .padding()
        }
    }
}
    
#Preview {
    DefinitionView(vm: DefinitionVM(selectedWord: "incoherent"))
}
