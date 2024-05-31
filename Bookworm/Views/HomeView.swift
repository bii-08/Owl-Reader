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
    @Environment(\.dismiss) var dismiss
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
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("background")
                ScrollView {
                    VStack {
                        
                        // MARK: HEADER
                        header
                        
                        // MARK: BREAKING NEWS
                        breakingNews
                        
                        // MARK: SHORTCUT
                        shotcuts
                        
                        // MARK: RECENTLY READ
                        recentlyRead
                        
                        Spacer()
                    }
                }
            }
            .edgesIgnoringSafeArea(.top)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                tabBarVisibility = .visible
                urlString = ""
                vm.fetchRecentlyReadURLs(modelContext: modelContext)
                vm.fetchShortcuts(modelContext: modelContext)
                Task {
                    await vm.handleHeadlines(modelContext: modelContext)
                }
            }
        }
        .toolbar(tabBarVisibility, for: .tabBar)
        .toolbarBackground(tabBarVisibility, for: .tabBar)
        .toolbarBackground(colorScheme == .light ? Color.white.opacity(0.5) : Color.black.opacity(0.5), for: .tabBar)
    }
}

extension HomeView {
    
    private var header: some View {
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
                Text("Owl Read")
                    .foregroundColor(.black)
                    .font(Font.custom("Marker Felt", size: 27))
                    .bold()
                    .padding(.horizontal)
                
                // SearchBar
                HStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .padding(.horizontal, 10)
                        TextField("", text: $urlString, prompt: Text("Enter your web link").foregroundColor(.white.opacity(0.7)))
                            .foregroundColor(.white)
                            .onSubmit {
                                processingLink = true
                            }
                            .submitLabel(.done)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .focused($isTextFieldFocused)
                    }
                    .frame(maxHeight: 35)
                    .background(RoundedRectangle(cornerRadius: 5).fill(Color("SearchBar").opacity(0.6)))
                    
                    
                    Button {
                        urlString = ""
                        isTextFieldFocused = false
                    } label: {
                        Text("Cancel")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxHeight: 35)
                            .background(RoundedRectangle(cornerRadius: 5).fill(Color("SearchBar").opacity(0.8)))
                    }
                }
                .padding(.horizontal)
            }
            .navigationDestination(isPresented: $processingLink) {
                if let url = URL(string: vm.handleUserInputSearchBar(userInput: urlString)) {
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
    }
    private var navigationBarOnWebPage: some View {
        
        ZStack {
            HStack(spacing: 2) {
                // Reload button
                Button {
                    webView?.reload()
                } label: {
                    Image(systemName: "arrow.counterclockwise.circle.fill")
                        .tint(.orange.opacity(0.7))
                        .font(.system(size: 15))
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
                        .font(.system(size: 15))
                }
                .disabled(!(webView?.canGoBack ?? false))
                
                // Go forward button
                Button {
                    webView?.goForward()
                } label: {
                    Image(systemName: "arrowshape.turn.up.right.fill")
                        .tint(.orange.opacity(0.7))
                        .font(.system(size: 15))
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
    private var breakingNews: some View {
        VStack(spacing: 5) {
            HStack {
                Text("Breaking News")
                    .font(Font.custom("DIN Condensed", size: 30))
                    .foregroundColor(.primary.opacity(0.8))
                    .bold()
                Spacer()
                
            }
            .padding(.horizontal)
            
            Divider()
                .padding(.horizontal)
            
            switch vm.loadingState {
            case .loading:
                ProgressHeadLineView() 
            case .success:
                // Tab View
                TabView {
                    ForEach(0..<vm.headLines.count, id: \.self) { index in
                        HeadlineView(headline: vm.headLines[index]) {
                            selectedHeadline = vm.headLines[index]
                        }
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
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
//                            Task {
//                                await vm.fetchHeadlinesFromAPI(modelContext: modelContext)
//                            }
                        }
                        .buttonStyle(BorderedButtonStyle())
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal)
                
            case .restricted:
                VStack {
                    Text("")
                }
            }
        }
    }
    private var shotcuts: some View {
        VStack(spacing: 5) {
            HStack {
                Text("Shortcuts")
                    .font(Font.custom("DIN Condensed", size: 30))
                    .foregroundColor(.primary.opacity(0.8))
                    .bold()
                Spacer()
            }
            .padding(.horizontal)
            
            Divider()
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
                            .padding(12)
                    }
                    .padding(.vertical, 2)
                    .navigationDestination(isPresented: $showingAddLinkSheet) {
                        AddOrEditLinkView(photoPickerVM: PhotoPickerVM())
                    }
                    
                    // Shortcut button
                    ForEach(vm.savedShortcuts, id: \.self) { shortcut in
                        ShortcutView(webPageTitle: shortcut.webPageTitle, favicon: UIImage(data: shortcut.favicon ?? Data())) {
                            urlString = shortcut.url.absoluteString
                            showingShortcutWebPage = true
                        }
                        .padding(.vertical, 10)
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
    }
    private var recentlyRead: some View {
        VStack(spacing: 5) {
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
            
            Divider()
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
                                        .font(.title3)
                                        .lineLimit(1)
                                    Spacer()
                                }
                                HStack {
                                    Text(link.url.absoluteString)
                                        .lineLimit(1)
                                        .font(.footnote)
                                    Spacer()
                                }
                            }
                            .padding(7)
                            .background(RoundedRectangle(cornerRadius: 5).fill(Color.gray.opacity(0.1)))
                        }
                        .listRowBackground(Color("background"))
                        .listRowSeparator(.hidden)
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
                .frame(height: 200)
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
    }
}

#Preview {
    HomeView()
        .environmentObject(HomeVM())
        .environmentObject(WordBookVM())
        .modelContainer(for: [Link.self, Shortcut.self, Headline.self, Word.self, WordBook.self])
}
