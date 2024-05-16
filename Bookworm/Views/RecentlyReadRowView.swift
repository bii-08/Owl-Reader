//
//  RecentlyReadRowView.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/05/10.
//

import SwiftUI

struct RecentlyReadRowView: View {
    @State private var recentlyReadURLs: [Link] = []
    var body: some View {
        ScrollView {
            ForEach(recentlyReadURLs, id: \.self) { url in
                Text(url.url.absoluteString)
            }
        }
    }
}

#Preview {
    RecentlyReadRowView()
}
