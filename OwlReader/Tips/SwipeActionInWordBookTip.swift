//
//  SwipeActionTip.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/06/08.
//

import Foundation
import TipKit

struct SwipeActionInWordBookTip: Tip {
    static let swipeActionInWordBookEvent = Event(id: "swipeActionInWordBookEvent")
    
    var options: [TipOption] {
        [
            Tips.MaxDisplayCount(1)
        ]
    }
    
    var title: Text {
        Text(Localized.Swipe_Action)
    }
    
    var message: Text? {
        Text(Localized.Swipe_from_trailing_edge_to_edit_or_delete_your_wordBook)
    }
    var image: Image? {
        Image(.owntips)
    }
    
    var rules: [Rule] {
        [
            #Rule(Self.swipeActionInWordBookEvent) { event in
                event.donations.count >= 1
            }
        ]
    }
}
