//
//  RewardedView.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/06/03.
//

import SwiftUI

struct RewardedView: View {
    @Environment(\.colorScheme) private var colorScheme
    var action: () -> ()
    var body: some View {
        ZStack {
            Image(colorScheme == .light ? "sunBurst" : "sunBurst_blue")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack {
                
                Image("reward icon")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                Image("10 Words Rewarded")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 80)
            }
            .overlay {
                VStack {
                    Spacer()
                    Text("")
                        .padding(.vertical, 120)
                    Button {
                        action()
                    } label: {
                        Image(colorScheme == .light ? "TapToContinue_Light" : "Tap To Continue_Dark")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 30)
                    }
                }
                
            }
             
            
        }
    
    }
}

#Preview {
    RewardedView(action: {})
}
