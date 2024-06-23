//
//  CreateWordBookTip.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/06/08.
//

import Foundation
import TipKit

struct CreateWordBookTip: Tip {
   
    var title: Text {
        Text(Localized.Create_your_Wordbook)
    }
    
    var message: Text? {
        Text(Localized.Tap_on_this_button_to_add_your_Wordbook_name)
    }
    
    var image: Image? {
        Image(.owntips)
    }
    
}
