//
//  HighlightTextView.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/06/04.
//

import SwiftUI

struct HighlightTextView: View {
    @State private var selectedWord: String?
    let paragraph: String = "Our town was baptized in the flood that year and the swelling of the river unearthed relics from long before men settled in these parts. That same year I buried my wife and infant son, both lost in birth. Months after they were gone, our train of ragged coaches met the elbow of that great river, and upon our manifest of provisions and mouths, we would continue no further and abide where we stood. Two dozen families in wheeled shelters began to fish and hunt and gather wood for burning and wood for building. The men were strong and fleet and they fashioned homesteads and fencing and a great church for the preacher to tout fable and promise. He carried his book with him and went about our nascent village to bless homes and new mothers alike. His robes and hat threadbare and humble but black and foreboding as a doctor of the plague."

    var body: some View {
        ZStack {
            Color("background").ignoresSafeArea()
            VStack {
                Text("Tap on a word to highlight it.")
                    .font(.headline)
                    .padding()
                
                ScrollView {
                    FlowLayout(items: paragraph.split(separator: " ").map(String.init), selectedWord: $selectedWord)
                        .padding()
                }
                BannerView()
                    .frame(height: 60)
            }
        }
    }
}

struct FlowLayout: View {
    var items: [String]
    @Binding var selectedWord: String?
    
    private let horizontalSpacing: CGFloat = 4
    private let verticalSpacing: CGFloat = 4
    
    var body: some View {
        GeometryReader { geometry in
            createFlow(in: geometry.size)
        }
    }
    
    private func createFlow(in size: CGSize) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        
        return ZStack(alignment: .topLeading) {
            ForEach(items.indices, id: \.self) { index in
                item(for: items[index])
                    .padding([.horizontal], horizontalSpacing / 2)
                    .alignmentGuide(.leading) { dimension in
                        if (abs(width - dimension.width) > size.width) {
                            width = 0
                            height -= dimension.height + verticalSpacing
                        }
                        let result = width
                        if index == items.count - 1 {
                            width = 0
                        } else {
                            width -= dimension.width
                        }
                        return result
                    }
                    .alignmentGuide(.top) { _ in
                        let result = height
                        if index == items.count - 1 {
                            height = 0
                        }
                        return result
                    }
            }
        }
    }
    
    private func item(for word: String) -> some View {
        let lettersOnlyWord = word.filter { $0.isLetter }
        return Text(word)
                    .foregroundColor(selectedWord == lettersOnlyWord ? .blue : .primary)
                    .background(selectedWord == lettersOnlyWord ? Color.yellow : Color.clear)
                    .onTapGesture {
                        selectedWord = lettersOnlyWord
                        print("\(String(describing: selectedWord))")
                    }
    }
}

struct HighlightTextView_Previews: PreviewProvider {
    static var previews: some View {
        HighlightTextView()
    }
}
