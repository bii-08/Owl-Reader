//
//  BookRowView.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/06/05.
//

import SwiftUI

struct BookRowView: View {
    var book: Book = Book(title: "The Monkey’s paw", author: "The Monkey’s paw")
    
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
            }
        }
    }
}

#Preview {
    BookRowView(book: Book(title: "", author: ""))
}
