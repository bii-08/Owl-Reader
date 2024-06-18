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
                Image(book.hasImage ? "\(book.title)" : "bookreading")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 45, height: 60)
                VStack(alignment: .leading) {
                    Text("\(book.title)")
                        .font(Font.custom("Palatino", size: 18))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.primary)
                    Text("\(book.author)")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                    
                        HStack {
                            Text("\(book.wordCount) words")
                                .font(Font.custom("Palatino", size: 15))
                                .frame(minWidth: 100, minHeight: 20)
                                .background(.orange.opacity(0.5))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            Text("Grade: \(book.grade)")
                                .font(Font.custom("Palatino", size: 15))
                                .frame(minWidth: 70, minHeight: 20)
                                .background(.pink.opacity(0.3))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .padding(.vertical, 2)
                        if let genre = book.genre {
                            Text(genre.rawValue)
                                .font(Font.custom("Palatino", size: 15))
                                .frame(minWidth: 80, minHeight: 20)
                                .background(.mint.opacity(0.5))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                }
                
                if markAsRead.contains(book) {
                    Spacer()
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.tabBarButton)
                        .imageScale(.large)
                        .padding(.vertical, 30)
                       
                }
            }
            
        }
        .padding(.horizontal, 10)
    }
}

//#Preview {
//    BookRowView(book: Book(title: "", author: ""))
//}
