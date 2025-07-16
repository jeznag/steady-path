//
//  Item.swift
//  SteadyPath
//
//  Created by Jeremy Nagel on 16/7/2025.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
