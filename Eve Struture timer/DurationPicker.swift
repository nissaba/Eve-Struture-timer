//
//  DurationPicker.swift
//  Eve Struture timer
//
//  Created by Pascale on 2025-07-01.
//

import SwiftUI



struct DurationPicker: View {
    @State var days: Int = 0
    @State var hours: Int = 0
    @State var minutes: Int = 0
    @Binding var duration: Duration
    
    init(duration: Binding<Duration>) {
        self._duration = duration
        let value = duration.wrappedValue
        self._days = State(initialValue: value.days)
        self._hours = State(initialValue: value.hours)
        self._minutes = State(initialValue: value.minutes)
    }
    
    var body: some View {
        VStack{
            HStack(spacing: 30){
                Text("Days")
                Text("Hours")
                Text("Minutes")
            }
            .font(.footnote)
            HStack {
                Spacer()
                // Days
                CustomNumberPicker(value: $days, maxValue: 7)
                Text(":")
                // Hours
                CustomNumberPicker(value: $hours, maxValue: 23)
                Text(":")
                // Minutes
                CustomNumberPicker(value: $minutes, maxValue: 59)
               Spacer()
            }
           
        }
        .frame(width: 170, height: 40)
        .padding()
        .onAppear {
            days = duration.days
            hours = duration.hours
            minutes = duration.minutes
        }
        .onChange(of: days) { _,newValue in
            duration = Duration(days: newValue, hours: hours, minutes: minutes)
        }
        .onChange(of: hours) { _,newValue in
            duration = Duration(days: days, hours: newValue, minutes: minutes)
        }
        .onChange(of: minutes) { _,newValue in
            duration = Duration(days: days, hours: hours, minutes: newValue)
        }
    }
}

struct PreviewWrapper: View {
    @State private var duration = Duration()
    var body: some View {
        DurationPicker(duration: $duration)
    }
}

#Preview {
    
    PreviewWrapper()
}


struct Duration: Equatable {
    var days: Int = 0
    var hours: Int = 0
    var minutes: Int = 0
}

struct DurationPickers: View {
    @State private var duration = Duration()

    var body: some View {
        VStack {
            HStack {
                Picker("Days", selection: $duration.days) {
                    ForEach(0..<2) { day in
                        Text("\(day)").tag(day)
                    }
                }
                .pickerStyle(.automatic)

                Picker("Hours", selection: $duration.hours) {
                    ForEach(0..<24) { hour in
                        Text("\(hour)").tag(hour)
                    }
                }
                .pickerStyle(.automatic)

                Picker("Minutes", selection: $duration.minutes) {
                    ForEach(0..<60) { minute in
                        Text("\(minute)").tag(minute)
                    }
                }
                .pickerStyle(.automatic)
            }
            Text("Selected Duration: \(duration.days)d \(duration.hours)h \(duration.minutes)m")
        }
    }
}

#Preview {
    DurationPickers()
}

