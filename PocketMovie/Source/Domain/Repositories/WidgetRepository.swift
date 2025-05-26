//
//  WidgetRepository.swift
//  PocketMovie
//
//  Created by 서준일 on 5/26/25.
//

import Foundation

protocol WidgetRepository {
    func loadWidgetData() -> WidgetDataContainer
    func saveWidgetData(_ data: WidgetDataContainer)
    func addMovieToWidget(_ movie: MovieDTO)
    func removeMovieFromWidget(movieId: String)
    func removeMoviesFromWidget(movieIds: [String])
    func updateMovieInWidget(_ movie: MovieDTO)
    func getWidgetMovieIds() -> Set<String>
    func clearWidgetData()
}
