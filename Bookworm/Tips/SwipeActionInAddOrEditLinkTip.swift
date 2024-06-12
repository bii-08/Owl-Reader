//
//  SwipeActionInAddOrEditLinkTip.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/06/08.
//

import Foundation
import TipKit

struct SwipeActionInAddOrEditLinkTip: Tip {
    
    var title: Text {
        Text(Localized.Swipe_Action)
    }
    
    var message: Text? {
        Text(Localized.Swipe_from_trailing_edge_to_edit_or_delete_your_shortcut)
    }
    var image: Image? {
        Image(.owntips)
    }
}
