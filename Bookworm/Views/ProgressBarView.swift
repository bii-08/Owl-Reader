//
//  ProgressBarView.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/05/21.
//

import SwiftUI

struct ProgressBarView: View {
    @Binding var progress: Double

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(Color.gray)
                    .opacity(0.3)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                Rectangle()
                    .foregroundColor(Color.blue)
                    .frame(width: geometry.size.width * CGFloat((self.progress)),
                           height: geometry.size.height)
                    .animation(.linear, value: progress)
            }
        }
    }
}

//#Preview {
//    ProgressBarView()
//}
