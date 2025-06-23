//
//  Bundle+AppVesion.swift
//  Eve Struture timer
//
//  Created by Pascale on 2025-06-23.
//

import Foundation

extension Bundle {
    static func appVersionAndBuild() -> String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "?"
        return "Version \(version) (\(build))"
    }
}
