//
//  EditingView.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/04/29.
//

import SwiftUI
import SwiftData

struct EditingView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var vm: HomeVM
    @Bindable var link: Shortcut
    
    var photoPikerVM: PhotoPickerVM
    
    @State private var editingTitle = ""
    @State private var editingURL = ""
    @State private var editingImage: UIImage?
    
    @State private var showingPhotoPiker = false
    @State private var showingAlert = false
    @State private var defaultURL: URL
    
    init(link: Shortcut, photoPiker: PhotoPickerVM) {
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
                        link.url = URL(string: editingURL) ?? defaultURL
                        link.favicon = editingImage?.pngData()
                        link.webPageTitle = editingTitle
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
                .padding(.vertical, 25)
                .disabled(showingAlert)
            }
            .navigationDestination(isPresented: $showingPhotoPiker) {
                ZStack {
                    Color("background").ignoresSafeArea()
                    PhotoPickerView(vm: photoPikerVM) {
                        self.editingImage = photoPikerVM.selectedImage
                    }
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
        .onLoad {
            editingTitle = link.webPageTitle
            editingURL = link.url.absoluteString
            editingImage = UIImage(data: link.favicon ?? Data())
        }
    }
}

#Preview {
    EditingView(link: Shortcut(url: URL(string: "https://www.investopedia.com")!, favicon: UIImage(named: "investopedia")?.pngData(), webPageTitle: "Investopedia"), photoPiker: PhotoPickerVM())
        .environmentObject(HomeVM())
}
