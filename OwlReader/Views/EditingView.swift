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
    @FocusState private var isTextFieldFocused: Bool
    let swipeActionTip: SwipeActionInAddOrEditLinkTip
    
    init(link: Shortcut, photoPiker: PhotoPickerVM, swipeActionTip: SwipeActionInAddOrEditLinkTip) {
        self.link = link
        self.photoPikerVM = photoPiker
        self.swipeActionTip = swipeActionTip
        self.defaultURL = link.url
    }
    
    var body: some View {
        ZStack {
            Color("background").ignoresSafeArea()
            VStack {
                HStack {
                    Text(Localized.Editing_shortcut)
                        .font(Font.custom("DIN Condensed", size: 25))
                    Spacer()
                }
                .padding(.horizontal)
                
                // Textfield : editing title
                TextField("", text: $editingTitle, prompt: Text(Localized.Add_web_page_title).foregroundColor(.white.opacity(0.7))).padding(6)
                    .foregroundColor(.white)
                    .submitLabel(.done)
                    .background(RoundedRectangle(cornerRadius: 5).fill(Color("SearchBar").opacity(0.35)))
                    .padding(.horizontal)
                    .disabled(vm.showingAlert)
                    .focused($isTextFieldFocused)
                
                // Textfield : editing URL
                TextField("", text: $editingURL, prompt: Text(Localized.Add_your_web_link).foregroundColor(.white.opacity(0.7))).padding(6)
                    .textInputAutocapitalization(.never)
                    .foregroundColor(.white)
                    .submitLabel(.done)
                    .background(RoundedRectangle(cornerRadius: 5).fill(Color("SearchBar").opacity(0.35)))
                    .padding(.horizontal)
                    .disabled(vm.showingAlert)
                    .focused($isTextFieldFocused)
                
                if let editingImage {
                    VStack {
                        Image(uiImage: editingImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 200, height: 200)
                            .cornerRadius(10)
                        Button(Localized.Change_Image) {
                            isTextFieldFocused = false
                            showingPhotoPiker = true
                            photoPikerVM.selectedImage = editingImage
                        }
                        .foregroundColor(.saveChangesButton)
                    }
                    
                } else {
                    Button(Localized.Add_Image) {
                        isTextFieldFocused = false
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
                        swipeActionTip.invalidate(reason: .actionPerformed)
                        dismiss()
                    } else {
                        showingAlert = true
                    }
                } label: {
                    Text(Localized.Save_changes)
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
                AlertView(title: !vm.isTitleValid || !vm.isValidURL ? Localized.Invalid : Localized.Error, message: !vm.isTitleValid || !vm.isValidURL ? Localized.Please_ensure_your_link_or_title_is_correct : Localized.This_title_or_link_is_already_exists, primaryButtonTitle: Localized.Got_it) {
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
    EditingView(link: Shortcut(url: URL(string: "https://www.investopedia.com")!, favicon: UIImage(named: "investopedia")?.pngData(), webPageTitle: "Investopedia"), photoPiker: PhotoPickerVM(), swipeActionTip: SwipeActionInAddOrEditLinkTip())
        .environmentObject(HomeVM())
}
