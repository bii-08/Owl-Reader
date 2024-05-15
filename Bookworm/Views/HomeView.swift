//
//  ContentView.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/04/22.
//

import SwiftUI
import WebKit
import SwiftData

struct HomeView: View {
    @EnvironmentObject var vm: HomeVM

    @State private var urlString = ""
    @State private var selectedWord: String? = nil
    @State private var showingDefinition = false
    @State private var processingLink = false
    @State private var showingShortcutWebPage = false
    @State private var webView: WKWebView? = nil // State variable to hold WKWebView instance
    @State private var showingAddLinkSheet = false
    @State private var showingRecentlyReadWebPage = false
    @State private var selectedHeadline: Headline?
   
    var body: some View {
        NavigationStack {
            ZStack {
                Color("background").ignoresSafeArea()
                
                ScrollView {
                    VStack {
                        ZStack {
                            //Header Image
                            Image("HeaderImage")
                                .resizable()
                                .ignoresSafeArea()
                                .scaledToFill()
                                .frame(maxWidth: .infinity, maxHeight: 200)
                                .cornerRadius(10)
                            
                            VStack(alignment: .leading) {
                                Spacer()
                                // App's name
                                Text("BOOKWORM")
                                    .font(Font.custom("Marker Felt", size: 40))
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
                                        .sheet(isPresented: Binding(get: { showingDefinition }, set: { showingDefinition = $0 })) {
                                            if let word = selectedWord {
                                                DefinitionView(vm: DefinitionVM(selectedWord: word))
                                                .presentationBackground(.thinMaterial)
                                                .presentationCornerRadius(15)
                                                .presentationDetents([.large, .height(300)])
                                            }
                                        }
                                    }
                                    .toolbar{
                                        navigationBarOnWebPage
                                    }
                                    .edgesIgnoringSafeArea(.all)
                                }
                            }
                        }
                    }
                    // Latest Headlines section
                    VStack(spacing: 1) {
                        HStack {
                            Text("Breaking News")
                                .font(Font.custom("DIN Condensed", size: 30))
                                .foregroundColor(.primary.opacity(0.8))
                                .bold()
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        // Tab View
                        TabView {
                            ForEach(0..<vm.headLines.count, id: \.self) { index in
                                HeadlineView(headline: vm.headLines[index]) {
                                    selectedHeadline = vm.headLines[index]
                                }
                            }
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                        .aspectRatio(1.5, contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .navigationDestination(item: $selectedHeadline) { headline in
                            VStack {
                                WebView(url: URL(string: headline.url), webView: $webView) { word in
                                    print(word)
                                    selectedWord = word
                                    showingDefinition = true
                                }
                                .sheet(isPresented: Binding(get: { showingDefinition }, set: { showingDefinition = $0 })) {
                                    if let word = selectedWord {
                                        DefinitionView(vm: DefinitionVM(selectedWord: word))
                                        .presentationBackground(.thickMaterial)
                                        .presentationCornerRadius(15)
                                        .presentationDetents([.large, .height(300)])
                                    }
                                }
                            }
                            .toolbar{
                                navigationBarOnWebPage
                            }
                            .edgesIgnoringSafeArea(.all)
                        }
                    }
                    // Shortcut section
                    VStack {
                        HStack {
                            Text("Shortcut")
                                .font(Font.custom("DIN Condensed", size: 30))
                                .foregroundColor(.primary.opacity(0.8))
                                .bold()
                            Spacer()
                        }
                        .padding(.horizontal)
                          
                        Spacer()
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                VStack {
                                    // Add/Edit Link Button
                                    Button {
                                        showingAddLinkSheet = true
                                    } label: {
                                        Image(systemName: "plus.circle.fill")
                                            .scaleEffect(2)
                                            .foregroundColor(.red.opacity(0.8))
                                            .frame(width: 80, height: 80)
                                            .padding(9)
                                    }
                                    .background(.ultraThinMaterial)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .shadow(radius: 1)
                                    
                                    Text("Add / Edit Link")
                                        .foregroundColor(.primary.opacity(0.5))
                                        .padding(5)
                                }
                                .navigationDestination(isPresented: $showingAddLinkSheet) {
                                    AddLinkView(photoPikerVM: PhotoPickerVM())
                                }
                                
                                ForEach(vm.savedShortcuts, id: \.self) { shortcut in
                                    ShortcutView(webPageTitle: shortcut.webPageTitle, favicon: UIImage(data: shortcut.favicon ?? Data())) {
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
                                        .sheet(isPresented: Binding(get: { showingDefinition }, set: { showingDefinition = $0 })) {
                                            if let word = selectedWord {
                                                DefinitionView(vm: DefinitionVM(selectedWord: word))
                                                .presentationBackground(.thickMaterial)
                                                .presentationCornerRadius(15)
                                                .presentationDetents([.large, .height(300)])
                                            }
                                        }
                                    }
                                    .toolbar{
                                        navigationBarOnWebPage
                                    }
                                    .edgesIgnoringSafeArea(.all)
                                }
                            }
                        }
                    }
                     
                    // Recently Read section
                    VStack {
                        HStack {
                            Text("Recently Read")
                                .font(Font.custom("DIN Condensed", size: 30))
                                .foregroundColor(.primary.opacity(0.8))
                                .bold()
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        ForEach(vm.recentlyReadURLs, id: \.self) { url in
                            Button {
                                urlString = url
                                showingRecentlyReadWebPage = true
                            } label: {
                                Text(url)
                            }
                        }
                    }
                    .navigationDestination(isPresented: $showingRecentlyReadWebPage) {
                        if let url = URL(string: urlString) {
                            VStack {
                                WebView(url: url, webView: $webView) { word in
                                    print(word)
                                    selectedWord = word
                                    showingDefinition = true
                                }
                                .sheet(isPresented: Binding(get: { showingDefinition }, set: { showingDefinition = $0 })) {
                                    if let word = selectedWord {
                                        DefinitionView(vm: DefinitionVM(selectedWord: word))
                                        .presentationBackground(.thickMaterial)
                                        .presentationCornerRadius(15)
                                        .presentationDetents([.large, .height(300)])
                                    }
                                }
                            }
                            .toolbar{
                                navigationBarOnWebPage
                            }
                            .edgesIgnoringSafeArea(.all)
                        }
                    }
                }
                .onAppear {
                    urlString = ""
                }
                .ignoresSafeArea()
                
            }
        }
    }
}

extension HomeView {
    private var navigationBarOnWebPage: some View {
        
        ZStack {
            HStack(spacing: 25) {
                // Go back button
                Button {
                    if let webView = webView, webView.canGoBack {
                        webView.goBack()
                    }
                    
                } label: {
                    Image(systemName: "arrowshape.turn.up.backward.fill")
                        .tint(.orange.opacity(0.7))
                }
                
                // Go forward button
                Button {
                    if let webView = webView, webView.canGoForward {
                        webView.goForward()
                    }
                } label: {
                    Image(systemName: "arrowshape.turn.up.right.fill")
                        .tint(.orange.opacity(0.7))
                }
                
                // Reload button
                Button {
                    if let webView = webView {
                        webView.reload()
                    }
                } label: {
                    Image(systemName: "arrow.counterclockwise.circle.fill")
                        .tint(.orange.opacity(0.7))
                }
            }
        }
        .frame(height: 50)
    }
}

#Preview {
    HomeView()
        .environmentObject(HomeVM())
        .environmentObject(WordBookVM())
        .modelContainer(for: [Link.self, Headline.self, Word.self, WordBook.self])
}
