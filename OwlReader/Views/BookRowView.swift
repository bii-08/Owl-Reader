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
                VStack {
                    if let dateAdded = book.dateAdded {
                        if isNew(date: dateAdded) {
                            Text("New")
                                .font(Font.custom("Palatino", size: 15))
                                .padding(4)
                                .foregroundColor(.white)
                                .background(.red.opacity(0.8))
                                .clipShape(Capsule())
                        }
                    }
                    AsyncImage(url: URL(string: book.image)) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 60)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        } else {
                            Image("bookreading")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 45, height: 60)
                        }
                    }
                }
                
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
                            Text(genre)
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
    
    func isNew(date: String) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        let todayString = dateFormatter.string(from: Date())
//        print("--today: \(todayString)")
        if date == todayString {
            return true
        } else {
            return false
        }
    }
}

//#Preview {
//    BookRowView(book: Book(title: "", author: ""))
//}
