//
//  pill_widget.swift
//  pill-widget
//
//  Created by hackathon on 16/7/2025.
//

import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent())
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: configuration)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        return Timeline(entries: entries, policy: .atEnd)
    }

//    func relevances() async -> WidgetRelevances<ConfigurationAppIntent> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
}

struct pill_widgetEntryView : View {
    var entry: Provider.Entry
    @State private var isActive: Bool = false

    var body: some View {
        ZStack {
            Color.clear
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Text("Last Medication Record:")
                    .font(.headline)
                    .fontWeight(.semibold)
                Text(entry.date, style: .time)
                    .foregroundStyle(Color.secondary)
            }
            .frame(maxWidth: .infinity)
            .widgetURL(URL(string: "steadypath://Pill"))
        }
       
    }
}

struct pill_widget: Widget {
    let kind: String = "pill_widget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            pill_widgetEntryView(entry: entry)
                .containerBackground(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.orange.opacity(0.8),
                            Color.red.opacity(0.6),
                            Color.orange.opacity(0.9),
                            Color.yellow.opacity(0.7)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    for: .widget
                )
        }
        .supportedFamilies([.systemMedium])
    }
}

#Preview(as: .systemMedium) {
    pill_widget()
} timeline: {
    SimpleEntry(date: .now, configuration: ConfigurationAppIntent())
}
