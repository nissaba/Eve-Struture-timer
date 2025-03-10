//
//  KillTimeEvent.swift
//  Eve Struture timer
//
//  Created by Pascale on 2025-03-07.
//


import SwiftUI
import SwiftData

@Model
class KillTimeEvent {
    var date: Date
    var systemName: String
    var planet: Int8
    
    init(date: Date, systemName: String, planet: Int8) {
        self.date = date
        self.systemName = systemName
        self.planet = planet
    }
}
