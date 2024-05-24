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
                        .frame(maxWidth: UIScreen.main.bounds.height <= 812 && UIScreen.main.bounds.width <= 375 ? 350 : 380, maxHeight: UIScreen.main.bounds.height <= 812 && UIScreen.main.bounds.width <= 375 ? 180 : 200)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(radius: 5)
                }
                Text(headline.title)
                    .font(.headline)
                    .frame(width: UIScreen.main.bounds.height <= 812 && UIScreen.main.bounds.width <= 375 ? 320 : 350)
                    .foregroundColor(.white)
                    .background(.black.opacity(0.4))
                    .cornerRadius(5)
                    .padding()
            }
        }
    }
}

#Preview {
    HeadlineView(headline: Headline(title: "BBC Gaza reporter: My struggle to keep family safe while covering the war", url: "https://www.bbc.co.uk/news/world-middle-east-68906903", urlToImage: "https://ichef.bbci.co.uk/news/1024/branded_news/977D/production/_133218783_razan_hug.jpg"), action: {})
}
