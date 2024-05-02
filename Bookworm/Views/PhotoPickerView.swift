//
//  PhotoPickerView.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/05/01.
//

import SwiftUI
import PhotosUI

struct PhotoPickerView: View {
    @StateObject var vm: PhotoPickerVM
    var action: () -> ()
    var body: some View {
        ZStack {
            Color("background").ignoresSafeArea()
            VStack(spacing: 20) {
                PhotosPicker(selection: $vm.imageSelection, matching: .images) {
                    
                    Text("Upload your webpage's icon")
                        .foregroundColor(.white)
                        .frame(width: 360, height: 40)
                        .background(Color("uploadImageButton"))
                        .cornerRadius(5)
                }
                
                if let image = vm.selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 200, height: 200)
                        .cornerRadius(10)
                } else {
                    Image(systemName: "photo")
                        .scaleEffect(8)
                        .foregroundColor(.gray)
                        .frame(width: 200, height: 200)
                }
                
            }
            .onDisappear {
                action()
            }
        }
    }
}

#Preview {
    PhotoPickerView(vm: PhotoPickerVM(), action: {})
}
