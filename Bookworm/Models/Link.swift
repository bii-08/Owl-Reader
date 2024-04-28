//
//  Link.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/04/24.
//

import Foundation

struct Link: Identifiable, Hashable {
    var id: URL {
        self.url
    }
    var url: URL
    var favicon: URL?
    var webPageTitle: String
}
