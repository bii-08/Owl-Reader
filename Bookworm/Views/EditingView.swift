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
    @State private var editingTitle: String
    @State private var editingURL: String
    @State private var editingImage: UIImage?
    @State private var showingPhotoPiker = false
    @State private var showingAlert = false
    
    init(link: Link, photoPiker: PhotoPickerVM) {
        self.link = link
        self.photoPikerVM = photoPiker
        self._editingTitle = State(initialValue: link.webPageTitle)
        self._editingURL = State(initialValue: link.url.absoluteString)
        self._editingImage = State(initialValue: link.favicon)
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
                    if vm.isEditingInputValid(link: Link(url: URL(string: editingURL)!, favicon: editingImage, webPageTitle: editingTitle)) {
                        vm.updateLink(link: Link(url: URL(string: editingURL)!, favicon: editingImage, webPageTitle: editingTitle))
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
                AlertView(title: "Error", message: "", primaryButtonTitle: "Got it") {
                    withAnimation {
                        showingAlert = false
                    }
                }
                .zIndex(5)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }
}

#Preview {
    EditingView(link: Link(url: URL(string: "https://www.investopedia.com")!, favicon: UIImage(named: "investopedia"), webPageTitle: "Investopedia"), photoPiker: PhotoPickerVM())
        .environmentObject(HomeVM())
}
