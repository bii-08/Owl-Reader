//
//  AddLinkView.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/04/24.
//

import SwiftUI
import SwiftData

struct AddOrEditLinkView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var vm: HomeVM
    @State private var urlString = ""
    @State private var webPageTitle = ""
    
    @ObservedObject var photoPickerVM: PhotoPickerVM
    @State var selectedPage: Shortcut?
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        ZStack {
            Color("background").ignoresSafeArea()
            ScrollView {
                VStack {
                    //Shortcut List
                    HStack {
                        Text("Shortcut list")
                            .font(Font.custom("DIN Condensed", size: 25))
                        Spacer()
                    }
                    .padding(.horizontal)
                    if !vm.savedShortcuts.isEmpty {
                        HStack {
                            Text("※ swipe to edit or delete wordbook's name")
                                .font(Font.custom("Apple SD Gothic Neo", size: 15))
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                    
                    if vm.savedShortcuts.isEmpty {
                        Text("No Item")
                            .font(Font.custom("Avenir Next Condensed", size: 20))
                            .padding(40)
                            .foregroundColor(.secondary)
                    } else {
                        // Web pages List
                        List(vm.savedShortcuts, id: \.self) { page in
                            Text(page.webPageTitle)
                                .foregroundColor(.primary)
                                .listRowSeparator(.hidden)
                                .listRowBackground(
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(Color.clear)
                                        .padding(.vertical, 2)
                                        .padding(.horizontal, 10)
                                )
                                .swipeActions(allowsFullSwipe: false) {
                                    // Delete Button
                                    Button(role: .destructive) {
                                        if let index = vm.savedShortcuts.firstIndex(where: { $0.url == page.url }) {
                                            //                                        vm.savedShortcuts.remove(at: index)
                                            modelContext.delete(vm.savedShortcuts[index])
                                            vm.fetchShortcuts(modelContext: modelContext)
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
                        .onAppear {
                            vm.fetchShortcuts(modelContext: modelContext)
                        }
                        .navigationDestination(item: $selectedPage, destination: { page in
                            EditingView(link: page, photoPiker: PhotoPickerVM())
                        })
                        .frame(height: 250)
                        .scrollIndicators(.visible)
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray.opacity(0.1))
                                .padding(.horizontal, 10)
                        )
                    }
                    
                    HStack {
                        Text("Add new shortcut")
                            .font(Font.custom("DIN Condensed", size: 25))
                        Spacer()
                    }
                    .padding(.horizontal)
                    
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
                        .focused($isTextFieldFocused)
                    
                    
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
                        .focused($isTextFieldFocused)
                    
                    // Photo Picker
                    PhotoPickerView(vm: photoPickerVM) {
                        isTextFieldFocused = false
                    }
                    .disabled(vm.showingAlert)
                    
                    HStack {
                        // Add button
                        Button {
                            if vm.isValidURL && !vm.isUrlAlreadyExists && vm.isTitleValid && !vm.isTitleAlreadyExists {
                                print("valid")
                                vm.addLink(newShortcut: Shortcut(url: URL(string: urlString)!, favicon: photoPickerVM.selectedImage?.pngData(), webPageTitle: webPageTitle), modelContext: modelContext)
                                vm.fetchShortcuts(modelContext: modelContext)
                                
                                urlString = ""
                                webPageTitle = ""
                                photoPickerVM.clear()
                                
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
                        .padding(.vertical, 10)
                        
                        // Clear button
                        Button {
                            urlString = ""
                            webPageTitle = ""
                            photoPickerVM.clear()
                            isTextFieldFocused = false
                        } label: {
                            Text("Clear")
                                .foregroundColor(.white)
                                .frame(width: 100, height: 40)
                                .background(RoundedRectangle(cornerRadius: 5).fill(vm.showingAlert ? .gray : .clearButton.opacity(0.5)))
                        }
                        .disabled(vm.showingAlert)
                        .padding(.vertical, 10)
                    }
                    Spacer()
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
    
    AddOrEditLinkView(photoPickerVM: PhotoPickerVM())
        .environmentObject(HomeVM())
        .modelContainer(for: [Shortcut.self])
}
