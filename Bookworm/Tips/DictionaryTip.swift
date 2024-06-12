//
//  DictionaryTip.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/06/08.
//

import Foundation
import TipKit

struct DictionaryTip: Tip {
    
    var title: Text {
        Text(Localized.Search_new_words)
    }
    
    var message: Text? {
        Text(Localized.Tap_on_this_plus_button_to_search_for_words)
    }
    
    var image: Image? {
        Image(.owntips)
    }
}
