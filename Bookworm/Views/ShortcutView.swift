//
//  ShotcutView.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/04/24.
//

import SwiftUI

struct ShortcutView: View {
    
    var webPageTitle: String
    var favicon: UIImage?
    var action: () -> ()
    
    var body: some View {
        Button {
            action()
        } label: {
            // Webpage icon
            VStack {
                if let icon = favicon {
                    Image(uiImage: icon)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 70, height: 70)
                        .cornerRadius(10)
                } else {
                    Image(systemName: "photo")
                        .frame(width: 70, height: 70)
//                        .padding(10)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .shadow(radius: 1)
                }
                // Webpage title
                Text("\(webPageTitle)")
                    .font(Font.custom("Avenir Next Condensed", size: 20))
                    .frame(width: 100)
                    .lineLimit(1)
                    .foregroundColor(.primary.opacity(0.5))
                    .padding(5)
            }
        }
    }
}

#Preview {
    ShortcutView(webPageTitle: "investopedia", favicon: UIImage(named: "investopedia"), action: {})
}
