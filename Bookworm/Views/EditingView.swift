//
//  EditingView.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/04/29.
//

import SwiftUI

struct EditingView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var vm: HomeVM
    var link: Link
    var photoPikerVM: PhotoPickerVM
    
    @State private var editingTitle = ""
    @State private var editingURL = ""
    @State private var editingImage: UIImage?
    
    @State private var showingPhotoPiker = false
    @State private var showingAlert = false
    @State private var defaultURL: URL
    
    init(link: Link, photoPiker: PhotoPickerVM) {
        self.link = link
        self.photoPikerVM = photoPiker
        self.defaultURL = link.url
    }
    
    var body: some View {
        ZStack {
            Color("background").ignoresSafeArea()
            VStack {
                HStack {
                    Text("Editing shortcut")
                        .font(Font.custom("DIN Condensed", size: 25))
                    Spacer()
                }
                .padding(.horizontal)
                
                // Textfield : editing title
                TextField("", text: $editingTitle, prompt: Text("Add web page title").foregroundColor(.white.opacity(0.7))).padding(6)
                    .foregroundColor(.white)
                    .submitLabel(.done)
                    .background(RoundedRectangle(cornerRadius: 5).fill(Color("SearchBar").opacity(0.35)))
                    .padding(.horizontal)
                    .disabled(vm.showingAlert)
                
                // Textfield : editing URL
                TextField("", text: $editingURL, prompt: Text("Add your web link").foregroundColor(.white.opacity(0.7))).padding(6)
                    .textInputAutocapitalization(.never)
                    .foregroundColor(.white)
                    .submitLabel(.done)
                    .background(RoundedRectangle(cornerRadius: 5).fill(Color("SearchBar").opacity(0.35)))
                    .padding(.horizontal)
                    .disabled(vm.showingAlert)
                
                if let editingImage {
                    VStack {
                        Image(uiImage: editingImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 200, height: 200)
                            .cornerRadius(10)
                        Button("Change Image") {
                            showingPhotoPiker = true
                            photoPikerVM.selectedImage = editingImage
                        }
                        .foregroundColor(.saveChangesButton)
                        
                    }
                    
                } else {
                    Button("Add Image") {
                        showingPhotoPiker = true
                        photoPikerVM.selectedImage = editingImage
                    }
                }
                
                Spacer()
                
                // Save changes Button
                Button {
                    let filtered = vm.savedShortcuts.filter({ $0 != link })
                    vm.isTitleValid = HomeVM.isTitleValid(title: editingTitle)
                    vm.isTitleAlreadyExists = vm.isTitleAlreadyExists(title: editingTitle, stored: filtered)
                    vm.isValidURL = vm.validateURL(urlString: editingURL)
                    vm.isUrlAlreadyExists = vm.isUrlAlreadyExists(urlString: editingURL, stored: filtered)
                    
                    if vm.isTitleValid && !vm.isTitleAlreadyExists && vm.isValidURL && !vm.isUrlAlreadyExists {
                        vm.updateLink(linkNeedToUpdate: link, newLink: Link(url: URL(string: editingURL) ?? defaultURL, favicon: editingImage, webPageTitle: editingTitle))
                        dismiss()
                    } else {
                        showingAlert = true
                    }
                } label: {
                    Text("Save changes")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(10)
                        .background(RoundedRectangle(cornerRadius: 5).fill(!showingAlert ? Color(.orange.opacity(0.8)) : .gray))
                }
                .padding(.horizontal, 50)
                .disabled(showingAlert)
            }
            .navigationDestination(isPresented: $showingPhotoPiker) {
                PhotoPickerView(vm: photoPikerVM) {
                    self.editingImage = photoPikerVM.selectedImage
                }
            }
            
            if showingAlert {
                
                AlertView(title: !vm.isTitleValid || !vm.isValidURL ? "Invalid" : "Error", message: !vm.isTitleValid || !vm.isValidURL ? "Please ensure your link or title is correct." : "This title or link is already exists.", primaryButtonTitle: "Got it") {
                    withAnimation {
                        showingAlert = false
                    }
                }
                .zIndex(5)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                
            }
        }
        .onAppear {
            editingTitle = link.webPageTitle
            editingURL = link.url.absoluteString
            editingImage = link.favicon
        }
    }
}

#Preview {
    EditingView(link: Link(url: URL(string: "https://www.investopedia.com")!, favicon: UIImage(named: "investopedia"), webPageTitle: "Investopedia"), photoPiker: PhotoPickerVM())
        .environmentObject(HomeVM())
}
