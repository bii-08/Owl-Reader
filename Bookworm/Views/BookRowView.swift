//
//  BookRowView.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/06/05.
//

import SwiftUI

struct BookRowView: View {
    var book: Book
    @ObservedObject var markAsRead = MarkAsRead.shared
    var body: some View {
        VStack {
            HStack {
                Image("\(book.title)")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 55)
                VStack(alignment: .leading) {
                    Text("\(book.title)")
                        .font(Font.custom("Palatino", size: 18))
                        .foregroundColor(.primary)
                    Text("\(book.author)")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                if markAsRead.contains(book) {
                    Spacer()
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.teal)
                }
            }
        }
    }
}

#Preview {
    BookRowView(book: Book(title: "", author: ""))
}
