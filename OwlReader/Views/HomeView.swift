//
//  ContentView.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/04/22.
//

import SwiftUI
import WebKit
import SwiftData
import StoreKit

struct HomeView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var vm: HomeVM
    @ObservedObject private var requestManager = RequestManager.shared
    @ObservedObject var addOrEditPhotoPickerVM = PhotoPickerVM()
    @Environment(\.modelContext) var modelContext
    @StateObject var viewModel = ProgressVM()
    
    @State var tabBarVisibility: Visibility = .visible
    @State private var selectedPage = 1
    
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
    let requestCounterTip = RequestCounterTip()
    var deviceType = DeviceInfo.shared.getDeviceType()
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
                AnalyticsManager.shared.logEvent(name: "HomeView_Appear")
                
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
            
            HStack(spacing: 15) {
                HStack {
                    
                    // Reload button
                    Button {
                        webView?.reload()
                    } label: {
                        Image(systemName: "arrow.counterclockwise.circle.fill")
                            .tint(.orange)
                            .font(.system(size: 22))
                    }
                    .padding(.horizontal, 3)
                    
                    // Go back button
                    Button {
                        webView?.goBack()
                    } label: {
                        Image(systemName: "arrowshape.turn.up.backward.fill")
                            .tint(.orange)
                            .font(.system(size: 22))
                    }
                    .disabled(!(webView?.canGoBack ?? false))
                    .padding(.horizontal, 3)
                    
                    // Go forward button
                    Button {
                        webView?.goForward()
                    } label: {
                        Image(systemName: "arrowshape.turn.up.right.fill")
                            .tint(.orange)
                            .font(.system(size: 22))
                    }
                    .disabled(!(webView?.canGoForward ?? false))
                    .padding(.horizontal, 3)
                }
                .frame(width: 150, height: 30)
                .background(Color.teal.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Show or hide tabbar
                Button {
                    if tabBarVisibility == .visible {
                        tabBarVisibility = .hidden
                    } else {
                        tabBarVisibility = .visible
                    }
                } label: {
                    Image(systemName: (tabBarVisibility == .visible) ? "eyeglasses" : "eyeglasses.slash")
                        .font(.system(size: 22))
                }
                
                // Request Counter
                WordRequestCounterView()
                    .onLoad {
                        requestManager.resetCountIfNeeded()
                    }
            }
            .padding(.horizontal)
        }
        .frame(height: 30)
        .clipShape(RoundedRectangle(cornerRadius: 5))
        .padding(.horizontal)
        .onAppear {
            AnalyticsManager.shared.logEvent(name: "WebView_Appear")
        }
        .onDisappear {
            AnalyticsManager.shared.logEvent(name: "WebView_Disappear")
        }
    }
    
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
                Text("Owl Reader")
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
                        TextField("", text: $urlString, prompt: Text(Localized.Enter_your_web_link).foregroundColor(.white.opacity(0.7)))
                            .foregroundColor(.white)
                            .onSubmit {
                                processingLink = true
                                AnalyticsManager.shared.logEvent(name: "HomeView_header_SearchButtonClick")
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
                        Text(Localized.Cancel)
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
                            // Navigation bar
                            navigationBarOnWebPage
                            BannerView()
                                .frame(height: 60)
                            
                            WebView(url: url, viewModel: viewModel, webView: $webView, didFinishLoadingThisURL: { link in vm.addURL(link: link, modelContext: modelContext)
                                urlToDisplay = link?.url.absoluteString ?? ""
                            }) { word in
                                print(word)
                                selectedWord = word
                                showingDefinition = true
                            }
                            .popover(isPresented: Binding(get: { showingDefinition }, set: { showingDefinition = $0 }),attachmentAnchor: .rect(.rect(CGRect(x: 30, y: 40, width: 320, height: 200))),arrowEdge: .bottom) {
                                if let word = selectedWord {
                                    DefinitionView(vm: DefinitionVM(selectedWord: word), width: deviceType == .pad ? 500 : nil, height: deviceType == .pad ? 450 : nil, isPopover: true)
                                        .presentationBackground(.thinMaterial)
                                        .presentationCornerRadius(15)
                                        .frame(maxWidth: deviceType == .pad ? 450 : 300, maxHeight: deviceType == .pad ? 1000 : 800)
                                        .presentationDetents([.large, .height(300)])
                                }
                            }
                        }
                        .toolbar{
                            TextField(Localized.Loading_url, text: $urlToDisplay, onCommit: {
                            })
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 300)
                        }
                    }
                    .toolbarBackground(tabBarVisibility, for: .tabBar)
                    .toolbarBackground(colorScheme == .light ? Color.white.opacity(0.7) : Color.black.opacity(0.7), for: .tabBar)
                }
            }
        }
    }
    private var breakingNews: some View {
        VStack(spacing: 5) {
            HStack {
                Text(Localized.Breaking_News)
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
                TabView(selection: $selectedPage) {
                    ForEach(0..<vm.headLines.count, id: \.self) { index in
                        HeadlineView(headline: vm.headLines[index], deviceType: deviceType) {
                            selectedHeadline = vm.headLines[index]
                        }
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .frame(height: deviceType == .pad ? 400 : 200)
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
                            // Navigation bar
                            navigationBarOnWebPage
                            BannerView()
                                .frame(height: 60)
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                            
                            WebView(url: URL(string: headline.url),viewModel: viewModel, webView: $webView, didFinishLoadingThisURL: { link in vm.addURL(link: link, modelContext: modelContext)
                                urlToDisplay = link?.url.absoluteString ?? ""
                            }) { word in
                                print(word)
                                selectedWord = word
                                showingDefinition = true
                            }
                            .popover(isPresented: Binding(get: { showingDefinition }, set: { showingDefinition = $0 }), attachmentAnchor: .rect(.rect(CGRect(x: 30, y: 40, width: 320, height: 200))), arrowEdge: .bottom) {
                                if let word = selectedWord {
                                    DefinitionView(vm: DefinitionVM(selectedWord: word), width: deviceType == .pad ? 500 : nil, height: deviceType == .pad ? 450 : nil, isPopover: true)
                                        .presentationBackground(.thickMaterial)
                                        .presentationCornerRadius(15)
                                        .frame(maxWidth: deviceType == .pad ? 450 : .infinity, maxHeight: deviceType == .pad ? 1000 : 800)
                                        .presentationDetents([.large, .height(300)])
                                }
                            }
                        }
                        .toolbar {
                            TextField(Localized.Loading_url, text: $urlToDisplay, onCommit: {
                            })
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 300)
                        }
                        .edgesIgnoringSafeArea(.all)
                    }
                    .toolbarBackground(tabBarVisibility, for: .tabBar)
                    .toolbarBackground(colorScheme == .light ? Color.white.opacity(0.7) : Color.black.opacity(0.7), for: .tabBar)
                }
                
                CustomPageControl(numberOfPages: vm.headLines.count, currentPage: $selectedPage)
                    .frame(height: UIScreen.main.bounds.height <= 812 && UIScreen.main.bounds.width <= 375 ? 12 : 23)
                
            case .failed:
                ZStack {
                    Color.gray.opacity(0.1)
                    ContentUnavailableView {
                        VStack {
                            Image("error")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                            Text(Localized.Error_loading_headlines)
                                .bold()
                        }
                    } description: {
                        Text(Localized.An_error_occurred_while_loading_headlines)
                    } actions: {
                        Button(Localized.Retry) {
                            Task {
                                await vm.fetchHeadlinesFromAPI(modelContext: modelContext)
                            }
                            AnalyticsManager.shared.logEvent(name: "HomeView_BreakingNews_HeadlineRetryButtonClick")
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
                
            case .rewarded:
                VStack {
                    Text("")
                }
            }
        }
    }
    private var shotcuts: some View {
        VStack(spacing: 5) {
            HStack {
                Text(Localized.Shortcuts)
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
                        
                        Text(Localized.Add_Edit_Link)
                            .foregroundColor(.primary.opacity(0.5))
                            .padding(12)
                    }
                    .padding(.vertical, 2)
                    .navigationDestination(isPresented: $showingAddLinkSheet) {
                        AddOrEditLinkView(photoPickerVM: addOrEditPhotoPickerVM)
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
                                // Navigation bar
                                navigationBarOnWebPage
                                BannerView()
                                    .frame(height: 60)
                                
                                WebView(url: url, viewModel: viewModel, webView: $webView, didFinishLoadingThisURL: { link in vm.addURL(link: link, modelContext: modelContext)
                                    urlToDisplay = link?.url.absoluteString ?? ""
                                }) { word in
                                    print(word)
                                    selectedWord = word
                                    showingDefinition = true
                                }
                                .popover(isPresented: Binding(get: { showingDefinition }, set: { showingDefinition = $0 }), attachmentAnchor: .rect(.rect(CGRect(x: 30, y: 40, width: 320, height: 200))), arrowEdge: .bottom) {
                                    if let word = selectedWord {
                                        DefinitionView(vm: DefinitionVM(selectedWord: word), width: deviceType == .pad ? 500 : nil, height: deviceType == .pad ? 450 : nil, isPopover: true)
                                            .presentationBackground(.thickMaterial)
                                            .presentationCornerRadius(15)
                                            .frame(maxWidth: deviceType == .pad ? 450 : .infinity, maxHeight: deviceType == .pad ? 1000 : 800)
                                            .presentationDetents([.large, .height(300)])
                                    }
                                }
                            }
                            .toolbar{
                                TextField(Localized.Loading_url, text: $urlToDisplay, onCommit: {
                                    
                                })
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 300)

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
                Text(Localized.Recently_Read + " " + "(\(vm.recentlyReadURLs.count))")
                    .font(Font.custom("DIN Condensed", size: 30))
                    .foregroundColor(.primary.opacity(0.8))
                    .bold()
                Spacer()
                if vm.recentlyReadURLs.count >= 2 {
                    Button(Localized.Clear_all) {
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
                Text(Localized.No_history)
                    .font(Font.custom("Avenir Next Condensed", size: 20))
                    .foregroundColor(.secondary)
                    .padding(40)
            } else {
                List {
                    ForEach(vm.recentlyReadURLs.reversed(), id: \.self) { link in
                        Button {
                            urlString = link.url.absoluteString
                            showingRecentlyReadWebPage = true
                            AnalyticsManager.shared.logEvent(name: "HomeView_RecentlyRead_HeadlineLinkClick")
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
                .frame(height: deviceType == .pad ? 400 : 200)
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
                        // Navigation bar
                        navigationBarOnWebPage
                        BannerView()
                            .frame(height: 60)
                        
                        WebView(url: url, viewModel: viewModel, webView: $webView, didFinishLoadingThisURL: { link in vm.addURL(link: link, modelContext: modelContext)
                            urlToDisplay = link?.url.absoluteString ?? ""
                        }) { word in
                            print(word)
                            selectedWord = word
                            showingDefinition = true
                        }
                        .popover(isPresented: Binding(get: { showingDefinition }, set: { showingDefinition = $0 }), attachmentAnchor: .rect(.rect(CGRect(x: 30, y: 40, width: 320, height: 200))),arrowEdge: .bottom) {
                            if let word = selectedWord {
                                DefinitionView(vm: DefinitionVM(selectedWord: word), width: deviceType == .pad ? 500 : nil, height: deviceType == .pad ? 450 : nil, isPopover: true)
                                    .presentationBackground(.thickMaterial)
                                    .presentationCornerRadius(15)
                                    .frame(maxWidth: deviceType == .pad ? 450 : .infinity, maxHeight: deviceType == .pad ? 1000 : 800)
                                    .presentationDetents([.large, .height(300)])
                            }
                        }
                    }
                    .toolbar{
                        TextField(Localized.Loading_url, text: $urlToDisplay, onCommit: {
                            
                        })
                        .frame(minWidth: 300)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
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
        .environmentObject(ReviewRequestManager())
        .modelContainer(for: [Link.self, Shortcut.self, Headline.self, Word.self, WordBook.self])
}
