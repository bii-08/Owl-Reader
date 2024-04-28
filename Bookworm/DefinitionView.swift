//
//  DefinitionView.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/04/23.
//

import SwiftUI

struct DefinitionView: View {
    var word: String
    
    var body: some View {
        VStack {
            Text(word)
                .textCase(.uppercase)
                .bold()
        }
    }
}

#Preview {
    DefinitionView(word: "incoherent")
}
