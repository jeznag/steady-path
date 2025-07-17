//
//  pillBundle.swift
//  pill
//
//  Created by David Naguib on 17/7/2025.
//

import WidgetKit
import SwiftUI

@main
struct pillBundle: WidgetBundle {
    var body: some Widget {
        pill_widget()
        pillControl()
        pillLiveActivity()
    }
}
