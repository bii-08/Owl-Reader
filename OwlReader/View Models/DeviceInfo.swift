//
//  DeviceInfo.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/06/12.
//

import Foundation
import UIKit

class DeviceInfo: ObservableObject {
    static let shared: DeviceInfo = DeviceInfo()
    
    func getDeviceType() -> DeviceType {
        if UIDevice.current.userInterfaceIdiom == .pad {
             return .pad
         } else {
             return .phone
         }
     }
}
