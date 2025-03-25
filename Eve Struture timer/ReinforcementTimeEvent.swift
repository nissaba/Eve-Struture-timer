//
//  KillTimeEvent.swift
//  Eve Struture timer
//
//  Created by Pascale on 2025-03-07.
//


import SwiftUI
import SwiftData

@Model
class ReinforcementTimeEvent {
    var date: Date
    var systemName: String
    var planet: Int8
    var isDefence: Bool
    
    init(date: Date, systemName: String, planet: Int8, isDefence: Bool) {
        self.date = date
        self.systemName = systemName
        self.planet = planet
        self.isDefence = isDefence
    }
    var isPastDue: Bool {
            return date < Date() // Returns true if the event date is in the past
        }
}
