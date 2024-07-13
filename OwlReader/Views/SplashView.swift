//
//  SlashView.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/06/08.
//

import SwiftUI
import AdSupport
import AppTrackingTransparency
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

struct SplashView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var isActive = false
    @State private var size = 0.5
    @State private var opacity = 0.95
    var body: some View {
        if isActive {
            TabBar()
        } else {
            ZStack {
                Color("background").ignoresSafeArea()
                VStack {
                    if colorScheme == .light {
                        Image("Owl Reader")
                            .resizable()
                            .frame(width: 120,height: 120)
                            .cornerRadius(10)
                    } else {
                        Image("Owl Reader_dark")
                            .resizable()
                            .frame(width: 120,height: 120)
                            .cornerRadius(10)
                    }
                }
                .scaleEffect(size)
                .opacity(opacity)
                .onAppear {
                    withAnimation(.easeIn(duration: 1)) {
                        self.size = 0.9
                        self.opacity = 1.0
                    }
                }
            }
            .onAppear {
                withAnimation(.easeInOut){
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                        self.isActive = true
                    }
                }
            }
        }
    }
}

#Preview {
    SplashView()
}
