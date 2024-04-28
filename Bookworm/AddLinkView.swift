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
    
    var body: some View {
            VStack {
                VStack {
                    TextField("", text: $webPageTitle, prompt: Text("Add web page title here").foregroundColor(.white.opacity(0.7))).padding()
                        .foregroundColor(.white)
                        .submitLabel(.done)
                        .background(RoundedRectangle(cornerRadius: 5).fill(Color("SearchBar").opacity(0.4)))
                        .padding(.horizontal)
                    TextField("", text: $urlString, prompt: Text("Add your web link here").foregroundColor(.white.opacity(0.7))).padding()
                        .onChange(of: urlString) { oldValue, newValue in
//                            vm.validateURL(urlString: urlString)
                        }
                        .textCase(.lowercase)
                        .foregroundColor(.white)
                        .submitLabel(.done)
                        .background(RoundedRectangle(cornerRadius: 5).fill(Color("SearchBar").opacity(0.4)))
                        .padding(.horizontal)
                }
                
                
                HStack {
                    // Add link button
                    Button {
                        vm.addLink(newLink: Link(url: URL(string: urlString)!, webPageTitle: webPageTitle))
                        dismiss()
                    } label: {
                        Text("Add")
                            .foregroundColor(.white)
                            .frame(width: 100, height: 40)
                            .background(RoundedRectangle(cornerRadius: 10))
                    }
                    Button {
                        urlString = ""
                        webPageTitle = ""
                    } label: {
                        Text("Clear")
                            .foregroundColor(.white)
                            .frame(width: 100, height: 40)
                            .background(RoundedRectangle(cornerRadius: 10))
                    }
                    
                }
                List(vm.savedShortcuts, id: \.self) { page in
                    Text(page.webPageTitle)
                }
                .listStyle(.plain)
            }
        
    }
}

#Preview {
    AddLinkView()
        .environmentObject(HomeVM())
}
