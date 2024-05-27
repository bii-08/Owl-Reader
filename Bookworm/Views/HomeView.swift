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
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var vm: HomeVM
    @Environment(\.modelContext) var modelContext
    @StateObject var viewModel = ProgressVM()
    
    @State var tabBarVisibility: Visibility = .visible
    
    @State private var urlString = ""
    @State private var selectedWord: String? = nil
    @State private var showingDefinition = false
    @State private var processingLink = false
    @State private var showingShortcutWebPage = false
    @State private var webView: WKWebView? = nil // State variable to hold WKWebView instance
    @State private var showingAddLinkSheet = false
    @State private var showingRecentlyReadWebPage = false
    @State private var selectedHeadline: Headline?
    @State private var urlToDisplay = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("background")
                
                VStack {
                    // MARK: HEADER
                    ZStack {
                        // MARK: HEADER IMAGE
                            Image("HeaderImage")
                                .resizable()
                                .scaledToFill()
                                .frame(height: 160)
                                .cornerRadius(10)
                            Spacer()
                        
                        VStack(alignment: .leading) {
                            // App's name
                            Text("ReadSmart")
                                .font(Font.custom("Marker Felt", size: 27))
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
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                            }
                            .background(RoundedRectangle(cornerRadius: 5).fill(Color("SearchBar").opacity(0.6)))
                            .padding(.horizontal)
                        }
                        .navigationDestination(isPresented: $processingLink) {
                            if let url = URL(string: urlString) {
                                VStack {
                                    ZStack{
                                        Divider()
                                        if viewModel.progress >= 0.0 && viewModel.progress < 1.0 {
                                            ProgressView(value: viewModel.progress)
                                                .progressViewStyle(LinearProgressViewStyle())
                                                .padding()
                                        }
                                    }
                                    .frame(height: 4)
                                    VStack {
                                        WebView(url: url, viewModel: viewModel, webView: $webView, didFinishLoadingThisURL: { link in vm.addURL(link: link, modelContext: modelContext)
                                            urlToDisplay = link?.url.absoluteString ?? ""
                                        }) { word in
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
                                    //.edgesIgnoringSafeArea(.all)
                                }
                                .toolbarBackground(tabBarVisibility, for: .tabBar)
                                .toolbarBackground(colorScheme == .light ? Color.white.opacity(0.7) : Color.black.opacity(0.7), for: .tabBar)
                            }
                        }
                    }
                    
                    // MARK: BREAKING NEWS
                    VStack(spacing: 0) {
                        HStack {
                            Text("Breaking News")
                                .font(Font.custom("DIN Condensed", size: 30))
                                .foregroundColor(.primary.opacity(0.8))
                                .bold()
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        switch vm.loadingState {
                        case .loading:
                            ProgressView("Loading...")
                        case .success:
                            // Tab View
                            TabView {
                                ForEach(0..<vm.headLines.count, id: \.self) { index in
                                    HeadlineView(headline: vm.headLines[index]) {
                                        selectedHeadline = vm.headLines[index]
                                    }
                                }
                            }
                            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                            .frame(height: 200)
                            .navigationDestination(item: $selectedHeadline) { headline in
                                VStack {
                                    ZStack{
                                        Divider()
                                        if viewModel.progress >= 0.0 && viewModel.progress < 1.0 {
                                            ProgressView(value: viewModel.progress)
                                                .progressViewStyle(LinearProgressViewStyle())
                                                .padding()
                                        }
                                    }
                                    .frame(height: 4)
                                    VStack {
                                        WebView(url: URL(string: headline.url),viewModel: viewModel, webView: $webView, didFinishLoadingThisURL: { link in vm.addURL(link: link, modelContext: modelContext)
                                            urlToDisplay = link?.url.absoluteString ?? ""
                                        }) { word in
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
                                .toolbarBackground(tabBarVisibility, for: .tabBar)
                                .toolbarBackground(colorScheme == .light ? Color.white.opacity(0.7) : Color.black.opacity(0.7), for: .tabBar)
                            }
                        case .failed:
                            ZStack {
                                Color.gray.opacity(0.1)
                                ContentUnavailableView {
                                    VStack {
                                        Image("error")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 50, height: 50)
                                        Text("Error loading headlines")
                                            .bold()
                                    }
                                } description: {
                                    Text("An error occurred while loading headlines.")
                                } actions: {
                                    Button("Retry") {
                                        Task {
                                            await vm.fetchHeadlines()
                                        }
                                    }
                                    .buttonStyle(BorderedButtonStyle())
                                }
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .padding(.horizontal)
                        }
                    }
                    
                    // MARK: SHORTCUT
                    VStack {
                        HStack {
                            Text("Shortcut")
                                .font(Font.custom("DIN Condensed", size: 30))
                                .foregroundColor(.primary.opacity(0.8))
                                .bold()
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                // Add/Edit Link Button
                                VStack(spacing: 2) {
                                    Button {
                                        showingAddLinkSheet = true
                                    } label: {
                                        Image(systemName: "plus.circle.fill")
                                            .scaleEffect(2)
                                            .foregroundColor(.red.opacity(0.8))
                                            .frame(width: 50, height: 50)
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
                                    AddOrEditLinkView(photoPickerVM: PhotoPickerVM())
                                }
                                
                                // Shortcut button
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
                                        ZStack{
                                            Divider()
                                            if viewModel.progress >= 0.0 && viewModel.progress < 1.0 {
                                                ProgressView(value: viewModel.progress)
                                                    .progressViewStyle(LinearProgressViewStyle())
                                                    .padding()
                                            }
                                        }
                                        .frame(height: 4)
                                        VStack {
                                            WebView(url: url, viewModel: viewModel, webView: $webView, didFinishLoadingThisURL: { link in vm.addURL(link: link, modelContext: modelContext)
                                                urlToDisplay = link?.url.absoluteString ?? ""
                                            }) { word in
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
                                    .toolbarBackground(tabBarVisibility, for: .tabBar)
                                    .toolbarBackground(colorScheme == .light ? Color.white.opacity(0.7) : Color.black.opacity(0.7), for: .tabBar)
                                }
                            }
                        }
                    }
                    
                    // MARK: RECENTLY READ
                    VStack {
                        HStack {
                            Text("Recently Read" + " " + "(\(vm.recentlyReadURLs.count))")
                                .font(Font.custom("DIN Condensed", size: 30))
                                .foregroundColor(.primary.opacity(0.8))
                                .bold()
                            Spacer()
                            if vm.recentlyReadURLs.count >= 2 {
                                Button("Clear all") {
                                    for url in vm.recentlyReadURLs {
                                        modelContext.delete(url)
                                    }
                                    vm.fetchRecentlyReadURLs(modelContext: modelContext)
                                }
                                .buttonStyle(BorderedButtonStyle())
                                .foregroundColor(.cyan)
                            }
                        }
                        .padding(.horizontal)
                        
                        if vm.recentlyReadURLs == [] {
                            Text("No history")
                                .font(Font.custom("Avenir Next Condensed", size: 20))
                                .foregroundColor(.secondary)
                                .padding(40)
                        } else {
                            List {
                                ForEach(vm.recentlyReadURLs.reversed(), id: \.self) { link in
                                    Button {
                                        urlString = link.url.absoluteString
                                        showingRecentlyReadWebPage = true
                                    } label: {
                                        VStack {
                                            HStack {
                                                Text(link.webPageTitle)
                                                    .foregroundColor(.secondary)
                                                    .font(.headline)
                                                    .lineLimit(1)
                                                Spacer()
                                            }
                                            HStack {
                                                Text(link.url.absoluteString)
                                                    .lineLimit(1)
                                                    .font(.caption)
                                                Spacer()
                                            }
                                        }
                                        .padding(7)
                                        .background(RoundedRectangle(cornerRadius: 5).fill(Color.gray.opacity(0.1)))
                                    }
                                    .listRowBackground(Color("background"))
                                    //                                    .listRowSeparator(.hidden)
                                    .swipeActions(allowsFullSwipe: true) {
                                        Button {
                                            if let index = vm.recentlyReadURLs.firstIndex(where: { $0.url == link.url }) {
                                                withAnimation {
                                                    modelContext.delete(vm.recentlyReadURLs[index])
                                                }
                                            }
                                            vm.fetchRecentlyReadURLs(modelContext: modelContext)
                                        } label: {
                                            Label("", image: "trash")
                                        }
                                        .tint(.clear)
                                    }
                                }
                            }
                            .listStyle(.plain)
                        }
                    }
                    .navigationDestination(isPresented: $showingRecentlyReadWebPage) {
                        if let url = URL(string: urlString) {
                            VStack {
                                ZStack{
                                    Divider()
                                    if viewModel.progress >= 0.0 && viewModel.progress < 1.0 {
                                        ProgressView(value: viewModel.progress)
                                            .progressViewStyle(LinearProgressViewStyle())
                                            .padding()
                                    }
                                }
                                .frame(height: 4)
                                VStack {
                                    WebView(url: url, viewModel: viewModel, webView: $webView, didFinishLoadingThisURL: { link in vm.addURL(link: link, modelContext: modelContext)
                                        urlToDisplay = link?.url.absoluteString ?? ""
                                    }) { word in
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
                            .toolbar(tabBarVisibility, for: .tabBar)
                            .toolbarBackground(tabBarVisibility, for: .tabBar)
                            .toolbarBackground(colorScheme == .light ? Color.white.opacity(0.7) : Color.black.opacity(0.7), for: .tabBar)
                        }
                    }
                    
                    Spacer()
                }
            }
            .edgesIgnoringSafeArea(.top)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                urlString = ""
                vm.fetchRecentlyReadURLs(modelContext: modelContext)
                vm.fetchShortcuts(modelContext: modelContext)
                tabBarVisibility = .visible
                
            }
        }
        .toolbar(tabBarVisibility, for: .tabBar)
        .toolbarBackground(tabBarVisibility, for: .tabBar)
        .toolbarBackground(colorScheme == .light ? Color.white.opacity(0.5) : Color.black.opacity(0.5), for: .tabBar)
    }
}

extension HomeView {
    private var navigationBarOnWebPage: some View {
        
        ZStack {
            HStack(spacing: 10) {
                // Reload button
                Button {
                    webView?.reload()
                } label: {
                    Image(systemName: "arrow.counterclockwise.circle.fill")
                        .tint(.orange.opacity(0.7))
                }
                
                TextField("Loading url....", text: $urlToDisplay, onCommit: {
                    
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                // Go back button
                Button {
                    webView?.goBack()
                } label: {
                    Image(systemName: "arrowshape.turn.up.backward.fill")
                        .tint(.orange.opacity(0.7))
                }
                .disabled(!(webView?.canGoBack ?? false))
                
                // Go forward button
                Button {
                    webView?.goForward()
                } label: {
                    Image(systemName: "arrowshape.turn.up.right.fill")
                        .tint(.orange.opacity(0.7))
                }
                .disabled(!(webView?.canGoForward ?? false))
                
                Button {
                    if tabBarVisibility == .visible {
                        tabBarVisibility = .hidden
                    } else {
                        tabBarVisibility = .visible
                    }
                } label: {
                    Image(systemName: (tabBarVisibility == .visible) ? "eyeglasses" : "eyeglasses.slash")
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
        .modelContainer(for: [Link.self, Shortcut.self, Headline.self, Word.self, WordBook.self])
}
