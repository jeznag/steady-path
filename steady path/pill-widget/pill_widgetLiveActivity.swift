//
//  pill_widgetLiveActivity.swift
//  pill-widget
//
//  Created by hackathon on 16/7/2025.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct pill_widgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct pill_widgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: pill_widgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension pill_widgetAttributes {
    fileprivate static var preview: pill_widgetAttributes {
        pill_widgetAttributes(name: "World")
    }
}

extension pill_widgetAttributes.ContentState {
    fileprivate static var smiley: pill_widgetAttributes.ContentState {
        pill_widgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: pill_widgetAttributes.ContentState {
         pill_widgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: pill_widgetAttributes.preview) {
   pill_widgetLiveActivity()
} contentStates: {
    pill_widgetAttributes.ContentState.smiley
    pill_widgetAttributes.ContentState.starEyes
}
