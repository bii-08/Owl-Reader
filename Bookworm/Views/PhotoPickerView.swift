//
//  PhotoPickerView.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/05/01.
//

import SwiftUI
import PhotosUI

struct PhotoPickerView: View {
    @ObservedObject var vm: PhotoPickerVM
    var action: () -> ()
    var body: some View {
            VStack(spacing: 5) {
                PhotosPicker(selection: $vm.imageSelection, matching: .images) {
                    Text(Localized.Upload_your_webpage_icon)
                        .foregroundColor(.white)
                        .padding()
                        .frame(height: 35)
                        .background(Color.brown)
                        .cornerRadius(5)
                }
                
                if let image = vm.selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .cornerRadius(10)
                } else {
                    Image(systemName: "photo")
                        .scaleEffect(5)
                        .foregroundColor(.gray)
                        .frame(width: 50, height: 90)
                }
            }
            .onDisappear {
                action()
            }
    }
}

#Preview {
    PhotoPickerView(vm: PhotoPickerVM(), action: {})
}
