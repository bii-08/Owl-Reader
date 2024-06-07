//
//  HighlightTextView.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/06/04.
//

import SwiftUI

struct StoryReadingView: View {
    @StateObject var storyReadingVM: StoryReadingVM
    @State private var flowLayoutHeight: CGFloat = 0 {
        didSet {
            print(flowLayoutHeight)
        }
    }
    
    var body: some View {
            ScrollView {
                VStack(alignment: .leading) {
                    if let content = storyReadingVM.content {
                        let words = slitWords(content: content)
                        FlowLayout(items: words, selectedWord: $storyReadingVM.selectedWord)
                            .onPreferenceChange(FlowLayoutHeightKey.self) { newHeight in
                                flowLayoutHeight = newHeight
                            }
                    } else {
                        Text("Loading content...")
                            .padding()
                    }
                }
                .padding()
                .frame(height: flowLayoutHeight)
            }
            .navigationTitle("\(storyReadingVM.book.title)")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                storyReadingVM.loadTextFile(named: storyReadingVM.book.title)
            }
       
    }
    
    func slitWords(content: String) -> [String] {
        let words = content.components(separatedBy: " ")
        print(words)
        return words
    }
}

struct FlowLayoutHeightKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

class FlowViewModel: ObservableObject {
    @Published var height: CGFloat = 0
}

struct FlowLayout: View {
    var items: [String]
    @Binding var selectedWord: String?
    
    @ObservedObject var vm = FlowViewModel()
    
    var body: some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        
        return GeometryReader { geo in
            ZStack(alignment: .topLeading) {
                ForEach(items.indices, id: \.self) { index in
                    item(for: items[index])
                        .padding(.all, 2.5)
                        .alignmentGuide(.leading) { dimension in
                            if(abs(CGFloat(width) - dimension.width) > geo.size.width) {
                                width = 0
                                height -= CGFloat(Float(dimension.height))
                            }
                            let result = width
                            if items[index] == items.last {
                                width = 0
                            } else if items[index] == "<break>" {
                                width = 0
                            } else {
                                width -= CGFloat(Float(dimension.width))
                            }
                            return CGFloat(result)
                        }
                        .alignmentGuide(.top) { dimension in
                            let result = height
                            if items[index] == items.last {
                                if vm.height == 0 {
                                    vm.height = abs(height) + 80
                                    print(vm.height)
                                }
                                height = 0
                                print("-----> setting height = 0, word is \(items[index])")
                            } else if items[index] == "<break>" {
                                height -= 60
                            }
                            print("-----> setting height \(result)")
                            return CGFloat(result)
                        }
                }
            }
            .preference(key: FlowLayoutHeightKey.self, value: vm.height)
        }
    }
    
    private func item(for word: String) -> some View {
        let lettersOnlyWord = word.filter { $0.isLetter }
        if word == "<break>" {
            return AnyView(Text(""))
        } else {
            return AnyView(Text(word)
                .foregroundColor(selectedWord == lettersOnlyWord ? .blue : .primary)
                .background(selectedWord == lettersOnlyWord ? Color.yellow : Color.clear)
                .onTapGesture {
                    selectedWord = lettersOnlyWord
                    print("\(String(describing: selectedWord))")
                })
        }
        
    }
}

#Preview {
    DailyStoryListView()
}
