//
//  PocketMovieWidgetBundle.swift
//  PocketMovieWidget
//
//  Created by 서준일 on 5/26/25.
//

import WidgetKit
import SwiftUI

@main
struct PocketMovieWidgetBundle: WidgetBundle {
    var body: some Widget {
        PocketMovieWidget()
        PocketMovieWidgetControl()
    }
}
