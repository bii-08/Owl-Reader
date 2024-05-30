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
                AsyncImage(url: URL(string: headline.urlToImage)) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: UIScreen.main.bounds.height <= 812 && UIScreen.main.bounds.width <= 375 ? 350 : 380, maxHeight: UIScreen.main.bounds.height <= 812 && UIScreen.main.bounds.width <= 375 ? 180 : 200)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .shadow(radius: 1)
                    } else {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.gray.opacity(0.5))
                            .frame(maxWidth: UIScreen.main.bounds.height <= 812 && UIScreen.main.bounds.width <= 375 ? 350 : 380, maxHeight: UIScreen.main.bounds.height <= 812 && UIScreen.main.bounds.width <= 375 ? 180 : 200)
                            .shadow(radius: 1)
                    }
                    
                }
                .overlay(
                    HStack {
                        Spacer()
                        RoundedRectangle(cornerRadius: 0)
                            .fill(Color("headlineRounded"))
                            .frame(maxWidth: UIScreen.main.bounds.height <= 812 && UIScreen.main.bounds.width <= 375 ? 190 : 200, maxHeight: UIScreen.main.bounds.height <= 812 && UIScreen.main.bounds.width <= 375 ? 180 : 200)
                            .clipShape(
                                .rect(
                                    topLeadingRadius: 0,
                                    bottomLeadingRadius: 0,
                                    bottomTrailingRadius: 20,
                                    topTrailingRadius: 20
                                )
                            )
                    }
                    .overlay(
                        VStack {
                            
                            HStack {
                                Spacer()
                                Text(headline.source?.name ?? "")
                                    .font(.headline)
//                                    .multilineTextAlignment(.leading)
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: UIScreen.main.bounds.height <= 812 && UIScreen.main.bounds.width <= 375 ? 190 : 200, maxHeight: UIScreen.main.bounds.height <= 812 && UIScreen.main.bounds.width <= 375 ? 180 : 190)
                                    .background(Rectangle().fill(Color("headlineTitleRounded")))
                                    .clipShape(
                                        .rect(
                                            topLeadingRadius: 0,
                                            bottomLeadingRadius: 0,
                                            bottomTrailingRadius: 0,
                                            topTrailingRadius: 20
                                        )
                                    )
                            }
                            .overlay() {
                                HStack {
                                    Text("")
                                        .padding(UIScreen.main.bounds.height <= 812 && UIScreen.main.bounds.width <= 375 ? 1 : 8)
                                    Image(headline.source?.name ?? "")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 20, height: 20)
                                        .cornerRadius(3)
                                }
                                .padding()
                            }
//                            Spacer()
                            VStack {
                                HStack {
                                    Spacer()
                                    Text(headline.title)
                                        .font(.headline)
                                        .multilineTextAlignment(.leading)
                                        .frame(width: UIScreen.main.bounds.height <= 812 && UIScreen.main.bounds.width <= 375 ? 160 : 170, height: 100)
                                        .foregroundColor(.primary)
                                }
                                .padding()
                            }
                        }
                    )
                )
                
            }
        }
    }
}

#Preview {
    HeadlineView(headline: Headline(source: Source(name: "BBC News"),title: "BBC Gaza reporter: My struggle to keep family safe while covering the war", url: "https://www.bbc.co.uk/news/world-middle-east-68906903", urlToImage: "https://ichef.bbci.co.uk/news/1024/branded_news/977D/production/_133218783_razan_hug.jpg"), action: {})
}
