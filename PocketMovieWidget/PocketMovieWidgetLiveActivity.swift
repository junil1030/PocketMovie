//
//  PocketMovieWidgetLiveActivity.swift
//  PocketMovieWidget
//
//  Created by 서준일 on 5/24/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct PocketMovieWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct PocketMovieWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PocketMovieWidgetAttributes.self) { context in
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

extension PocketMovieWidgetAttributes {
    fileprivate static var preview: PocketMovieWidgetAttributes {
        PocketMovieWidgetAttributes(name: "World")
    }
}

extension PocketMovieWidgetAttributes.ContentState {
    fileprivate static var smiley: PocketMovieWidgetAttributes.ContentState {
        PocketMovieWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: PocketMovieWidgetAttributes.ContentState {
         PocketMovieWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: PocketMovieWidgetAttributes.preview) {
   PocketMovieWidgetLiveActivity()
} contentStates: {
    PocketMovieWidgetAttributes.ContentState.smiley
    PocketMovieWidgetAttributes.ContentState.starEyes
}
