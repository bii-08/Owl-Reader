//
//  ShotcutView.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/04/24.
//

import SwiftUI

struct ShortcutView: View {
    var webPageTitle: String
    var favicon: URL?
    var action: () -> ()
    var body: some View {
       
            Button {
                action()
            } label: {
                VStack {
                    if let icon = favicon {
                        AsyncImage(url: icon) { image in
                            image.image?.resizable()
                                .frame(width: 100, height: 100)
                                .padding(10)
                            
                        } 
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .shadow(radius: 3)
                    } else {
                        Image(systemName: "photo")
                            .frame(width: 100, height: 100)
                            .padding(10)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .shadow(radius: 3)
                    }
                    
                    Text("\(webPageTitle)")
                        .foregroundColor(.primary.opacity(0.5))
                        .padding(5)
                }
                
            }
    }
}

#Preview {
    ShortcutView(webPageTitle: "investopedia", favicon: URL(string: "https://www.investopedia.com/favicon.ico"), action: {})
}
