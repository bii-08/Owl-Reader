//
//  AddLinkView.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/04/24.
//

import SwiftUI

struct AddLinkView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var vm: HomeVM
    @State private var urlString = ""
    @State private var webPageTitle = ""
    
    var photoPikerVM: PhotoPickerVM
    
    @State var selectedPage: Link?
    var body: some View {
        ZStack {
            Color("background").ignoresSafeArea()
            VStack {
                
                //Shortcut List
                HStack {
                    Text("Shortcut list")
                        .font(Font.custom("DIN Condensed", size: 25))
                    Spacer()
                }
                .padding(.horizontal)
                
                if vm.savedShortcuts.isEmpty {
                        Text("No Item")
                            .font(Font.custom("Avenir Next Condensed", size: 20))
                            .foregroundColor(.secondary)
                            .padding(40)
                } else {
                    // Web pages List
                    List(vm.savedShortcuts, id: \.self) { page in
                        Text(page.webPageTitle)
                            .foregroundColor(.secondary)
                            .listRowBackground(Color("background"))
                            .swipeActions(allowsFullSwipe: false) {
                                // Delete Button
                                Button(role: .destructive) {
                                    if let index = vm.savedShortcuts.firstIndex(where: { $0.url == page.url }) {
                                        vm.savedShortcuts.remove(at: index)
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                .tint(.red)
                                
                                // Edit Button
                                Button {
                                    withAnimation {
                                        selectedPage = page
                                    }
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                .tint(.orange)
                            }
                    }
                    .navigationDestination(item: $selectedPage, destination: { page in
                        EditingView(link: page, photoPiker: PhotoPickerVM())
                    })
                    .listStyle(.plain)
                }

                // Add new shortcut Section
                VStack {
                    Spacer()
                    HStack {
                        Text("Add new shortcut")
                            .font(Font.custom("DIN Condensed", size: 25))
                        Spacer()
                    }
                    .padding(.horizontal)
                }
                // Textfield
                VStack {
                    Spacer()
                    // Page title
                    TextField("", text: $webPageTitle, prompt: Text("Page title").foregroundColor(.white.opacity(0.7))).padding(6)
                        .onChange(of: webPageTitle) { oldValue, newValue in
                            vm.isTitleValid = HomeVM.isTitleValid(title: newValue)
                            vm.isTitleAlreadyExists = vm.isTitleAlreadyExists(title: newValue, stored: vm.savedShortcuts)
                        }
                        .foregroundColor(.white)
                        .submitLabel(.done)
                        .background(RoundedRectangle(cornerRadius: 5).fill(Color("SearchBar").opacity(0.35)))
                        .padding(.horizontal)
                        .disabled(vm.showingAlert)
                    
                    // Weblink
                    TextField("", text: $urlString, prompt: Text("Your web link").foregroundColor(.white.opacity(0.7))).padding(6)
                        .onChange(of: urlString) { oldValue, newValue in
                            vm.isValidURL = vm.validateURL(urlString: newValue)
                            vm.isUrlAlreadyExists = vm.isUrlAlreadyExists(urlString: newValue, stored: vm.savedShortcuts)
                        }
                        .textInputAutocapitalization(.never)
                        .foregroundColor(.white)
                        .submitLabel(.done)
                        .background(RoundedRectangle(cornerRadius: 5).fill(Color("SearchBar").opacity(0.35)))
                        .padding(.horizontal)
                        .disabled(vm.showingAlert)
                    
                    // Photo Picker
                    PhotoPickerView(vm: photoPikerVM) {
                        
                    }
                    .disabled(vm.showingAlert)
                }
                
                HStack {
                    // Add button
                    Button {
                        if vm.isValidURL && !vm.isUrlAlreadyExists && vm.isTitleValid && !vm.isTitleAlreadyExists {
                            print("valid")
                            vm.addLink(newLink: Link(url: URL(string: urlString)!, favicon: photoPikerVM.selectedImage?.pngData(), webPageTitle: webPageTitle))
                            
                            urlString = ""
                            webPageTitle = ""
                            photoPikerVM.clear()
                            
                        } else {
                            print("invalid")
                            withAnimation {
                                vm.showingAlert = true
                            }
                        }
                    } label: {
                        Text("Add")
                            .foregroundColor(.white)
                            .frame(width: 100, height: 40)
                            .background(RoundedRectangle(cornerRadius: 5).fill(vm.showingAlert ? .gray : .orange.opacity(0.8)))
                    }
                    .disabled(vm.showingAlert)
                    
                    // Clear button
                    Button {
                        urlString = ""
                        webPageTitle = ""
                        photoPikerVM.clear()
                    } label: {
                        Text("Clear")
                            .foregroundColor(.white)
                            .frame(width: 100, height: 40)
                            .background(RoundedRectangle(cornerRadius: 5).fill(vm.showingAlert ? .gray : .clearButton.opacity(0.5)))
                    }
                    .disabled(vm.showingAlert)
                }
            }
            
            if vm.showingAlert {
                AlertView(title: !vm.isTitleValid || !vm.isValidURL ? "Invalid" : "Error", message: !vm.isTitleValid || !vm.isValidURL ? "Please ensure your link or title is correct." : "This title or link is already exists.", primaryButtonTitle: "Got it") {
                    withAnimation {
                        vm.showingAlert = false
                    }
                }
                .zIndex(5)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }
}

#Preview {
    
    AddLinkView(photoPikerVM: PhotoPickerVM())
        .environmentObject(HomeVM())
}
