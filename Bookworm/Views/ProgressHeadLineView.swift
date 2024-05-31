//
//  ProgressHeadLineView.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/05/31.
//

import SwiftUI

struct ProgressHeadLineView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.gray.opacity(0.5))
            .frame(width: UIScreen.main.bounds.height <= 812 && UIScreen.main.bounds.width <= 375 ? 350 : 380, height: UIScreen.main.bounds.height <= 812 && UIScreen.main.bounds.width <= 375 ? 180 : 200)
            .shadow(radius: 1)
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
                                Text("The New Yorker")
                                    .redacted(reason: .placeholder)
                                    .font(.headline)
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
                                    Image("TechCrunch")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 20, height: 20)
                                        .cornerRadius(3)
                                        .redacted(reason: .placeholder)
                                }
                                .padding()
                            }
                            VStack {
                                HStack {
                                    Spacer()
                                    Text("The evidence which may decide Trump's fate at trial")
                                        .redacted(reason: .placeholder)
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


#Preview {
    ProgressHeadLineView()
}
