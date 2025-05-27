//
//  WidgetEntry.swift
//  PocketMovie
//
//  Created by 서준일 on 5/27/25.
//

import WidgetKit
import SwiftUI

struct MovieWidgetEntry: TimelineEntry {
    let date: Date
    let movies: [MovieDTO]
    let currentMovieIndex: Int
    
    var currentMovie: MovieDTO? {
        guard !movies.isEmpty, currentMovieIndex < movies.count else { return nil }
        return movies[currentMovieIndex]
    }
}
