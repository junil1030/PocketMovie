//
//  DefaultWidgetRepository.swift
//  PocketMovie
//
//  Created by 서준일 on 5/26/25.
//

import Foundation
import WidgetKit

final class UserDefaultsWidgetRepository: WidgetRepository {
    private let sharedDefaults: UserDefaults?
    private let maxWidgetMovies: Int
    private let widgetDataKey = "widget_movies"
    
    init(appGroupIdentifier: String = "group.com.junil.pocketmovie", maxWidgetMovies: Int = 10) {
        self.sharedDefaults = UserDefaults(suiteName: appGroupIdentifier)
        self.maxWidgetMovies = maxWidgetMovies
    }
    
    func loadWidgetData() -> WidgetDataContainer {
        guard let data = sharedDefaults?.data(forKey: widgetDataKey),
              let widgetData = try? JSONDecoder().decode(WidgetDataContainer.self, from: data) else {
            return WidgetDataContainer.empty
        }
        return widgetData
    }
    
    func saveWidgetData(_ data: WidgetDataContainer) {
        do {
            let encodedData = try JSONEncoder().encode(data)
            sharedDefaults?.set(encodedData, forKey: widgetDataKey)
            notifyWidgetUpdate()
        } catch {
            print("위젯 데이터 저장 실패: \(error)")
        }
    }
    
    func addMovieToWidget(_ movie: MovieDTO) {
        var currentData = loadWidgetData()
        
        // 이미 존재하는지 확인
        if !currentData.movies.contains(where: { $0.id == movie.id }) {
            // 맨 앞에 추가
            currentData.movies.insert(movie, at: 0)
            
            // 최대 개수 제한
            if currentData.movies.count > maxWidgetMovies {
                currentData.movies = Array(currentData.movies.prefix(maxWidgetMovies))
            }
            
            currentData.lastUpdated = Date()
            saveWidgetData(currentData)
        }
    }
    
    func removeMovieFromWidget(movieId: String) {
        var currentData = loadWidgetData()
        
        if currentData.movies.contains(where: { $0.id == movieId }) {
            currentData.movies.removeAll { $0.id == movieId }
            currentData.lastUpdated = Date()
            saveWidgetData(currentData)
        }
    }
    
    func removeMoviesFromWidget(movieIds: [String]) {
        var currentData = loadWidgetData()
        let movieIdSet = Set(movieIds)
        
        let originalCount = currentData.movies.count
        currentData.movies.removeAll { movieIdSet.contains($0.id) }
        
        // 실제로 삭제된 항목이 있는 경우에만 저장
        if currentData.movies.count != originalCount {
            currentData.lastUpdated = Date()
            saveWidgetData(currentData)
        }
    }
    
    func updateMovieInWidget(_ movie: MovieDTO) {
        var currentData = loadWidgetData()
        
        if let index = currentData.movies.firstIndex(where: { $0.id == movie.id }) {
            currentData.movies[index] = movie
            currentData.lastUpdated = Date()
            saveWidgetData(currentData)
        }
    }
    
    func getWidgetMovieIds() -> Set<String> {
        let currentData = loadWidgetData()
        return Set(currentData.movies.map { $0.id })
    }
    
    func clearWidgetData() {
        sharedDefaults?.removeObject(forKey: widgetDataKey)
        notifyWidgetUpdate()
    }
    
    private func notifyWidgetUpdate() {
        WidgetCenter.shared.reloadTimelines(ofKind: "PocketMovieWidget")
    }
}
