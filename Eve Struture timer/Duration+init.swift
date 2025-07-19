//
//  Duration+init.swift
//  Eve Struture timer
//
//  Created by Pascale on 2025-07-19.
//

import Foundation

extension Duration: CustomStringConvertible {
    var description: String {
        var components: [String] = []
        if days > 0 { components.append("\(days)d") }
        if hours > 0 { components.append("\(hours)h") }
        if minutes > 0 { components.append("\(minutes)m") }
        return components.joined(separator: " ")
    }
}

extension Duration {
    init(from timeInterval: TimeInterval) {
        let totalMinutes = Int(timeInterval) / 60
        self.days = totalMinutes / (24 * 60)
        self.hours = (totalMinutes % (24 * 60)) / 60
        self.minutes = totalMinutes % 60
    }
}
