//
//  Link.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/04/24.
//

import Foundation
import SwiftUI

struct Link: Identifiable, Hashable {
    var id: String {
        self.url.absoluteString
    }
    var url: URL
    var favicon: UIImage?
    var webPageTitle: String
}



 
