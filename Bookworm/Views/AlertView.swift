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
    var action1: () -> ()
    
    @State private var offset: CGFloat = 0
    
    var body: some View {
        ZStack {
            VStack {
                Text(title)
                    .font(Font.custom("DIN Condensed", size: 30))
//                    .font(.title)
                    .bold()
                    .padding()
                    .foregroundColor(.primary)
                
                Text(message)
                    .font(.custom("DIN Condensed", size: 20))
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                Spacer()
  
                HStack {
                    Button {
                        action1()
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .frame(width: 120, height: 50)
                                .foregroundColor(Color.blue.opacity(0.5))
                            Text(primaryButtonTitle)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .padding()
                        }
                        .padding()
                    }
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding(5)
            .background(.ultraThickMaterial.opacity(0.8))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .shadow(radius: 2)
            .padding(30)
        }
    }
}

#Preview {
    AlertView(title: "Invalid", message: "Please enter a valid URL (e.g., https://example.com) or title.", primaryButtonTitle: "Got it", action1: {})
}
