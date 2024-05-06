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
    
    func clear() {
        imageSelection = nil
        selectedImage = nil
    }
}
