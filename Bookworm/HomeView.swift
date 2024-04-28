//
//  ContentView.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/04/22.
//

import SwiftUI
import WebKit

struct HomeView: View {
    @EnvironmentObject var vm: HomeVM
    @State private var urlString = ""
    @State private var selectedWord: String? = nil
    @State private var showingDefinition = false
    @State private var processingLink = false
    @State private var showingShortcutWebPage = false
    @State private var webView: WKWebView? = nil // State variable to hold WKWebView instance
    @State private var showingAddLinkSheet = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    ZStack {
                        
                        //Header Image
                        Image("HeaderImage")
                            .resizable()
                            .ignoresSafeArea()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, maxHeight: 300)
                            .cornerRadius(10)
                        
                        VStack(alignment: .leading) {
                            
                            // App's name
                            Text("BOOKWORM")
                                .font(.title)
                                .bold()
                                .padding(.horizontal)
                            
                            // SearchBar
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .padding()
                                TextField("", text: $urlString, prompt: Text("Enter your web link here").foregroundColor(.white.opacity(0.7)))
                                    .foregroundColor(.white)
                                    .onSubmit {
                                        processingLink = true
                                    }
                                    .submitLabel(.done)
                            }
                            .background(RoundedRectangle(cornerRadius: 5).fill(Color("SearchBar").opacity(0.6)))
                            .padding(12)
                            
                        }
                        .navigationDestination(isPresented: $processingLink) {
                            if let url = URL(string: urlString) {
                                VStack {
                                    WebView(url: url, webView: $webView) { word in
                                        print(word)
                                        selectedWord = word
                                        showingDefinition = true
                                    }
                                    .sheet(isPresented: $showingDefinition) {
                                        if let word = selectedWord {
                                            DefinitionView(word: word)
                                                .presentationBackground(.thinMaterial)
                                                .presentationCornerRadius(15)
                                                .presentationDetents([.height(300)])
                                        }
                                    }
                                    navigationBarOnWebPage
                                }
                            }
                        }
                    }
                }
                // Shortcut section
                VStack {
                    HStack {
                        Text("Shortcut")
                            .font(.title3)
                            .foregroundColor(.primary.opacity(0.8))
                            .bold()
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            VStack {
                                // Add New Link Button
                                Button {
                                    showingAddLinkSheet = true
                                } label: {
                                    
                                    Image(systemName: "plus.circle.fill")
                                        .scaleEffect(4)
                                        .foregroundColor(.red.opacity(0.8))
                                        .frame(width: 100, height: 100)
                                        .padding(10)
                                }
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .shadow(radius: 3)
                                
                                Text("Add New Link")
                                    .foregroundColor(.primary.opacity(0.5))
                                    .padding(5)
                            }
                            .navigationDestination(isPresented: $showingAddLinkSheet) {
                                AddLinkView()
                            }
                            
                            ForEach(vm.savedShortcuts, id: \.self) { shortcut in
                                ShortcutView(webPageTitle: shortcut.webPageTitle, favicon: shortcut.favicon) {
                                    urlString = shortcut.url.absoluteString
                                    showingShortcutWebPage = true
                                }
                                
                            }
                        }
                        .navigationDestination(isPresented: $showingShortcutWebPage) {
                            if let url = URL(string: urlString) {
                                
                                VStack {
                                    WebView(url: url, webView: $webView) { word in
                                        print(word)
                                        selectedWord = word
                                        showingDefinition = true
                                    }
                                    .sheet(isPresented: $showingDefinition) {
                                        if let word = selectedWord {
                                            DefinitionView(word: word)
                                                .presentationBackground(.thinMaterial)
                                                .presentationCornerRadius(15)
                                                .presentationDetents([.height(300)])
                                            
                                        }
                                    }
                                    
                                    navigationBarOnWebPage
                                    
                                }
                                
                            }
                            
                        }
                    }
                }
                // Recently Read section
                VStack {
                    HStack {
                        Text("Recently Read")
                            .font(.title3)
                            .foregroundColor(.primary.opacity(0.8))
                            .bold()
                        Spacer()
                    }
                    .padding(.horizontal)
                }
                
            }
            .onAppear {
                urlString = ""
            }
            .ignoresSafeArea()
        }
    }
}

extension HomeView {
    private var navigationBarOnWebPage: some View {
        HStack(spacing: 50) {
            // Go back button
            Button {
                if let webView = webView, webView.canGoBack {
                    webView.goBack()
                }
            } label: {
                Image(systemName: "arrow.left")
                
            }
            
            // Go forward button
            Button {
                if let webView = webView, webView.canGoForward {
                    webView.goForward()
                }
            } label: {
                Image(systemName: "arrow.right")
            }
            
            // Reload button
            Button {
                if let webView = webView {
                    webView.reload()
                }
            } label: {
                Image(systemName: "arrow.counterclockwise")
            }
            
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(HomeVM())
}
