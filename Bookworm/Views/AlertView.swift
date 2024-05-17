//
//  AlertView.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/04/29.
//

import SwiftUI

struct AlertView: View {
    var title: String
    var message: String
    var primaryButtonTitle: String
    var secondaryButtonTitle: String?
    var action1: () -> ()
    var action2: (() -> ())?
    @State private var offset: CGFloat = 0
    
    var body: some View {
        ZStack {
            VStack {
                Text(title)
                    .font(Font.custom("DIN Condensed", size: 30))
                    .bold()
                    .padding()
                    .foregroundColor(.primary)
                
                Text(message)
                    .font(.custom("DIN Condensed", size: 20))
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                Spacer()
  
                HStack {
                    if let action2 {
                        Button {
                            action2()
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .frame(width: 150, height: 42)
                                    .foregroundColor(Color.blue.opacity(0.5))
                                Text(secondaryButtonTitle ?? "")
                                    .font(.custom("DIN Condensed", size: 20))
                                    .foregroundColor(.white)
                                   
                            }
                            .padding()
                        }
                    }
                    
                    Button {
                        action1()
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .frame(width: 100, height: 42)
                                .foregroundColor(Color.orange.opacity(0.5))
                            Text(primaryButtonTitle)
                                .font(.custom("DIN Condensed", size: 20))
                                .foregroundColor(.white)
                               
                        }
                        .padding()
                    }
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding(5)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .shadow(radius: 5)
            .padding(30)
        }
    }
}

#Preview {
    AlertView(title: "Invalid", message: "Please enter a valid URL (e.g., https://example.com) or title.", primaryButtonTitle: "Got it", action1: {})
}
