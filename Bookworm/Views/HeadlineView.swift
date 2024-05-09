//
//  HeadlineView.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/04/30.
//

import SwiftUI

struct HeadlineView: View {
    
    var headline: Headline
    var action: () -> ()
    
    var body: some View {
        
        Button {
           action()
        } label: {
            ZStack(alignment: .bottom) {
                AsyncImage(url: URL(string: headline.urlToImage)) { image in
                    image.image?.resizable()
                        .scaledToFill()
                        .frame(maxWidth: 380, maxHeight: 230)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(radius: 5)
                }
                Text(headline.title)
                    .font(.title3)
                    .frame(width: 350)
                    .foregroundColor(.white)
                    .background(.black.opacity(0.4))
                    .padding()
            }
        }
    }
}

#Preview {
    HeadlineView(headline: Headline(title: "BBC Gaza reporter: My struggle to keep family safe while covering the war", url: "https://www.bbc.co.uk/news/world-middle-east-68906903", urlToImage: "https://ichef.bbci.co.uk/news/1024/branded_news/977D/production/_133218783_razan_hug.jpg"), action: {})
}
