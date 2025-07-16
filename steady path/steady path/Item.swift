//
//  Item.swift
//  steady path
//
//  Created by hackathon on 16/7/2025.
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
