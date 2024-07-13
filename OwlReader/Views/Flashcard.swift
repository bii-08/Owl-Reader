//
//  Flashcard.swift
//  OwlReader
//
//  Created by LUU THANH TAM on 2024/07/05.
//

import SwiftUI

enum Dificulty: String {
    case bad, okay, good, perfect
}
struct FlashcardWord {
    var word: Word
    var dificulty: Dificulty
}

struct Review: View {
    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()
        }
    }
}

struct ReviewingWordView: View {
    
    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()
            VStack {
                BannerView()
                    .frame(height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .padding(.horizontal)
                
                Flashcard(front: {
                    Text("front")
                }, back: {
                    Text("back")
                })
                .padding(.vertical, 60)
                
                HStack {
                    Button("Bad") {
                        
                    }
                    .buttonStyle(.borderedProminent)
                    .accentColor(.red.opacity(0.8))
                    
                    Button("Okay") {
                        
                    }
                    .buttonStyle(.borderedProminent)
                    .accentColor(.orange.opacity(0.8))
                    
                    Button("Good") {
                        
                    }
                    .buttonStyle(.borderedProminent)
                    .accentColor(.green.opacity(0.8))
                    
                    Button("Perfect") {
                        
                    }
                    .buttonStyle(.borderedProminent)
                    .accentColor(.purple.opacity(0.8))
                }
            }
            
        }
    }
}


struct Flashcard<Front, Back>: View where Front: View, Back: View {
    var front: () -> Front
    var back: () -> Back
    
    @State var flipped: Bool = false
    @State var flashcardRotation = 0.0
    @State var contentRotation = 0.0
    
    init(@ViewBuilder front: @escaping () -> Front, @ViewBuilder back: @escaping () -> Back) {
        self.front = front
        self.back = back
    }
    var body: some View {
        ZStack {
            if flipped {
                back()
            } else {
                front()
            }
        }
        .rotation3DEffect(.degrees(contentRotation), axis: (x: 0, y: 1, z:0))
        .frame(height: 400)
        .frame(maxWidth: .infinity)
        .background(Color.pink)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding()
        .onTapGesture {
            flipFlashcard()
        }
        .rotation3DEffect(.degrees(flashcardRotation), axis: (x: 0, y: 1, z:0))
    }
    
    private func flipFlashcard() {
        let animationTime = 0.5
        withAnimation(Animation.linear(duration: animationTime)) {
            flashcardRotation += 180
        }
        withAnimation(Animation.linear(duration: 0.001).delay(animationTime / 2)) {
            contentRotation += 180
            flipped.toggle()
        }
       
    }
}

//#Preview {
//    Flashcard()
//}
