//
//  RequestCounterTip.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/06/08.
//

import Foundation
import TipKit

struct RequestCounterTip: Tip {
  
    var title: Text {
        Text(Localized.Request_Balance)
    }
    
    var message: Text? {
        Text(Localized.This_is_an_indicator_for_your_request_remaining_balance)
    }
    
    var image: Image? {
        Image(.owntips)
    }
    
}

