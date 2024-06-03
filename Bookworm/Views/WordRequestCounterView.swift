//
//  WordRequestCounterView.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/06/03.
//

import SwiftUI

struct WordRequestCounterView: View {
    @ObservedObject var requestManager = RequestManager.shared
    var body: some View {
        ZStack {
            Image("Counter")
                .resizable()
                .scaledToFit()
                .frame(width: 70, height: 30)
                .overlay {
                    HStack {
                        Text("")
                            .padding(.horizontal, 15)
                        Text("\(requestManager.requestRemaning)")
                            .font(Font.custom("Marker Felt", size: 20))
                            .frame(width: 120)
                    }
                }
        }
    }
}

#Preview {
    WordRequestCounterView()
}
