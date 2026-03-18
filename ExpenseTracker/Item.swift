//
//  Item.swift
//  ExpenseTracker
//
//  Created by David Küng on 18.03.26.
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
