//
//  SheetView.swift
//  Eve Struture timer
//
//  Created by Pascale on 2025-03-08.
//

import SwiftUI

struct SheetView: View {
    @Binding var isVisible: Bool

    var body: some View {
        VStack {
            Text("This is a sheet.")
            Button("OK") {
                self.isVisible = false
            }
        }
        .frame(width: 300, height: 150)
    }
}
