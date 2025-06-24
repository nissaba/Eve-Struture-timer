//
//  Eve_Struture_timerTests.swift
//  Eve Struture timerTests
//
//  Created by Pascale on 2025-06-24.
//

import Testing
import Foundation
import SwiftData

@MainActor
@Suite("EventFormViewModel regression and logic tests")
struct EventFormViewModelTests {
    
    // Helper to create a new ViewModel with minimal valid data
    func makeViewModel() -> EventFormViewModel {
        // TODO: Replace `YourModelType` with your actual model type(s)
        let container = try! ModelContainer(for:ReinforcementTimeEvent.self , configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let context = container.mainContext
        return EventFormViewModel(context: context)
    }

    @Test("Validates correct due date calculation with 0 offset")
    func testDueDateNoOffset() async throws {
        // TODO: Replace `YourModelType` with your actual model type(s)
        let container = try! ModelContainer(for: ReinforcementTimeEvent.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let context = container.mainContext
        
        let viewModel = EventFormViewModel(context: context)
        let now = Date()
        viewModel.eventStartTime = formatDate(now)
        viewModel.timeToAdd = "0:00:00"
        viewModel.calculateFutureTime()
        
        // Should be equal (to the minute, since formatting may cut seconds)
        let formatted = viewModel.resultText
        #expect(formatted.hasPrefix(formatDate(now)), "Due date should match input date with no offset.")
    }
    
    @Test("Validates due date calculation with 1:02:30 offset")
    func testDueDatePositiveOffset() async throws {
        // TODO: Replace `YourModelType` with your actual model type(s)
        let container = try! ModelContainer(for: ReinforcementTimeEvent.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let context = container.mainContext
        
        let viewModel = EventFormViewModel(context: context)
        let now = Date()
        viewModel.eventStartTime = formatDate(now)
        viewModel.timeToAdd = "1:02:30"
        viewModel.calculateFutureTime()
        
        let calendar = Calendar.current
        let future = calendar.date(byAdding: .day, value: 1, to: now)!
        let futurePlusHours = calendar.date(byAdding: .hour, value: 2, to: future)!
        let finalDate = calendar.date(byAdding: .minute, value: 30, to: futurePlusHours)!
        let formatted = viewModel.resultText
        #expect(formatted.hasPrefix(formatDate(finalDate)), "Due date should include all offsets.")
    }
    
    @Test("Rejects invalid timeToAdd format")
    func testTimeToAddValidation() async throws {
        let viewModel = makeViewModel()
        viewModel.timeToAdd = "xyz"
        viewModel.validateTimeToAdd()
        #expect(viewModel.timeToAddError != nil, "Invalid timeToAdd string should populate error.")
        viewModel.timeToAdd = "1:00:00"
        viewModel.validateTimeToAdd()
        #expect(viewModel.timeToAddError == nil, "Valid timeToAdd string should not set error.")
    }
    
    // Helper to format dates as the production view model expects
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: date)
    }
}

