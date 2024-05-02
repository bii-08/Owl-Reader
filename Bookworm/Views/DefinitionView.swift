//
//  DefinitionView.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/04/23.
//

import SwiftUI

struct DefinitionView: View {
    var word: String
    @State private var starTapped = false
    var body: some View {
       
        ZStack {
            Color(.cyan.opacity(0.2)).ignoresSafeArea()
            VStack(alignment: .leading) {
                    // selected word
                    HStack {
                        Text(word)
                            .font(.title2)
                            .textCase(.lowercase)
                            .bold()
                            .padding(.horizontal)
                        Spacer()
                        Button {
                            starTapped.toggle()
                        } label: {
                            Image(systemName: "star.fill")
                                .foregroundColor(starTapped ? .orange : .gray)
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    
                    // pronunciation
                    HStack {
                        VStack(alignment: .leading) {
                            HStack {
                                Text("UK")
                                    .foregroundColor(.secondary)
                                Button {
                                    
                                } label: {
                                    Image(systemName: "speaker.wave.3")
                                        .foregroundColor(.cyan)
                                }
                                
                            }
                            .padding(.horizontal)
                            
                            Text("[pronunciation]")
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                        }
                        VStack(alignment: .leading) {
                            HStack {
                                Text("US")
                                    .foregroundColor(.secondary)
                                Button {
                                    
                                } label: {
                                    Image(systemName: "speaker.wave.3")
                                        .foregroundColor(.cyan)
                                }
                                
                            }
                            .padding(.horizontal)
                            
                            Text("[pronunciation]")
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                        }
                    }
                    
                    ScrollView {
                        // word type
                        HStack {
                            Text("Adjective")
                                .padding(.horizontal)
                                .padding(.vertical, 5)
                                .foregroundColor(.orange)
                            Spacer()
                        }
                        
                        // definition and example
                        VStack(alignment: .leading) {
                            Text("a computer programming language that is often used on the internet.")
                                .padding(5)
                            Text("He seemed dazed and incoherent, apperently from blood loss.")
                                .foregroundColor(.secondary)
                                .padding(5)
                        }
                        .frame(width: 350)
                        .background(.gray.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding()
                        
                    }
                    
                }
            .padding()
        }
           
        
    }
}
    

#Preview {
    DefinitionView(word: "incoherent")
}
