//
//  PhotoPickerVM.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/05/01.
//

import SwiftUI
import PhotosUI

@MainActor
final class PhotoPickerVM: ObservableObject {
    @Published var selectedImage: UIImage? = nil
    @Published var imageSelection: PhotosPickerItem? = nil {
        didSet {
            setImage(from: imageSelection)
        }
    }
    
    // FUNCTION: to covert the image from PhothoPicker with the type of 'PhotosPickerItem' to UIImage and set it into selectedImage to display
    private func setImage(from selection: PhotosPickerItem?) {
        guard let selection else { return }
        
        Task {
            do {
                let data = try? await selection.loadTransferable(type: Data.self)
                guard let data, let uiImage = UIImage(data: data) else {
                    throw URLError(.badServerResponse)
                }
                selectedImage = uiImage
            } catch {
                print(error)
            }
        }
    }
    
    // FUNCTION: to clear chosen image when needed
    func clear() {
        imageSelection = nil
        selectedImage = nil
    }
}
